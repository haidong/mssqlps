function getInstanceUserDb($ServerInstance)
{
    $UserDbList = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "select name
    from master.sys.databases where name not in ('master', 'model', 'msdb',
    'tempdb') and state_desc = 'online'"
    $UserDbList
}
function getDbDataIndexSizeInMB($ServerInstance, $DbName)
{
    $TableStatsQuery = @"
        SELECT
        --(row_number() over(order by a3.name, a2.name))%2 as l1,
        a3.name AS [schemaname],
        a2.name AS [tablename],
        a1.rows as row_count,
        CAST((a1.reserved + ISNULL(a4.reserved,0)) AS DECIMAL(18,4)) * 8/1024 AS reservedMB,
        CAST(a1.data AS DECIMAL(18,4)) * 8/1024 AS dataMB,
        (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN
         (CAST(a1.used AS DECIMAL(18,4)) + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8/1024 AS index_sizeMB,
        (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN
         (CAST(a1.reserved AS DECIMAL(18,4)) + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8/1024 AS unusedMB
            FROM
            (SELECT
             ps.object_id,
             SUM (
                 CASE
                 WHEN (ps.index_id < 2) THEN row_count
                 ELSE 0
                 END
                 ) AS [rows],
             SUM (ps.reserved_page_count) AS reserved,
             SUM (
                 CASE
                 WHEN (ps.index_id < 2) THEN
                 (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
                 ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
                 END
                 ) AS data,
             SUM (ps.used_page_count) AS used
             FROM $DbName.sys.dm_db_partition_stats ps
             GROUP BY ps.object_id) AS a1
            LEFT OUTER JOIN
            (SELECT
             it.parent_id,
             SUM(ps.reserved_page_count) AS reserved,
             SUM(ps.used_page_count) AS used
             FROM $DbName.sys.dm_db_partition_stats ps
             INNER JOIN $DbName.sys.internal_tables it ON (it.object_id = ps.object_id)
             WHERE it.internal_type IN (202,204)
             GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
            INNER JOIN $DbName.sys.all_objects a2 ON ( a1.object_id = a2.object_id )
            INNER JOIN $DbName.sys.schemas a3 ON (a2.schema_id = a3.schema_id)
            WHERE a2.type <> 'S' and a2.type <> 'IT'
            ORDER BY a3.name, a2.name
"@
    $TableStats = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $TableStatsQuery
    $dataIndexArray = New-Object System.Collections.ArrayList
    $TableStats | foreach {
         $myHashtable = @{schema = $_.schemaname; dataSizeInMB = $_.dataMB; indexSizeInMB = $_.index_sizeMB; tableName = $_.tableName; totalRowCount = $_.row_count}
    [void] $dataIndexArray.add($myHashtable)
            }
    $dataIndexArray
}
function storeDataIndexIntoJiMetrics($sql)
{
    $serverResults = Invoke-Sqlcmd -ServerInstance "sql1" -Database "JiMetrics" -Query $sql
    $serverResults | forEach {
        $ServerInstance, $ServerSID = $_.InstanceName, $_.InstanceID
        Try {
            $dbResults = getInstanceUserDb -ServerInstance $ServerInstance
        }
        Catch { Return }
        $dbResults | ForEach {
            $dbName = $_.name
            Try {
                $a = getDbDataIndexSizeInMB -ServerInstance $ServerInstance -DbName $dbName
            }
            Catch { Return }
            $a | ForEach {
                if ($_.Schema)
                    {
                    $SchemaName, $tableName, $TotalRowCount, $DataSizeInMB, $IndexSizeInMB = $_.Schema, $_.tableName, $_.TotalRowCount, $_.DataSizeInMB, $_.IndexSizeInMB
                    $sql = "EXEC Windows.TableStats_Insert $ServerSID, '$DbName', '$SchemaName', $tableName, $TotalRowCount, $DataSizeInMB, $IndexSizeInMB"
                    Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"
                    } } } } }


$sql = @"
Windows.Instance_Select_InstanceID_InstanceName
"@
storeDataIndexIntoJiMetrics -sql $sql

