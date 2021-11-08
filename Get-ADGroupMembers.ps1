$OUstring = ",ou=Barksdale afb security groups,ou=barksdale afb,ou=afconuswest,ou=bases,dc=area52,dc=afnoapps,dc=usaf,dc=mil"
$GroupName = Read-host -Prompt "Please enter group name"
#$GroupName = "GLS_Barksdale AFB_SDC Servicing script (Mandatory)"
$Members = Get-ADGroupMember -Identity "CN=$GroupName$OUString"

Write-host "Count`: $($Members.count)"
$Members|ConvertTo-Csv -NoTypeInformation|Out-file -FilePath "$PSScriptRoot\GroupMembers.csv" -Encoding default
