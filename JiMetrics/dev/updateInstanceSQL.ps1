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

    $sql = "EXEC Windows.Instance_Update $InstanceID, '$InstanceEdition', '$InstanceEditionID', '$InstanceVersion', '$InstanceServicePack'"
	return $sql
}