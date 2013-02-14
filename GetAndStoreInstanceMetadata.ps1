param([parameter(Mandatory=$true)]$ServerInstance)
import-module sqlps
Function getAndStoreInstanceMetadata($ServerInstance)
{
try {
$results = Invoke-Sqlcmd -Query "select @@servername" -SuppressProviderContextWarning -ServerInstance $ServerInstance
}
catch {
"Check your spelling. You might have put in the wrong instance name or it is down: $ServerInstance"
exit
}
$serverName = $results.column1.replace('\', '_')
$serverDate = Get-Date -format "yyyy_MM_dd"
$fileName = "X:\ProperPathName\" + $serverName + "_configuration" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for SQL instance level objects"

# Generate script for Credentials since sqlps does not have a method for it!
$credentialQuery = @"
select
	'CREATE CREDENTIAL [' + name + '] WITH IDENTITY = ''' + credential_identity + ''', SECRET = ''<Put Password Here>'';' as cred
from
	sys.credentials 
order by name;
"@

$results = Invoke-Sqlcmd -Query $credentialQuery -ServerInstance $serverName -SuppressProviderContextWarning
Add-Content $fileName "--Credentials"
$results | ForEach-Object {
	Add-Content $fileName $_.cred
}

Add-Content $fileName "--Logins"
cd SQLSERVER:\sql\$serverName\Default\Logins
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--LinkedServers"
cd SQLSERVER:\sql\$serverName\Default\LinkedServers
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ResourcePools"
cd SQLSERVER:\sql\$serverName\Default\ResourceGovernor\ResourcePools
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ServerTriggers"
cd SQLSERVER:\sql\$serverName\Default\Triggers
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--ProxyAccounts"
cd SQLSERVER:\sql\$serverName\Default\JobServer\ProxyAccounts
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--JobCategories"
cd SQLSERVER:\sql\$serverName\Default\JobServer\JobCategories
get-childitem | %{$_.Script()} | Add-Content $fileName

Add-Content $fileName "--Jobs"
cd SQLSERVER:\sql\$serverName\Default\JobServer\Jobs
get-childitem | %{$_.Script()} | Add-Content $fileName

"Successfully scripted metadata for instance $ServerInstance. It was saved in file $fileName"
}

#$DebugPreference = "Continue"

getAndStoreInstanceMetadata -ServerInstance $ServerInstance
