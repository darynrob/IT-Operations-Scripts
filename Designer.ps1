#Test this to see if Adobe LifeCycle Designer is removed from remote host computer
#As of June 8th 2020, this script is confirmed to have successfully removed the Adobe LifeCycle off a single machine.

$computers = Get-Content -Path "C:\computers.txt"

foreach ($computer in $computers) {
    if (Test-Connection -ComputerName $computer -Count 1 -Quiet) {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            $string = Get-ChildItem -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | 
            Get-ItemProperty | Where-Object DisplayName -eq 'Designer' | Select-Object -ExpandProperty PSChildName;
            Start-Process -FilePath msiexec.exe "/x $string /qn" -Wait -PassThru
        }
    }
}


# Will add on extra functions to check if registry files have been deleted from specific remote hosts
# Added function below tells whether computer has Designer installed or not.

if($string -eq $true){
    #$string = true
    echo "Found"
}
else {
    #a = false
    echo "Not found"
}