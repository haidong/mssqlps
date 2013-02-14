. PSUnit.ps1
. "c:\PathTo\baseFunctions.ps1"

function Test.getInstanceVersion()
{
#Arrange
    	$expectedResult = "11.0.2100.60"
#Act
	$actualResult = getInstanceVersion -ServerInstance "myTestServer"
#Assert
	Assert-That -ActualValue $actualResult -Constraint {$actualResult -eq $expectedResult}
}
function Test.getInstanceUserDb()
{
#Arrange
	$expectedResult = "DBAMetrics"
#Act
	$actualResult = getInstanceUserDb -ServerInstance "myTestServer"
	$actualResultArray = @()
	for ($i=0; $i -le $actualResult.length; $i++)
	{
		$actualResultArray = $actualResultArray + ($actualResult[$i].ItemArray -join ",")
	}
#Assert
	Assert-That -ActualValue $actualResultArray -Constraint {$actualResultArray -contains $expectedResult}
}
function Test.getUserDbDatafile_MoreThanOneFile()
{
#Arrange
	$expectedResult = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\DBAMetrics.mdf"
#Act
	$actualResult = getUserDbDatafile -ServerInstance "myTestServer" -DbName "DBAMetrics"
	$actualResultArray = @()
	for ($i=0; $i -le $actualResult.length; $i++)
	{
		$actualResultArray = $actualResultArray + ($actualResult[$i].ItemArray -join ",")
	}
#Assert
	Assert-That -ActualValue $actualResultArray -Constraint {$actualResultArray -contains $expectedResult}
}
function Test.getUserDbDatafile_OneFile()
{
#Arrange
	$expectedResult = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\master.mdf"
#Act
	$actualResult = getUserDbDatafile -ServerInstance "myTestServer" -DbName "master"
#Assert
	Assert-That -ActualValue $actualResult-Constraint {$actualResult.physical_name -eq $expectedResult}
}
function Test.getUserDbLogfile()
{
#Arrange
	$expectedResult = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\DBAMetrics_log.ldf"
#Act
	$actualResult = getUserDbLogfile -ServerInstance "myTestServer" -DbName "DBAMetrics"
#Assert
	Assert-That -ActualValue $actualResult -Constraint {$actualResult.physical_name -contains $expectedResult}
}
function Test.generateAttachScript()
{
#Arrange
	$expectedResult = "*create database DBAMetrics*"
#Act
	$actualResult = generateAttachScript -ServerInstance "myTestServer" -DbName "DBAMetrics"
#Assert
	Assert-That -ActualValue $actualResult -Constraint {$actualResult -like $expectedResult}
}
function Test.getDbDataIndexSizeInGB()
{
#Arrange
	$expectedResult = "tSQLt"
#Act
	$actualResult = getDbDataIndexSizeInGB -ServerInstance "myTestServer" -DbName "DBAMetrics"
#Assert
	Assert-That -ActualValue $actualResult -Constraint {$actualResult[2].schema -eq $expectedResult}
}
