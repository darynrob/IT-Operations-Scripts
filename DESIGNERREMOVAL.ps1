#As of June 25th 2020, this script is in development and testing phase.
#BY Roberts, Daryn, T, A1C, USAF

#Variables
$computername = Get-Content -path 'c:\Computers\computers.txt'
$sourcefile = "C:\SDC NIPR and SIPR - Adobe AEM Forms Designer - 190807\Files\x86\Source\setup.exe"

#This section will install the software 
foreach ($computer in $computername) 
{
    $destinationFolder = "\\$computer\C$\Temp"
    #It will copy $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.

    if (!(Test-Path -path $destinationFolder))
    {
        New-Item $destinationFolder -Type Directory
    }
    Copy-Item -Path $sourcefile -Destination $destinationFolder
    Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process 'c:\temp\setup.exe'}
}
