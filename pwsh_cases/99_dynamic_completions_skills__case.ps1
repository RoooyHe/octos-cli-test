$result = octos completions bash --dynamic Skills
if ($result)
{
    Write-Host "PASS"
}
else
{
    Write-Host "ERROR"
}