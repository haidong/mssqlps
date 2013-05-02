function getSqlInstanceName($ComputerName)
{
	$a = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceNameArray = New-Object System.Collections.ArrayList
    if ($a -ne $null) {
        $a | foreach {
            if ($_.Name -eq 'mssqlserver') {
                [void]
                $instanceNameArray.add(@{InstanceName=$ComputerName;Status=$_.Status})
            }
            else {
                [void]
                $instanceNameArray.add(@{InstanceName=$ComputerName + "\" +
                $_.Name.split("$")[1];Status=$_.Status})
            }
        }
    }
    $instanceNameArray
}
$a = Invoke-Sqlcmd -ServerInstance "sql1" -Query "EXEC
Windows.Host_Select_HostID_HostName" -Database "DBAMetrics"
$a | foreach {
    $HostID = $_.HostID
    Try {
        $b = getSqlInstanceName($_.HostName) }
    Catch {
        continue }
    $b | foreach {
        $InstanceName = $_.InstanceName
        if ($InstanceName -ne $null) {
            if ($_.Status -eq 'running') {
                $IsActive = "Y"}
            else {
                $IsActive = "N"}
            $sql = "EXEC Windows.Instance_Insert $HostID, '$InstanceName',
            '$IsActive'"
            Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database `
            "DBAMetrics"
        }
    }
}
