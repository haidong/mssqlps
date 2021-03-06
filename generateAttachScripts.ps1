param([parameter(Mandatory=$true)]$ServerInstance)
. "X:\pathTo\baseFunctions.ps1"
try {
$results = Invoke-Sqlcmd -Query "select @@servername" -ServerInstance $ServerInstance
}
catch {
"Check your spelling. You might have put in the wrong instance name or it is down: $ServerInstance"
exit
}
$serverName = $results.column1.replace('\', '_')
$serverDate = Get-Date -format "yyyy_MM_dd"
$fileName = "X:\savedScriptPath\" + $serverName + "_attach" + "_$serverDate.sql"
Set-Content $fileName "--Scripts for attaching all user databases on $ServerInstance"

# Get a list of user databases, then iterate through them one by oen for attach script generation
$results = getInstanceUserDb -ServerInstance $ServerInstance
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
