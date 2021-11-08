#Test Tanium(ARAD) Client Health

$Service = (Get-Service -Name *Tanium*).Status

$Port = (Get-NetTCPConnection -LocalPort 17472).state

$File = Test-Path -Path 'C:\Program Files (X86)\tanium\Tanium Client'

$Server = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Tanium\Tanium Client' | Select-Object ServerName

if ( ($Service -eq "Running" ) -and ( $Port -ne $null ) -and ($File -eq "True") -and ($Server -match "ts1" -or "ts2" ) )

{ Write-Host "client Health Check - Passed/Active" }
Else {Write-Host "Client Health Check - Failed/Inactive" }
