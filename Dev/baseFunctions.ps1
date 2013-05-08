#Base Functions for SQL Server administration

#Due to errors with AD that I don't quite understand yet, Get-ADUser can spit
#out ADIdentityNotFoundException. Setting $ErrorActionPreference to
#"SilentlyContinue" solved it.
$ErrorActionPreference = "SilentlyContinue"
Import-Module sqlps -DisableNameChecking
Import-Module ActiveDirectory
function getInstanceVersion($ServerInstance)
{
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "SELECT SERVERPROPERTY('ProductVersion')"
	$results.column1
}
function getInstanceUserDb($ServerInstance)
{
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query "select name from master.sys.databases where name not in ('master', 'model', 'msdb',
    'tempdb')" -SuppressProviderContextWarning
	$results
}
function getUserDbDatafile($ServerInstance, $DbName)
{
	$Query = "select physical_name from $DbName.sys.database_files where type <> 1 order by file_id"
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $Query `
    -SuppressProviderContextWarning
	$results
}
function getUserDbLogfile($ServerInstance, $DbName)
{
	$Query = "select physical_name from $DbName.sys.database_files where type = 1 order by file_id"
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $Query `
    -SuppressProviderContextWarning
	$results
}
function generateAttachScript($ServerInstance, $DbName)
{
	$attachScript = "CREATE DATABASE $DbName ON
	"
	# First we get non-log files
	$results = getUserDbDatafile -ServerInstance $ServerInstance -DbName $DbName
	$results | foreach {
		$a = $_.physical_name
		$attachScript = $attachScript + "(FILENAME = '$a'),
	"
	}
	# Then we get log files. Note that the last file for attachment has no comma at the end so we will have to treat the last file separately. In most cases there is only one log file, but we also need to take care of the fact that there could be more than 1 log files. Hence the array length check and then the somewhat funky $results[0..($results.length) -2] and $results[-1] stuff if there are more than 1 log file.
	$results = getUserDbLogfile -ServerInstance $ServerInstance -DbName $DbName
	if ($results.length -gt 1) {
		$results[0..($results.length -2)] | foreach {
			$a = $_.physical_name
			$attachScript = $attachScript + "(FILENAME = '$a'),
	"
		}
		$a = $results[-1].physical_name
		$attachScript = $attachScript + "(FILENAME = '$a')
FOR ATTACH
"}
	else {
		$a = $results.physical_name
		$attachScript = $attachScript + "(FILENAME = '$a')
FOR ATTACH
"}
	$attachScript
}
function getDbDataIndexSizeInGB($ServerInstance, $DbName)
{
	$Query = @"
SELECT
 --(row_number() over(order by a3.name, a2.name))%2 as l1,
 a3.name AS [schemaname],
 count(a2.name ) as NumberOftables,
 sum(a1.rows) as row_count,
 sum((a1.reserved + ISNULL(a4.reserved,0))* 8)/1024/1024 AS reservedGB,
 sum(a1.data * 8)/1024/1024 AS dataGB,
 sum((CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN
   (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 )/1024/1024 AS index_sizeGB,
 sum((CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN
   (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8)/1024/1024 AS unusedGB
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
INNER JOIN $DbName.sys.all_objects a2  ON ( a1.object_id = a2.object_id )
INNER JOIN $DbName.sys.schemas a3 ON (a2.schema_id = a3.schema_id)
WHERE a2.type <> 'S' and a2.type <> 'IT'
group by a3.name
ORDER BY a3.name
"@
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $Query
	$dataIndexArray = New-Object System.Collections.ArrayList
	$results | foreach {
		$myHashtable = @{schema = $_.schemaname; dataSizeInGB = $_.dataGB; indexSizeInGB = $_.index_sizeGB; numberOfTables = $_.NumberOfTables; totalRowCount = $_.row_count}
		[void] $dataIndexArray.add($myHashtable)
	}
	$dataIndexArray
}
#Although the function parameter is called $SID, in reality one can pass in
#other from of unique identifier as well, such as its name.
function getADUserInfo($SID)
{
    $a = Get-ADUser $SID -Properties GivenName,Surname,OfficePhone,Mail
    $userHashTable = @{FullName = $a.GivenName + ' ' + $a.Surname;
    OfficePhone = $a.OfficePhone; EMail = $a.Mail; UserPrincipalName =`
    $a.UserPrincipalName }
    $userHashTable
}
function getGroupMember($GroupName)
{
	$results = Get-ADGroupMember -Identity $GroupName -recursive | where {
        $_.objectClass -eq 'user'}
    $userArray = New-Object System.Collections.ArrayList
    $results | foreach {
        $a = getADUserInfo $_.SID 
        [void] $userArray.add($a)
    }
    $userArray | sort { $_.UserPrincipalName } -uniq
}
function getADUserWithSqlSaPermission($ServerInstance)
{
    #Let's get individual Windows login first. Then we'll get Windows group
    #members
    $sql = @"
    SELECT name FROM Master.sys.server_principals
    WHERE is_disabled = 0 AND type = 'u' AND IS_SRVROLEMEMBER('sysadmin',
    name) = 1 AND name NOT LIKE 'NT service%'
"@
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $sql
    $userArray = New-Object System.Collections.ArrayList
	$results | foreach {
        $userName = $_.name.split("\")[1]
        $a = getADUserInfo $userName
        [void] $userArray.add($a)
    }
    #Let's now get AD users that belong to a AD group
    $sql = @"
    SELECT name FROM Master.sys.server_principals
    WHERE is_disabled = 0 AND type = 'g' AND IS_SRVROLEMEMBER('sysadmin',
    name) = 1
"@
	$results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $sql
	$results | foreach {
        $groupName = $_.name.split("\")[1]
        $a = getGroupMember $groupName
        $userArray = $userArray + $a
    }
    $userArray | sort { $_.UserPrincipalName } -uniq
}
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
