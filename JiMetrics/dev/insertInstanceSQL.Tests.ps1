$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "getSqlInstanceName" {
    It "sql2 has Finance and HR" {
		$SqlInstances = getSqlInstanceName("sql2")
		$SqlInstances[1].InstanceName | Should Be "sql2\hr"
		$SqlInstances[0].InstanceName | Should Be "sql2\finance"
		$SqlInstances.Length | Should Be 2}
    It "sql1 has mssqlserver" {
		$SqlInstances = getSqlInstanceName("sql1")
		$SqlInstances.Length | Should Be 1
		$SqlInstances.InstanceName | Should Be "sql1"}}

Describe "insertInstanceSQL" {
    It "sql2\finance is inactive and sql2\hr is active" {
		$SqlInstances = getSqlInstanceName("sql2")
		$sql = insertInstanceSQL $SqlInstances[0] 2
		$sql | Should Be "EXEC Windows.Instance_Insert 2, 'sql2\FINANCE', 'N'"
		$sql = insertInstanceSQL $SqlInstances[1] 2
		$sql | Should Be "EXEC Windows.Instance_Insert 2, 'sql2\HR', 'Y'"}
    It "sql1 is active" {
		$SqlInstances = getSqlInstanceName("sql1")
		$sql = insertInstanceSQL $SqlInstances 1
		$sql | Should Be "EXEC Windows.Instance_Insert 1, 'sql1', 'Y'"}}