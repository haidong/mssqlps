$a = Invoke-Sqlcmd -Query "EXEC Windows.Host_Select_HostID_HostName" -ServerInstance "sql1" -Database "SysMetrics"
$a | ForEach-Object {
    $HostName = $_.HostName
    $HostID = $_.HostID
#Note: DriveType 5 is CD/DVD, DriveType 2 is removable disk therefore we don't care. We only care about LocalDisk, which is DriveType 3
    try {
            $b = get-wmiobject -computername $hostName Win32_volume | where { $_.DriveType -eq 3}
        }
    catch [Exception] {
        continue
    }
    $b | foreach {
        $DiskSizegB = ($_.Capacity / 1gb) + 1
        $DiskFreeGB = ($_.FreeSpace / 1gb) + 1
        $DiskPath, $DiskFormat, $DiskLabel = $_.Name, $_.FileSystem, $_.Label
        $sql = "EXEC Windows.Storage_Insert $HostID, '$DiskPath', '$DiskFormat', '$DiskLabel', $DiskSizeGB, $DiskFreeGB"
        Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "SysMetrics"
    }
} 
