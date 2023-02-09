<#
By: Daryn Roberts
Date: 2/8/2023 
Purpose: To identify Checkpoint FDE decrypted machines, remove the Endpoint Security client, and replace disk encryption method with AES-256 bit BitLocker Disk Encryption
#>

# Defining the list of computers using a text file
$computerList = get-content -path "c:\WHEREEVERIDECIDE\computers.txt"

# Here script will loop through each computer in text file
foreach ($computer in $computerList) {
  # Initializes the TPM module on the current computer
  Write-Host "Initializing TPM on $computer"
  Initialize-Tpm -ComputerName $computer

  # Uninstalls the Check Point Endpoint Security if it's installed on local machine
  Write-Host "Checking for Check Point Endpoint Security on $computer"
  $checkPointInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Check Point Endpoint Security" }

    if ($checkPointInstalled) {
    Write-Host "Uninstalling Check Point Endpoint Security from $computer"
    $checkPointInstalled.Uninstall()
  }

  # Enables BitLocker on the current computer
  Write-Host "Enabling BitLocker on $computer"
  Enable-BitLocker -MountPoint C: -EncryptionMethod Aes256 -UsedSpaceOnly -Skiphardwaretest -RecoveryPasswordProtector
}

# Output success message
Write-Host "BitLocker Successfully Enabled!"
