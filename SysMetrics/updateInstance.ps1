$a = Invoke-Sqlcmd -Query "exec Windows.Instance_Select_InstanceID_InstanceName" -ServerInstance "sql1" -Database "SysMetrics"
$a | ForEach-Object {

    $InstanceName = $_.InstanceName
    $InstanceID = $_.InstanceID

        Try {
           $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('Edition')"
           $InstanceEdition = $result.column1
           $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT
           SERVERPROPERTY('EditionID')"
           $InstanceEditionID = $result.column1
           $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('ProductVersion')"
           $InstanceVersion = $result.column1
           $result = Invoke-Sqlcmd -ServerInstance $InstanceName -Query "SELECT SERVERPROPERTY('ProductLevel')"
           $InstanceServicePack = $result.column1

           $sql = "EXEC Windows.Instance_Update $InstanceID,
           '$InstanceEdition', '$InstanceEditionID', '$InstanceVersion', '$InstanceServicePack'"
           Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "SysMetrics"
        }
    Catch { Return }
}
