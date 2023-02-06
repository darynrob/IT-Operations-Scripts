#script's purpose is to uninstall a program from a .txt file variable list of computers and offer the user of the specified targeted machine an option to accept a restart or reschedule the restart for a later date.
#Daryn Roberts, 2/6/2023


function Show-RestartPrompt {
  param (
    [string]$computerName
  )

  $objMessageBox = [System.Windows.Forms.MessageBox]
  $result = $objMessageBox::Show("Do you want to restart $computerName now or schedule it for later?", "Restart $computerName", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)
  
  switch ($result) {
    "Yes" {
      Restart-Computer -ComputerName $computerName -Force
      break
    }
    "No" {
      Write-Host "Restart of $computerName has been scheduled."
      break
    }
    "Cancel" {
      Write-Host "Restart of $computerName has been cancelled."
      break
    }
  }
}

$computers = Get-Content -Path "C:\computers.txt"
$program = "Microsoft Teams"

foreach ($computer in $computers) {
  Write-Host "Uninstalling $program on $computer..."
  Get-WmiObject -Class Win32_Product -Filter "Name='$program'" -ComputerName $computer |
    ForEach-Object { $_.Uninstall() }
  
  Show-RestartPrompt -computerName $computer
}
