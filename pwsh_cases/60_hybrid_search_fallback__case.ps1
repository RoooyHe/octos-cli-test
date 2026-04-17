$env:OPENAI_API_KEY = ""
$result = octos chat -m "搜索我之前提到的编程语言偏好"
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}