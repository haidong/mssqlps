$HostList = Invoke-Sqlcmd -Query "EXEC Windows.Host_Select_HostID_HostName" -ServerInstance "sql1" -Database "SysMetrics"
$HostList | ForEach-Object {
    $HostName = $_.HostName
    $HostID = $_.HostID
#Note: DriveType 5 is CD/DVD, DriveType 2 is removable disk therefore we don't care. We only care about LocalDisk, which is DriveType 3
    try {
            $WmiResults = get-wmiobject -computername $hostName Win32_volume | where { $_.DriveType -eq 3}
        }
    catch [Exception] {
        continue
    }
    $WmiResults | foreach {
        $DiskPath = $_.Name
        if (-not ($DiskPath.StartsWith("\\"))) {
            $DiskSizegB = ($_.Capacity / 1gb) + 1
            $DiskFreeGB = ($_.FreeSpace / 1gb) + 1
            $DiskFormat, $DiskLabel = $_.FileSystem, $_.Label
            $sql = "EXEC Windows.Storage_Insert $HostID, '$DiskPath', '$DiskFormat', '$DiskLabel', $DiskSizeGB, $DiskFreeGB"
            Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "SysMetrics"
    }}}
