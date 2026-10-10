$ErrorActionPreference = 'Stop'

$source = 'C:\Users\LEANDRO\.codex\sessions'
$destination = 'D:\CodexData\sessions'
$backup = 'C:\Users\LEANDRO\.codex\sessions.before-d-move'
$log = 'D:\CodexData\finalizar-mudanca.log'

function Get-Manifest([string]$root) {
    $rootPath = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
    $manifest = @{}
    Get-ChildItem -LiteralPath $rootPath -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($rootPath.Length).TrimStart('\')
        $manifest[$relative] = $_.Length
    }
    return $manifest
}

function Test-ManifestsEqual($left, $right) {
    if ($left.Count -ne $right.Count) { return $false }
    foreach ($entry in $left.GetEnumerator()) {
        if (-not $right.ContainsKey($entry.Key)) { return $false }
        if ($right[$entry.Key] -ne $entry.Value) { return $false }
    }
    return $true
}

Write-Host ''
Write-Host 'Finalizando a mudanca das conversas do Codex para o disco D:' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $source)) {
    throw "Pasta de origem nao encontrada: $source"
}

$sourceItem = Get-Item -LiteralPath $source -Force
if ($sourceItem.LinkType -eq 'Junction') {
    Write-Host 'A mudanca ja foi concluida. As conversas ja estao no disco D:.' -ForegroundColor Green
    exit 0
}

$codexProcesses = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $_.ProcessName -match '^Codex' -or $_.ProcessName -eq 'ChatGPT'
}
if ($codexProcesses) {
    Write-Host 'Feche completamente o Codex e execute este arquivo novamente.' -ForegroundColor Yellow
    exit 2
}

if (Test-Path -LiteralPath $backup) {
    throw "A pasta de seguranca ja existe: $backup. Ela nao sera sobrescrita."
}

New-Item -ItemType Directory -Path $destination -Force | Out-Null

Write-Host '1/4 Sincronizando as conversas...' -ForegroundColor Cyan
& robocopy.exe $source $destination /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 /J /NP /NFL /NDL /NJH /NJS "/LOG:$log"
$robocopyExit = $LASTEXITCODE
if ($robocopyExit -ge 8) {
    throw "A sincronizacao falhou (codigo $robocopyExit). Veja: $log"
}

Write-Host '2/4 Conferindo todos os arquivos...' -ForegroundColor Cyan
$sourceManifest = Get-Manifest $source
$destinationManifest = Get-Manifest $destination
if (-not (Test-ManifestsEqual $sourceManifest $destinationManifest)) {
    throw 'A copia no disco D: nao corresponde exatamente a origem. Nada foi removido.'
}

Write-Host '3/4 Trocando a pasta por um redirecionamento para D:...' -ForegroundColor Cyan
Move-Item -LiteralPath $source -Destination $backup

try {
    New-Item -ItemType Junction -Path $source -Target $destination | Out-Null
    $junction = Get-Item -LiteralPath $source -Force
    if ($junction.LinkType -ne 'Junction') {
        throw 'O redirecionamento nao foi criado corretamente.'
    }

    $junctionManifest = Get-Manifest $source
    if (-not (Test-ManifestsEqual $destinationManifest $junctionManifest)) {
        throw 'O redirecionamento foi criado, mas a verificacao final falhou.'
    }

    Write-Host '4/4 Removendo somente a copia antiga ja verificada do disco C:...' -ForegroundColor Cyan
    Remove-Item -LiteralPath $backup -Recurse -Force
}
catch {
    if (Test-Path -LiteralPath $source) {
        $failedItem = Get-Item -LiteralPath $source -Force
        if ($failedItem.LinkType -eq 'Junction') {
            Remove-Item -LiteralPath $source -Force
        }
    }
    if ((Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $source)) {
        Move-Item -LiteralPath $backup -Destination $source
    }
    throw
}

Write-Host ''
Write-Host 'Concluido! As conversas continuam aparecendo normalmente, mas agora ficam no disco D:.' -ForegroundColor Green
Write-Host "Destino: $destination"
