$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "getSqlInstanceName" {

    It "sql2 has Finance and HR" {
	$SqlInstances = getSqlInstanceName("sql2")
	$SqlInstances.InstanceName[1] | Should Be "sql2\hr"
	$SqlInstances.InstanceName[0] | Should Be "sql2\finance"
    }
}
