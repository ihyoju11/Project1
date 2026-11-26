$folder = Split-Path -Parent $MyInvocation.MyCommand.Path
$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()
Write-Host "서버 시작! http://localhost:8080" -ForegroundColor Green
Write-Host "종료하려면 이 창을 닫으세요." -ForegroundColor Yellow
Start-Process "http://localhost:8080"
while ($http.IsListening) {
    $context = $http.GetContext()
    $rawPath = $context.Request.Url.LocalPath.TrimStart('/')
    $decoded = [System.Uri]::UnescapeDataString($rawPath)
    if ($decoded -eq '') { $decoded = 'index (1).html' }
    $filePath = Join-Path $folder $decoded
    if (Test-Path $filePath) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = switch ($ext) {
            '.html' { 'text/html; charset=utf-8' }
            '.glb'  { 'model/gltf-binary' }
            '.js'   { 'application/javascript' }
            '.css'  { 'text/css' }
            default { 'application/octet-stream' }
        }
        $context.Response.ContentType = $mime
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $context.Response.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
        $context.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $context.Response.Close()
}
