function getSqlInstanceName($ComputerName)
{
	$a = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceNameArray = New-Object System.Collections.ArrayList
	$a | foreach {
        if ($_.Name -eq 'mssqlserver') {
            [void] $instanceNameArray.add($ComputerName)
        }
        else {
            [void] $instanceNameArray.add($ComputerName + "\" +
            $_.Name.split("$")[1])
        }
    }
    $instanceNameArray
}
$a = Invoke-Sqlcmd -ServerInstance "sql1" -Query "EXEC
Windows.Host_Select_HostID_HostName" -Database "DBAMetrics"
$a | foreach {
    $HostID = $_.HostID
    $b = getSqlInstanceName($_.HostName)
    $b | foreach {
        $InstanceName = $_
        $sql = "EXEC Windows.Instance_Insert $HostID, '$InstanceName'"
        Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database `
        "DBAMetrics"
    }
}
