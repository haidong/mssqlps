function getSqlInstanceName($ComputerName) {
    $SqlInstances = Get-Service -ComputerName $ComputerName | where {($_.Name -like
    'mssql$*') -or ($_.Name -eq 'mssqlserver')}
    $instanceNameArray = New-Object System.Collections.ArrayList
    if ($SqlInstances -ne $null) {
        $SqlInstances | foreach {
            if ($_.Name -eq 'mssqlserver') {
                [void]
                $instanceNameArray.add(@{InstanceName=$ComputerName;Status=$_.Status})
            }
            else {
                [void]
                $instanceNameArray.add(@{InstanceName=$ComputerName + "\" +
                $_.Name.split("$")[1];Status=$_.Status})
            }
        }
    }
    $instanceNameArray
}
