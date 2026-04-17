$result = octos completions bash --dynamic Models
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}