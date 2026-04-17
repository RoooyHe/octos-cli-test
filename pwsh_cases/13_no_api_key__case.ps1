$env:ANTHROPIC_API_KEY = ""
$env:OPENAI_API_KEY = ""
$result = octos chat -m "hello"
if ($result -match "error|Error|API|key|key")
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}