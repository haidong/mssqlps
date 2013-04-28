$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

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

    Describe "getGroupMember" {

        It "checks member count" {
            $a = getGroupMember("family")
            $a.Count | Should Be 5
        }
        It "checks bogey is part of the family group" {
            $a = getGroupMember("family")
            $a[0].FullName | Should Be "bogey "
        }
    }
    }
