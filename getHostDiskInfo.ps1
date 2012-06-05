#ADD-PSSNAPIN SqlServerProviderSnapin100
#ADD-PSSNAPIN SqlServerCmdletSnapin100
$a = Invoke-Sqlcmd -Query "exec metrics.SelectHostSID_Name_WMIError" -ServerInstance "vhacdwm01" -Database "Dbametrics"
$a | ForEach-Object {
    $hostName = $_.hostname
    $hostSID = $_.hostSID
    if ($_.WMIError.ToUpper() -eq 'Y') {
    Invoke-Expression "psinfo \\$hostName -d volume" | foreach {
        if ($_ -imatch '\s+([A-Z]):\sFixed\s+(\w+)\s+(.*?)(\d+\.\d+\s\w\w)\s+(\d+\.\d+\s\w\w)\s+(\d+\.\d+%).*$') {
            $driveLetter, $diskFormat, $diskLabel, $diskTotalSize, $diskAvailableSize = $matches[1].trim(), $matches[2].trim(), $matches[3].trim(), $matches[4].trim(), $matches[5].trim()
	    if ($diskTotalSize.Endswith("MB")) { $diskTotalSize =1 }
	    else {$diskTotalSize = $diskTotalSize.replace('GB', '')}
	    if ($diskAvailableSize.Endswith("MB")) { $diskAvailableSize =1 }
	    else {$diskAvailableSize = $diskAvailableSize.replace('GB', '')}
            $sql = "EXEC Metrics.InsertWindowsHostDiskInfo $hostSID, '$driveLetter', '$diskFormat', '$diskLabel', $diskTotalSize, $diskAvailableSize"
            Invoke-Sqlcmd -Query $sql -ServerInstance "vhacdwm01" -Database "DBAMetrics" } } }
    else {
#Note: DriveType 5 is CD/DVD, DriveType 2 is removable disk therefore we don't care. We only care about LocalDisk, which is DriveType 3
get-wmiobject -computername $hostName Win32_volume | where { $_.DriveType -eq 3} | foreach {
	    $diskTotalSize = $_.Capacity / 1gb
	    $diskAvailableSize =  $_.FreeSpace / 1gb
            $driveLetter, $diskFormat, $diskLabel = $_.Name.substring(0,1), $_.FileSystem, $_.Label
            $sql = "EXEC Metrics.InsertWindowsHostDiskInfo $hostSID, '$driveLetter', '$diskFormat', '$diskLabel', $diskTotalSize, $diskAvailableSize"
	    Invoke-Sqlcmd -Query $sql -ServerInstance "vhacdwm01" -Database "DBAMetrics"
	} } }

