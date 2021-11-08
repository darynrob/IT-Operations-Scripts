$computer = Read-Host "Remote computer to remove profiles from:"
$maxage = (get-date).Addmonths(-$(Read-Host "Remove profiles not used for X months: X="))

$folders = get-childitem "\\$computer\C$\users"-depth 0
foreach($folder in $folders){
    $folderlw = ($folder).LastWriteTime
    if($folder -notlike "*admin*"){
     if($folder -notlike "*public*"){
      if($folder -notlike "*default*"){
       if($folder -notlike "*backup*"){
        if($folder -notlike "*svc*"){
         if($folder -notlike "*USAF*"){
         if($folderlw -lt $maxage){
          write-host $folder -ForegroundColor DarkYellow
          $ProfileInfo = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath -eq "c:\users\$folder" }
          write-host $ProfileInfo -ForegroundColor DarkYellow
          Foreach($RemoveProfile in $ProfileInfo)
		{

			Try{
            Write-Host "Removing Profile"
            $RemoveProfile.Delete()
            Write-Host -ForegroundColor DarkGreen "Deleted profile '$($RemoveProfile.LocalPath)' successfully."
            #Write-Host "Removing Local Files"
			#Remove-Item $RemoveProfile.LocalPath -Recurse -Force
                }
            Catch{Write-Host "Delete profile failed." -ForegroundColor Red}
                   
        }

        	Try{
            Write-Host "Removing Local Files"
			Remove-Item "\\$computer\C$\users\$folder" -Recurse
                }
            Catch{Write-Host "Folder Already deleted." -ForegroundColor DarkYellow}

            }}}}}}}}