$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "updateInstanceSQL" {

	It "generate the right SQL for sql1" {
		$sql = updateInstanceSQL @{InstanceName = "sql1"; InstanceID = 1}
		$sql | Should Be "EXEC Windows.Instance_Update 1, 'Developer Edition (64-bit)', '-2117995310', '12.0.2000.8', 'RTM'"}}
