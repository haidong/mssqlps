function getSqlInstanceName($ComputerName) {
    $SqlInstances = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceArray = @()
    if ($SqlInstances -ne $null) {
        $SqlInstances | foreach {
            if ($_.Name -eq 'mssqlserver') {
                $instanceArray = $instanceArray + @(@{InstanceName=$ComputerName;Status=$_.Status})}
            else {
                $instanceArray = $instanceArray + @(@{InstanceName=$ComputerName + "\" +
								$_.Name.split("$")[1];Status=$_.Status})}}}
    return $instanceArray}

function insertInstanceSQL($i, $HostID) {
    $InstanceName = $i.InstanceName
    if ($InstanceName -ne $null) {
        if ($i.Status -eq 'running') {
            $IsActive = "Y"}
        else {$IsActive = "N"}
        $sql = "EXEC Windows.Instance_Insert $HostID, '$InstanceName', '$IsActive'"
	return $sql}}