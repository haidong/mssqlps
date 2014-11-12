$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


Describe "getInstanceMasterUserSP" {

        It "should have sp_WhoIsActive" {
			$a = getInstanceMasterUserSP("sql1")
			$a.name[1] | Should Be "sp_WhoIsActive"
		}

}

Describe "getMasterUserSPDefinition" {

        It "sp_WhoIsActive definition should be" {
			$a = getMasterUserSPDefinition "sql1" "sp_WhoIsActive"
			$a | Should Be "sp_WhoIsActive"
		}

}

Describe "getInstanceVersion" {

        It "checks version number for sql1" {
            getInstanceVersion("sql1") | Should Be "11.0.3000.0"
        }
        It "checks version number for sql2\finance" {
            getInstanceVersion("sql2\finance") | Should Be "11.0.3128.0"
        }
        It "sql1 version number is not 11.0" {
            getInstanceVersion("sql1") | Should Not Be "11.0"
        }

}

Describe "getADUserInfo" {

        It "checks user name" {
            $a = getADUserInfo("S-1-5-21-4123415722-4240324617-1029072784-1108")
            $a.FullName | Should Be "bogey "
        }
        It "checks user's office phone" {
            $a = getADUserInfo("S-1-5-21-4123415722-4240324617-1029072784-1104")
            $a.OfficePhone | Should Be "123"
        }
}
Describe "getGroupMember" {

        It "checks member count" {
            $a = getGroupMember("family")
            $a.Count | Should Be 5
        }
        It "checks bogey is part of the family group" {
            $a = getGroupMember("family")
            $a[2].FullName | Should Be "bogey "
        }
}
Describe "getADUserWithSqlSaPermission" {

        It "checks member count" {
            $a = getADUserWithSqlSaPermission("sql1")
            $a.Count | Should Be 5
        }
        It "checks bogey has sysadmin to sql1 default instance" {
            $a = getADUserWithSqlSaPermission("sql1")
            $a[2].FullName | Should Be "bogey "
        }
}
Describe "getSqlInstanceName" {

        It "checks the default instance" {
            $a = getSqlInstanceName("sql1")
            $a | Should Be "sql1"
        }
        It "checks named instances on a server" {
            $a = getSqlInstanceName("sql2")
            $a[0] | Should Be "sql2\finance"
        }
        It "checks when no SQL Server is installed" {
            $a = getSqlInstanceName("DCServer")
            $a | Should Be $null
        }
}
