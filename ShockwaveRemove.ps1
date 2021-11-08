clear-Host

$computers = Get-Content -Path "C:\Shockwavelist\computers.txt"
$fileName = "C:\Windows\SysWOW64\Adobe\Shockwave 12"

Write-Host "Checking Shockwave..."

foreach ($computer in $computers) {
    if (Test-Path $fileName) {
  
   }       
}