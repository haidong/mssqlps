function getInstanceConfig($ServerInstance) {
    $InstanceConfigQuery = @"
       SELECT  [configuration_id]
                , [name]
                , [value]
                , [value_in_use]
        FROM    [sys].[configurations];
"@
    try {
    $InstanceConfigList = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $InstanceConfigQuery -Database "master"
    }
    catch {}
    $dataIndexArray = New-Object System.Collections.ArrayList
    $InstanceConfigList | foreach {
        $myHashtable = @{Configuration_Id = $_.configuration_id;  Name =
        $_.name; Value = $_.value; ValueInUse = $_.value_in_use}
        [void] $dataIndexArray.add($myHashtable)}
    $dataIndexArray}

function insertInstanceConfigSQL($instanceConfig, $instanceID) {
	$ConfigurationId, $Name, $Value, $ValueInUse =
        $instanceConfig.Configuration_Id, $instanceConfig.Name, $instanceConfig.Value, $instanceConfig.ValueInUse
	$sql = "EXEC Windows.InstanceConfig_Insert $InstanceID, $ConfigurationId, '$Name', '$Value', '$ValueInUse'"
    return $sql}

$InstanceList = Invoke-Sqlcmd -Query "exec Windows.Instance_Select_InstanceID_InstanceName" -ServerInstance "sql1" -Database "JiMetrics"
$InstanceList | ForEach-Object {

    $InstanceName = $_.InstanceName
    $InstanceID = $_.InstanceID

    Try {
           $InstanceConfigArray = getInstanceConfig($InstanceName)
           $InstanceConfigArray | ForEach-Object {
               $sql = insertInstanceConfigSQL $_ $InstanceID
               Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"}}
    Catch [Exception] { Continue }}