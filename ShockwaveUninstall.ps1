﻿$computers = Get-Content -Path "C:\Shockwavelist\computers.txt"

foreach ($computer in $computers) {
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            $string = Get-ChildItem -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | 
            Get-ItemProperty | Where-Object DisplayName -eq 'Adobe Shockwave Player 12.3' | Select-Object -ExpandProperty PSChildName;
            Start-Process -FilePath msiexec.exe "/x $string /qn" -Wait -PassThru
        }
    }
}
## Will add on extra functions to check if registry files have been deleted from specific remote hosts
#-------------------------------------------------------------
#This will be an attempt to test if registry key has been deleted

if($string -eq $true){
    #$string = true
    echo "Found"
}
else {
    #a = false
    echo "Not found"
}