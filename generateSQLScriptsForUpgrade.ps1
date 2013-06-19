param([parameter(Mandatory=$true)]$ServerInstance)
# *** Note: modify the line below so we can souce in baseFunctions.ps1
. "C:\Users\alex\Documents\GitHub\mssqlps\baseFunctions.ps1"
try {
$results = Invoke-Sqlcmd -Query "select @@servername" -ServerInstance $ServerInstance
}
catch {
"Check your spelling. You might have put in the wrong instance name or it is down: $ServerInstance"
exit
}

if ($results.column1.Contains("\")) {
    $ServerName, $InstanceName = $results.column1.split("\")
}
else {
    $ServerName, $InstanceName = $results.column1, "Default"}
$serverDate = Get-Date -format "yyyy_MM_dd"
# *** Note: modify the folder name below so scripts generated are saved in the
# right place
$savedScriptPath = "C:\users\Alex\Documents\work\"

#Step 1 Save SQL Server metadata: credentials, logins, linked servers, resource pools, server triggers, proxy accounts, job categories, and jobs
$fileName = $savedScriptPath + $ServerName + "_" + $InstanceName + "_configuration" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for SQL instance level objects"

# Generate script for Credentials since sqlps does not have a method for it!
$credentialQuery = @"
select
	'CREATE CREDENTIAL [' + name + '] WITH IDENTITY = ''' + credential_identity + ''', SECRET = ''<Put Password Here>'';' as cred
from
	sys.credentials 
order by name;
"@

$results = Invoke-Sqlcmd -Query $credentialQuery -ServerInstance `
$ServerInstance -SuppressProviderContextWarning
Add-Content $fileName "--Credentials"
$results | ForEach-Object {
	Add-Content $fileName $_.cred
}

Add-Content $fileName "--Logins"
cd SQLSERVER:\sql\$serverName\$InstanceName\Logins
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--LinkedServers"
cd SQLSERVER:\sql\$serverName\$InstanceName\LinkedServers
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ResourcePools"
cd SQLSERVER:\sql\$serverName\$InstanceName\ResourceGovernor\ResourcePools
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ServerTriggers"
cd SQLSERVER:\sql\$serverName\$InstanceName\Triggers
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ProxyAccounts"
cd SQLSERVER:\sql\$serverName\$InstanceName\JobServer\ProxyAccounts
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--JobCategories"
cd SQLSERVER:\sql\$serverName\$InstanceName\JobServer\JobCategories
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--Jobs"
cd SQLSERVER:\sql\$serverName\$InstanceName\JobServer\Jobs
get-childitem | %{$_.Script()} | Add-Content $fileName

"Successfully scripted metadata for instance $ServerInstance. It was saved in file $fileName"

# Get a list of user databases, then iterate through them one by oen for various scripts generation
$results = getInstanceUserDb -ServerInstance $ServerInstance

#Step 2 Generate DBCC CHECKDB command to make sure it is in a stable state before detaching
$fileName = $savedScriptPath + $serverName + "_" + $InstanceName + "_Step1_DBCC" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for checking all user databases integrity with DBCC on $ServerInstance"
$results | ForEach-Object {
	Add-Content $fileName ("--" + $_.name)
	Add-Content $fileName ("USE Master")
	Add-Content $fileName ("GO")
	Add-Content $fileName ("DBCC CHECKDB ([" + $_.name + "], NOINDEX) WITH PHYSICAL_ONLY, NO_INFOMSGS")
	Add-Content $fileName ("GO")
}
"Successfully generated DBCC CHECKDB script for instance $ServerInstance. It was saved in file $fileName"

#Step 3 Generate detach script
$fileName = $savedScriptPath + $serverName + "_" + $InstanceName + "_Step2_detach" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for detaching all user databases on $ServerInstance"
$results | ForEach-Object {
	Add-Content $fileName ("--" + $_.name)
	Add-Content $fileName ("USE Master")
	Add-Content $fileName ("GO")
	Add-Content $fileName ("EXEC sp_detach_db @dbname = N'" + $_.name + "'")
}
"Successfully generated detach script for instance $ServerInstance. It was saved in file $fileName"

#Step 4 Generate attach script, to be used after upgrade. It also changes db ownership to SA and set compatibility level to 110
$fileName = $savedScriptPath + $serverName + "_" + $InstanceName + "_Step3_attach" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for attaching all user databases on $ServerInstance"
$results | ForEach-Object {
	Add-Content $fileName ("--" + $_.name)
	Add-Content $fileName ("USE Master")
	Add-Content $fileName ("GO")
	Add-Content $fileName (generateAttachScript -ServerInstance $ServerInstance -DbName $_.name)
}
Add-Content $fileName ("--Change db owner to sa and set compatibility level to 110" + $_.name)
$results | ForEach-Object {
	Add-Content $fileName ("ALTER AUTHORIZATION ON DATABASE::[" + $_.name
    + "] TO SA")
	Add-Content $fileName ("ALTER DATABASE [" + $_.name + "] SET COMPATIBILITY_LEVEL = 110")
}

Add-Content $fileName ("--Reset certain customized database property values to its states prior to upgrade" + $_.name)
$dbPropertyQuery = @"
SELECT 'ALTER DATABASE [' + name + '] SET ANSI_NULLS '                       + CASE WHEN is_ansi_nulls_on = 1                          THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET ANSI_PADDING '                     + CASE WHEN is_ansi_padding_on = 1                        THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET ANSI_WARNINGS '                           + CASE WHEN is_ansi_warnings_on = 1                         THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET ARITHABORT '                       + CASE WHEN is_arithabort_on = 1                          THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET CONCAT_NULL_YIELDS_NULL '    + CASE WHEN is_concat_null_yields_null_on = 1 THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET DB_CHAINING '                      + CASE WHEN is_db_chaining_on = 1                          THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET QUOTED_IDENTIFIER '                + CASE WHEN is_quoted_identifier_on = 1              THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
SELECT 'ALTER DATABASE [' + name + '] SET READ_COMMITTED_SNAPSHOT  '   + CASE WHEN is_read_committed_snapshot_on = 1 THEN ' ON ' ELSE ' OFF ' END FROM sys.databases WHERE name NOT IN ('master', 'msdb', 'model', 'tempdb');
"@

$dbPropertyResults = Invoke-Sqlcmd -Query $dbPropertyQuery -ServerInstance `
$ServerInstance -SuppressProviderContextWarning
$dbPropertyResults | ForEach-Object {
	Add-Content $fileName $_.Column1
}
"Successfully generated attach script for instance $ServerInstance. It was saved in file $fileName"

#Step 5 Generate update stats scripts for use after upgrade is complete.
$fileName = $savedScriptPath + $serverName + "_" + $InstanceName + "_Step4_UpdateStats" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for updating database stats after upgrade is complete"
$results | ForEach-Object {
	Add-Content $fileName ("USE [" + $_.name + "]")
	Add-Content $fileName ("GO")
	Add-Content $fileName ("EXEC sp_updatestats")
	Add-Content $fileName ("GO")
}
"Successfully generated stats update script for instance $ServerInstance. It was saved in file $fileName"

C:
