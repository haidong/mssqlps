$HostList = Invoke-Sqlcmd -Query "exec Windows.Host_Select_HostID_HostName" -ServerInstance "sql1" -Database "SysMetrics"
$HostList | ForEach-Object {
    $HostName = $_.HostName
    $HostID = $_.HostID

    try {
       $WmiResults = get-wmiobject -computername $HostName -Class Win32_ComputerSystem
        }
    catch [Exception] {
       continue
    }

    $Domain = $WmiResults.Domain
    $HardwareVendor = $WmiResults.Manufacturer
    $HardwareModel = $WmiResults.Model
    $MemorySizeGB = ($WmiResults.TotalPhysicalMemory / 1gb) + 1

    try {
       $WmiResults = get-wmiobject -computername $HostName -Class Win32_Processor | select -first 1
        }
    catch [Exception] {
       continue
    }

    $CPUType = $WmiResults.name
    $CoreCount = $WmiResults.NumberOfCores

    try {
       $WmiResults = get-wmiobject -computername $HostName -Class Win32_OperatingSystem
        }
    catch [Exception] {
       continue
    }

    $OS = $WmiResults.Caption
    $OSArchitecture = $WmiResults.OSArchitecture
    $OSServicePack = $WmiResults.CSDVersion
    $OSVersionNumber = $WmiResults.Version

    $sql = "EXEC Windows.Host_Update $HostID, '$Domain', '$OS', '$OSArchitecture', '$OSServicePack', '$OSVersionNumber', '$HardwareModel', '$HardwareVendor', $MemorySizeGB, '$CPUType', $CoreCount"
    Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "SysMetrics"
}
