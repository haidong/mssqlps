$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "getInstanceConfig" {

	It "retrieves current SQL Server instance configuration values" {
		$config = getInstanceConfig("sql1")
		$config[0].Configuration_ID | Should Be 101
		$config[11].Configuration_ID | Should Be 400}}

Describe "insertInstanceConfigSQL" {

	It "generates correct SQL given a configuration value" {
		$sql = insertInstanceConfigSQL @{Configuration_ID = 101; name = "recovery interval (min)"; value=0; valueInUse=0} 1
		$sql | Should Be "EXEC Windows.InstanceConfig_Insert 1, 101, 'recovery interval (min)', '0', '0'"}}