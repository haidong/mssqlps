param([parameter(Mandatory=$true)]$SourceInstance, [parameter(Mandatory=$true)]$DestinationInstance)

. .\baseFunctions.ps1

$spLists = getInstanceMasterUserSP($SourceInstance)

$spLists.name | foreach {
	$sp = $_
	$query = "IF OBJECT_ID('dbo.$sp', 'P') IS NOT NULL DROP PROC dbo.$sp"
	Invoke-Sqlcmd -ServerInstance $DestinationInstance -Query $query
	$query = getMasterUserSPDefinition $SourceInstance $sp
	Invoke-Sqlcmd -ServerInstance $DestinationInstance -Query $query
}