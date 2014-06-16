function getSqlInstanceName($ComputerName) {
    $SqlInstances = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceArray = @()
    if ($SqlInstances -ne $null) {
        $SqlInstances | foreach {
			$sqlName = $_.Name
			$service = Get-WmiObject win32_service -ComputerName $ComputerName | where {$_.Name -eq $sqlName}
            if ($sqlName -eq 'mssqlserver') {
                $instanceArray = $instanceArray + @(@{InstanceName=$ComputerName; StartupAcct=$service.StartName; Status=$_.Status})}
            else {
                $instanceArray = $instanceArray + @(@{InstanceName=$ComputerName + "\" +
								$sqlName.split("$")[1];StartupAcct=$service.StartName; Status=$_.Status})}}}
    return $instanceArray}

function insertInstanceSQL($i, $HostID) {
    $InstanceName = $i.InstanceName
    $StartupAcct = $i.StartupAcct
    if ($InstanceName -ne $null) {
        if ($i.Status -eq 'running') {
            $IsActive = "Y"}
        else {$IsActive = "N"}
        $sql = "EXEC Windows.Instance_Insert $HostID, '$InstanceName', '$StartupAcct', '$IsActive'"
	return $sql}}

$HostList = Invoke-Sqlcmd -ServerInstance "sql1" -Query "EXEC
Windows.Host_Select_HostID_HostName" -Database "JiMetrics"
$HostList | foreach {
    $HostID = $_.HostID
    Try {$SqlInstances = getSqlInstanceName($_.HostName)}
    Catch {Return}
    $SqlInstances | foreach {
		$sql = insertInstanceSQL $_ $HostID
        Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"}}