$Dir = "\\awub-fs-3466p\ScriptOutput\History\LOGS\COMPUTER\"
$outDir = "\\awub-fs-3466p\ScriptOutput\History\LOGS\History_Output.csv"
$AllItems = Get-Childitem $Dir

$Loopnum = 0

#$List = Get-Content "\\AWUB-FS-3466P\ScriptOutput\History\LOGS\List.txt"

#$Allitems = $Allitems|Where-object {$list -contains ($_.name -replace ".txt","")}

Foreach ($item in $AllItems)
{
    $loopnum++
    Write-host $Loopnum
    $Content = Get-content "$($item.DirectoryName)\$($item.name)"
    IF ($Content -is [array]) {$Content[($Content.count - 1)]|out-file $outdir -Append -encoding default}
    ELSE {$Content|out-file $outdir -Append -encoding default}
}#End Foreach ($item in $Allitems)

