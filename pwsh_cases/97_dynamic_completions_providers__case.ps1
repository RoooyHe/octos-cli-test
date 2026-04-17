$result = octos completions bash --dynamic Providers
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}