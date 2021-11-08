<#
BY A1C DARYN ROBERTS 
03 July 2020

Purpose:
This Script is an attempt [2] to copy a source installation file from the computer's local drive and execute said file
on a specified list of hosts 


#>


#$UNC ='\\wcjx-fs-001v\Software\LifeCycle_Source\'
$sourcefile = "C:\Install2\Designer.msi"
$computers= Get-Content -path "C:\Computers\Groupsegment.txt"
$dest = "c$"
$dirinstall = "\\$computer\$dest\designer.msi"

 function Install-AEMDesigner {
            Write-Host "Starting Installation!!"
                if (test-path -path $dirinstall <#directory of install#>) {
                    invoke-command -computername $computers -ScriptBlock {
                    msiexec.exe $dirinstall <#Directory of install#> /s    
                    Write-Host -BackgroundColor DarkGreen -ForegroundColor White "Installation successful!!!"
                    }
                } 
            }     

clear-host
   foreach($computer in $computers){ 
      #if (Test-Connection -ComputerName $computer -count 1 -quiet) {
        #invoke-command -ComputerName $computers -ScriptBlock {
            #new-item -path 'c:\' -name Temp03 -ItemType directory
            Copy-item $sourcefile -Destination "\\$computer\$dest" -recurse -force

            if(test-path -path $dirinstall){
                Write-Host "Item has been copied!!!"
                Install-AEMDesigner
            }
            else {
                Write-Host "Item has not copied"
   #Start-Process -FilePath "c:\temp\setup.exe"

            }
         #} 
      #}
   }
