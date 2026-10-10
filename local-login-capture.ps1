param(
    [string]$Prefix = 'http://localhost:7777/',
    [string]$LogPath = "$PSScriptRoot\local-login-capture.log"
)

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($Prefix)
$listener.Prefixes.Add('http://127.0.0.1:7777/')
$listener.Start()
Write-Output "Listening on $Prefix"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $reader = [System.IO.StreamReader]::new($context.Request.InputStream, $context.Request.ContentEncoding)
    $body = $reader.ReadToEnd()
    $reader.Dispose()

    # Retain request shape while avoiding accidental storage of test credentials.
    $safeBody = $body -replace '(?i)("password"\s*:\s*")[^"]*', '$1[redacted]'
    $safeBody = $safeBody -replace '(?i)(password=)[^&\s]*', '$1[redacted]'
    $headers = ($context.Request.Headers.AllKeys | ForEach-Object { "${_}: $($context.Request.Headers[$_])" }) -join "`n"
    @(
        "[$([DateTime]::Now.ToString('o'))] $($context.Request.HttpMethod) $($context.Request.Url)",
        $headers,
        $safeBody,
        ''
    ) | Add-Content -LiteralPath $LogPath -Encoding utf8

    $response = '{"error":"Local login service is being configured. Please retry shortly."}'
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($response)
    $context.Response.StatusCode = 503
    $context.Response.ContentType = 'application/json'
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
}
