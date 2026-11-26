$glbPath = "c:\Users\ihyoj\Desktop\DP_12주차 실습\model.glb"
$bytes = [System.IO.File]::ReadAllBytes($glbPath)
$b64 = [Convert]::ToBase64String($bytes)
$dataUrl = "data:model/gltf-binary;base64," + $b64

$htmlPath = "c:\Users\ihyoj\Desktop\DP_12주차 실습\index (1).html"
$html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
$html = $html -replace 'url\(model\.glb\)', ("url(" + $dataUrl + ")")
$html = $html -replace 'src="model\.glb"', ('src="' + $dataUrl + '"')
[System.IO.File]::WriteAllText($htmlPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "완료! HTML 파일에 GLB가 내장됐습니다." -ForegroundColor Green
