function getInstanceDmvPerfCounter($ServerInstance)
{
    $InstanceDmvPerfCounterQuery = @"
select object_name
       , counter_name
       , instance_name
       , cntr_value
       , cntr_type
from sys.dm_os_performance_counters
where [counter_name] IN ( N'Page life expectancy'
                          , N'Lazy writes/sec'
                          , N'Page reads/sec'
                          , N'Page writes/sec'
                          , N'Free Pages'
                          , N'Free list stalls/sec'
                          , N'User Connections'
                          , N'Lock Waits/sec'
                          , N'Number of Deadlocks/sec'
                          , N'Transactions/sec'
                          , N'Forwarded Records/sec'
                          , N'Index Searches/sec'
                          , N'Full Scans/sec'
                          , N'Batch Requests/sec'
                          , N'SQL Compilations/sec'
                          , N'SQL Re-Compilations/sec'
                          , N'Total Server Memory (KB)'
                          , N'Target Server Memory (KB)'
                          , N'Latch Waits/sec' )
"@
    try {
    $InstanceConfigList = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $InstanceDmvPerfCounterQuery -Database "master"
    }
    catch {}
    $dataIndexArray = New-Object System.Collections.ArrayList
    $InstanceConfigList | foreach {
        $myHashtable = @{object_name = $_.object_name;  counter_name =
        $_.counter_name; instance_name = $_.instance_name; cntr_value =
        $_.cntr_value; cntr_type = $_.cntr_type}
        [void] $dataIndexArray.add($myHashtable)
    }
    $dataIndexArray
}

$InstanceList = Invoke-Sqlcmd -Query "exec Windows.Instance_Select_InstanceID_InstanceName" -ServerInstance "sql1" -Database "JiMetrics"
$InstanceList | ForEach-Object {

    $InstanceName = $_.InstanceName
    $InstanceID = $_.InstanceID

        Try {
           $InstanceDmvPerfCounterArray = getInstanceDmvPerfCounter($InstanceName)
           $InstanceDmvPerfCounterArray | ForEach-Object {
               $object_name, $counter_name, $instance_name, $cntr_value,
               $cntr_type = $_.object_name, $_.counter_name, $_.instance_name,
               $_.cntr_value, $_.cntr_type

               $sql = "EXEC Windows.InstanceDmvPerfCounter_Insert $InstanceID, '$object_name',
               '$counter_name', '$instance_name', $cntr_value, $cntr_type"
                Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"
           }
        }
    Catch { Return }
}
