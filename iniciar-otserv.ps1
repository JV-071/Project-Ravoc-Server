[CmdletBinding()]
param(
    [string]$WebStackPath = "C:\xampp",
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$runtime = Join-Path $root ".otserv-runtime"
$logs = Join-Path $runtime "logs"
$pidFile = Join-Path $runtime "processos.json"
$lockFile = Join-Path $runtime "iniciando.lock"

New-Item -ItemType Directory -Force -Path $logs | Out-Null

function Test-Port {
    param([int]$Port)
    $client = [Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync("127.0.0.1", $Port)
        return $task.Wait(500) -and $client.Connected
    } catch {
        return $false
    } finally {
        $client.Dispose()
    }
}

function Wait-Port {
    param([int]$Port, [string]$Name, [int]$Seconds = 30)
    $limit = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $limit) {
        if (Test-Port $Port) { return }
        Start-Sleep -Milliseconds 500
    }
    throw "$Name nao respondeu na porta $Port em $Seconds segundos. Consulte os logs em $logs."
}

function Start-Component {
    param(
        [string]$Name,
        [string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory
    )
    if (-not (Test-Path -LiteralPath $FilePath)) {
        throw "$Name nao encontrado: $FilePath"
    }
    $stdout = Join-Path $logs "$Name.log"
    $stderr = Join-Path $logs "$Name-erro.log"
    $startParams = @{
        FilePath               = $FilePath
        WorkingDirectory       = $WorkingDirectory
        RedirectStandardOutput = $stdout
        RedirectStandardError  = $stderr
        PassThru               = $true
        WindowStyle            = "Hidden"
    }
    if ($Arguments.Count -gt 0) {
        $startParams.ArgumentList = $Arguments
    }
    $process = Start-Process @startParams
    Start-Sleep -Milliseconds 700
    if ($process.HasExited) {
        throw "$Name encerrou ao iniciar (codigo $($process.ExitCode)). Consulte $stderr."
    }
    return $process
}

if ((Test-Path -LiteralPath $pidFile) -or (Test-Path -LiteralPath $lockFile)) {
    Write-Host "Ja existe uma sessao registrada. Execute parar-otserv.cmd antes de iniciar novamente." -ForegroundColor Yellow
    exit 1
}

# Criado antes de subir qualquer processo para bloquear cliques duplos.
Set-Content -LiteralPath $lockFile -Value $PID -Encoding ASCII

$apacheExe = Join-Path $WebStackPath "apache\bin\httpd.exe"
$apacheConf = Join-Path $WebStackPath "apache\conf\httpd.conf"
$mysqlExe = Join-Path $WebStackPath "mysql\bin\mysqld.exe"
$mysqlDefaults = Join-Path $WebStackPath "mysql\bin\my.ini"
$serverExe = Join-Path $root "crystalserver.exe"

$started = [ordered]@{}
try {
    if (-not (Test-Port 3306)) {
        $p = Start-Component -Name "mariadb" -FilePath $mysqlExe `
            -Arguments @("--defaults-file=$mysqlDefaults", "--standalone") `
            -WorkingDirectory (Split-Path $mysqlExe)
        $started.mariadb = $p.Id
        Wait-Port -Port 3306 -Name "MariaDB"
        Write-Host "[OK] MariaDB na porta 3306" -ForegroundColor Green
    } else {
        Write-Host "[OK] Ja existe um banco na porta 3306" -ForegroundColor Green
    }

    if (-not (Test-Port 80)) {
        $p = Start-Component -Name "apache" -FilePath $apacheExe `
            -Arguments @("-f", $apacheConf) -WorkingDirectory (Split-Path $apacheExe)
        $started.apache = $p.Id
        Wait-Port -Port 80 -Name "Apache"
        Write-Host "[OK] Apache em http://127.0.0.1/" -ForegroundColor Green
    } else {
        Write-Host "[OK] Ja existe um servidor web na porta 80" -ForegroundColor Green
    }

    $existingServer = Get-Process -Name "crystalserver" -ErrorAction SilentlyContinue
    if ($existingServer -or (Test-Port 7172)) {
        throw "O Crystal Server ja esta aberto. Encerre a instancia existente antes de continuar."
    }
    $p = Start-Component -Name "crystalserver" -FilePath $serverExe -WorkingDirectory $root
    $started.crystalserver = $p.Id
    Write-Host "[...] Carregando mapa e scripts; isso pode levar alguns minutos..." -ForegroundColor Yellow
    Wait-Port -Port 7172 -Name "Crystal Server" -Seconds 300
    Write-Host "[OK] Crystal Server na porta 7172" -ForegroundColor Green

    [pscustomobject]$started | ConvertTo-Json | Set-Content -LiteralPath $pidFile -Encoding UTF8
    Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
    if (-not $NoBrowser) { Start-Process "http://127.0.0.1/" }
    Write-Host "`nTudo iniciado. Este console permanecera aberto para controle." -ForegroundColor Cyan
    Write-Host "Digite AJUDA para ver os comandos.`n" -ForegroundColor Cyan

    $keepConsoleOpen = $true
    while ($keepConsoleOpen) {
        $command = (Read-Host "OTServ").Trim().ToLowerInvariant()
        switch ($command) {
            { $_ -in @("ajuda", "help", "?") } {
                Write-Host ""
                Write-Host "  status  - mostra o estado dos servicos"
                Write-Host "  site    - abre o site no navegador"
                Write-Host "  log     - mostra as ultimas linhas do servidor"
                Write-Host "  reload  - mostra os comandos de reload dentro do jogo"
                Write-Host "  fechar  - encerra servidor, Apache e MariaDB"
                Write-Host ""
            }
            "status" {
                foreach ($service in @(
                    @{ Name = "Site/Apache"; Port = 80 },
                    @{ Name = "MariaDB"; Port = 3306 },
                    @{ Name = "Crystal Server"; Port = 7172 }
                )) {
                    $state = if (Test-Port $service.Port) { "ONLINE" } else { "OFFLINE" }
                    $color = if ($state -eq "ONLINE") { "Green" } else { "Red" }
                    Write-Host ("[{0}] {1} (porta {2})" -f $state, $service.Name, $service.Port) -ForegroundColor $color
                }
            }
            "site" { Start-Process "http://127.0.0.1/" }
            "log" {
                Write-Host "--- Ultimas linhas do Crystal Server ---" -ForegroundColor Cyan
                Get-Content (Join-Path $logs "crystalserver.log") -Tail 25 -ErrorAction SilentlyContinue
            }
            "reload" {
                Write-Host "O reload e executado dentro do jogo por um personagem GOD:" -ForegroundColor Yellow
                Write-Host "  /reload all        (recarrega tudo)"
                Write-Host "  /reload scripts    (scripts)"
                Write-Host "  /reload monsters   (monstros)"
                Write-Host "  /reload npcs       (NPCs)"
                Write-Host "  /reload config     (configuracao)"
            }
            { $_ -in @("fechar", "sair", "stop", "exit") } {
                Write-Host "Encerrando todos os componentes..." -ForegroundColor Yellow
                & (Join-Path $root "parar-otserv.ps1")
                $keepConsoleOpen = $false
            }
            "" { }
            default { Write-Host "Comando desconhecido. Digite AJUDA." -ForegroundColor Yellow }
        }
    }
} catch {
    Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
    foreach ($id in $started.Values) {
        Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
    exit 1
}
