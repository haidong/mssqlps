$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "updateHostSQL" {

	It "should produce proper update host stored procedure call" {
		$hh = @{HostID = 1; HostName = "sql1"}
		$sql = updateHostSQL($hh)
		$sql | Should Be "EXEC Windows.Host_Update 1, 'HaidongWorks.local', 'Microsoft Windows Server 2012 Standard Evaluation', '64-bit', '', '6.2.9200', 'VirtualBox', 'innotek GmbH', 8.99956130981445, 'Intel(R) Core(TM) i7-2820QM CPU @ 2.30GHz', 1, 'VirtualBox', '20061201', '0'"
	}
}
