$Computername = 'Computer'
Get-WmiObject Win32_Product -ComputerName $computername | Select-Object -Property IdentifyingNumber, Name
