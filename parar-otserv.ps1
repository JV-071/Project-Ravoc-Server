[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$pidFile = Join-Path $PSScriptRoot ".otserv-runtime\processos.json"
$lockFile = Join-Path $PSScriptRoot ".otserv-runtime\iniciando.lock"

if (-not (Test-Path -LiteralPath $pidFile) -and -not (Test-Path -LiteralPath $lockFile)) {
    Write-Host "Nenhuma sessao iniciada pelo launcher foi encontrada." -ForegroundColor Yellow
    exit 0
}

$processes = if (Test-Path -LiteralPath $pidFile) {
    Get-Content -LiteralPath $pidFile -Raw | ConvertFrom-Json
} else {
    [pscustomobject]@{}
}
foreach ($name in @("crystalserver", "apache", "mariadb")) {
    $processId = $processes.$name
    if ($processId) {
        $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $processId -Force
            Write-Host "[OK] $name encerrado" -ForegroundColor Green
        }
    }
}

Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $lockFile -Force -ErrorAction SilentlyContinue
Write-Host "OTServ encerrado." -ForegroundColor Cyan
