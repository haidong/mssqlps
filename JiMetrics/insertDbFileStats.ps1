function getInstanceUserDb($ServerInstance)
{
    $UserDbList = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "select name
        from master.sys.databases where name not in ('master', 'model', 'msdb',
                'tempdb') and state_desc = 'online'"
    $UserDbList
}
function getDbFileInfo($ServerInstance, $DbName)
{
    $DbFileQuery = @"
        select
        a.name as FileLogicalName
        , a.filename as FilePhysicalName
        , c.name as FileGroupName
        , a.size/128 as FileSizeInMB
        , (a.size-fileproperty(a.name,'SpaceUsed'))/128 as FreeSizeInMB
        , b.max_size
        , b.growth
        , case b.is_percent_growth
        when 1 then 'Y'
        else 'N' end as is_percent_growth
            from [$DbName].sys.sysfiles a inner join [$DbName].sys.database_files b on a.fileid = b.file_id
                left outer join [$DbName].sys.filegroups c on a.groupid = c.data_space_id
"@
    try {
    $DbFileList = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $DbFileQuery -Database $DbName
    }
    catch {}
    $dataIndexArray = New-Object System.Collections.ArrayList
    $DbFileList | foreach {
        $myHashtable = @{FileLogicalName = $_.FileLogicalName; FilePhysicalName = $_.FilePhysicalName; FileGroupName = $_.FileGroupName; FileSizeInMB = $_.FileSizeInMB; FreeSizeInMB = $_.FreeSizeInMB; max_size = $_.max_size; growth = $_.growth; is_percent_growth = $_.is_percent_growth}
        [void] $dataIndexArray.add($myHashtable)
    }
    $dataIndexArray
}
function storeDbFileInfo($sql)
{
    $serverResults = Invoke-Sqlcmd -ServerInstance "sql1" -Database "JiMetrics" -Query $sql
    $serverResults | forEach {
    $InstanceName, $InstanceID = $_.InstanceName, $_.InstanceID
    Try {
        $dbResults = getInstanceUserDb -ServerInstance $InstanceName
    }
    Catch { Return }
    $dbResults | ForEach {
        $dbName = $_.name
        Try {
            $a = getDbFileInfo -ServerInstance $InstanceName -DbName $dbName
        }
        Catch { Return }
        $a | ForEach {
            if ($_.FileLogicalName)
            {
                $FileLogicalName, $FilePhysicalName, $FileGroupName, $FileSizeInMB, $FreeSizeInMB, $max_size, $growth, $is_percent_growth = $_.FileLogicalName, $_.FilePhysicalName, $_.FileGroupName, $_.FileSizeInMB, $_.FreeSizeInMB, $_.max_size, $_.growth, $_.is_percent_growth
                $sql = "EXEC Windows.DbFileStats_Insert $InstanceID, '$DbName', '$FileLogicalName', '$FilePhysicalName', '$FileGroupName', $FileSizeInMB, $FreeSizeInMB, $max_size, $growth, '$is_percent_growth'"
                Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "JiMetrics"
            } } } } }


$sql = @"
Windows.Instance_Select_InstanceID_InstanceName
"@
storeDbFileInfo -sql $sql
