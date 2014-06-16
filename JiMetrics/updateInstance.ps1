function updateInstanceSQL($i) {
    $InstanceName = $i.InstanceName
    $InstanceID = $i.InstanceID
	
    $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('Edition')"
    $InstanceEdition = $result.column1
    $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('EditionID')"
    $InstanceEditionID = $result.column1
    $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('ProductVersion')"
    $InstanceVersion = $result.column1
    $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('ProductLevel')"
    $InstanceServicePack = $result.column1
	
	if ($InstanceName.Contains("\")) {
		$serviceName = "mssql`$" + $InstanceName.split("\")[1]
		$service = Get-WmiObject win32_service -ComputerName $InstanceName.split("\")[0] | where {$_.Name -eq $serviceName}}
	else {
		$serviceName = "mssqlserver"
		$service = Get-WmiObject win32_service -ComputerName $InstanceName | where {$_.Name -eq $serviceName}}

	$StartupAcct = $service.StartName
    $sql = "EXEC Windows.Instance_Update $InstanceID, '$InstanceEdition', '$InstanceEditionID', '$InstanceVersion', '$InstanceServicePack', '$StartupAcct'"
	return $sql}

$InstanceList = Invoke-Sqlcmd -Query "exec Windows.Instance_Select_InstanceID_InstanceName" -ServerInstance "sql1" -Database "JiMetrics"
$InstanceList | ForEach-Object {
     try {
		 $sql = updateInstanceSQL($_)
		 Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"}
	 Catch [Exception] {Continue}}
