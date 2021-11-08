
[CmdletBinding()]
param(
	[Parameter(Position=0,ValueFromPipeline=$true)]
	[Alias("CN","Computer")]
	[String[]]$ComputerName="$env:AWUBW-291XWF",
	[String]$FilterSID,
	[String]$WQLFilter="NOT SID = 'S-1-5-18' AND NOT SID = 'S-1-5-19' AND NOT SID = 'S-1-5-20'"
	)

Begin
	{
		#Adjusting ErrorActionPreference to stop on all errors
		$TempErrAct = $ErrorActionPreference
		$ErrorActionPreference = "Stop"
		#Exclude Local System, Local Service & Network Service
	}#End Begin Script Block

Process
	{
		Foreach ($Computer in $ComputerName)
			{
				$Computer = $Computer.ToUpper().Trim()
				Try
					{
						#Querying Windows version to determine how to proceed.
						$Win32OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
						$Build = $Win32OS.BuildNumber
						
						#Win32_UserProfile exist on Windows Vista and above
						If ($Build -ge 6001)
							{
								If ($FilterSID)
									{
										$WQLFilter = $WQLFilter + " AND NOT SID = `'$FilterSID`'"
									}#End If ($FilterSID)
								$Win32User = Get-WmiObject -Class Win32_UserProfile -Filter $WQLFilter -ComputerName $Computer
								$LastUser = $Win32User | Sort-Object -Property LastUseTime -Descending | Select-Object -First 1
								$Loaded = $LastUser.Loaded
								$Script:Time = ([WMI]'').ConvertToDateTime($LastUser.LastUseTime)
								
								#Convert SID to Account for friendly display
								$Script:UserSID = New-Object System.Security.Principal.SecurityIdentifier($LastUser.SID)
								$User = $Script:UserSID.Translate([System.Security.Principal.NTAccount])
							}#End If ($Build -ge 6001)
							
						If ($Build -le 6000)
							{
								If ($Build -eq 2195)
									{
										$SysDrv = $Win32OS.SystemDirectory.ToCharArray()[0] + ":"
									}#End If ($Build -eq 2195)
								Else
									{
										$SysDrv = $Win32OS.SystemDrive
									}#End Else
								$SysDrv = $SysDrv.Replace(":","$")
								$Script:ProfLoc = "\\$Computer\$SysDrv\Documents and Settings"
								$Profiles = Get-ChildItem -Path $Script:ProfLoc
								$Script:NTUserDatLog = $Profiles | ForEach-Object -Process {$_.GetFiles("ntuser.dat.LOG")}
								
								#Function to grab last profile data, used for allowing -FilterSID to function properly.
								function GetLastProfData ($InstanceNumber)
									{
										$Script:LastProf = ($Script:NTUserDatLog | Sort-Object -Property LastWriteTime -Descending)[$InstanceNumber]							
										$Script:UserName = $Script:LastProf.DirectoryName.Replace("$Script:ProfLoc","").Trim("\").ToUpper()
										$Script:Time = $Script:LastProf.LastAccessTime
										
										#Getting the SID of the user from the file ACE to compare
										$Script:Sddl = $Script:LastProf.GetAccessControl().Sddl
										$Script:Sddl = $Script:Sddl.split("(") | Select-String -Pattern "[0-9]\)$" | Select-Object -First 1
										#Formatting SID, assuming the 6th entry will be the users SID.
										$Script:Sddl = $Script:Sddl.ToString().Split(";")[5].Trim(")")
										
										#Convert Account to SID to detect if profile is loaded via the remote registry
										$Script:TranSID = New-Object System.Security.Principal.NTAccount($Script:UserName)
										$Script:UserSID = $Script:TranSID.Translate([System.Security.Principal.SecurityIdentifier])
									}#End function GetLastProfData
								GetLastProfData -InstanceNumber 0
								
								#If the FilterSID equals the UserSID, rerun GetLastProfData and select the next instance
								If ($Script:UserSID -eq $FilterSID)
									{
										GetLastProfData -InstanceNumber 1
									}#End If ($Script:UserSID -eq $FilterSID)
								
								#If the detected SID via Sddl matches the UserSID, then connect to the registry to detect currently loggedon.
								If ($Script:Sddl -eq $Script:UserSID)
									{
										$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"Users",$Computer)
										$Loaded = $Reg.GetSubKeyNames() -contains $Script:UserSID.Value
										#Convert SID to Account for friendly display
										$Script:UserSID = New-Object System.Security.Principal.SecurityIdentifier($Script:UserSID)
										$User = $Script:UserSID.Translate([System.Security.Principal.NTAccount])
									}#End If ($Script:Sddl -eq $Script:UserSID)
								Else
									{
										$User = $Script:UserName
										$Loaded = "Unknown"
									}#End Else

							}#End If ($Build -le 6000)
						
						#Creating Custom PSObject For Output
						New-Object -TypeName PSObject -Property @{
							Computer=$Computer
							User=$User
							SID=$Script:UserSID
							Time=$Script:Time
							CurrentlyLoggedOn=$Loaded
							} | Select-Object Computer, User, SID, Time, CurrentlyLoggedOn
							
					}#End Try
					
				Catch
					{
						If ($_.Exception.Message -Like "*Some or all identity references could not be translated*")
							{
								Write-Warning "Unable to Translate $Script:UserSID, try filtering the SID `nby using the -FilterSID parameter."	
								Write-Warning "It may be that $Script:UserSID is local to $Computer, Unable to translate remote SID"
							}
						Else
							{
								Write-Warning $_
							}
					}#End Catch
					
			}#End Foreach ($Computer in $ComputerName)
			
	}#End Process
	
End
	{
		#Resetting ErrorActionPref
		$ErrorActionPreference = $TempErrAct
	}#End End

}# End Function Get-LastLogon

#$CompList = get-content "\\awub-fs-3466p\2CS\SCOO\6. Scripts\3. PS\Input Docs\input.txt"
#$Loop = 0
#$Total = $Complist.count
#ForEach ($Comp in $Complist)
#{
#$Loop++
#$Out = Get-LastLogon -ComputerName $Comp
#Write-host "$($out.Computer) completed"
#Write-host "$Loop of $Total complete"
#$Out|Convertto-csv|out-file "\\awub-fs-3466p\2CS\SCOO\6. Scripts\3. PS\Output\Output.csv" -append -encoding default
#}
