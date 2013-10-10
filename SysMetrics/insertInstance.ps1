function getSqlInstanceName($ComputerName)
{
	$SqlInstances = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceNameArray = New-Object System.Collections.ArrayList
    if ($SqlInstances -ne $null) {
        $SqlInstances | foreach {
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
$HostList = Invoke-Sqlcmd -ServerInstance "sql1" -Query "EXEC
Windows.Host_Select_HostID_HostName" -Database "SysMetrics"
$HostList | foreach {
    $HostID = $_.HostID
    Try {
        $SqlInstances = getSqlInstanceName($_.HostName) }
    Catch {
        Return }
    $SqlInstances | foreach {
        $InstanceName = $_.InstanceName
        if ($InstanceName -ne $null) {
            if ($_.Status -eq 'running') {
                $IsActive = "Y"}
            else {
                $IsActive = "N"}
            $sql = "EXEC Windows.Instance_Insert $HostID, '$InstanceName',
            '$IsActive'"
            Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database `
            "SysMetrics"
        }
    }
}
