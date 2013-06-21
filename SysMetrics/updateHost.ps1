$a = Invoke-Sqlcmd -Query "exec Windows.Host_Select_HostID_HostName" -ServerInstance "sql1" -Database "SysMetrics"
$a | ForEach-Object {
$HostName = $_.HostName
$HostID = $_.HostID

try {
$b = get-wmiobject -computername $HostName -Class Win32_ComputerSystem
}
catch [Exception] {
continue
}

$Domain = $b.Domain
$HardwareVendor = $b.Manufacturer
$HardwareModel = $b.Model
$MemorySizeGB = ($b.TotalPhysicalMemory / 1gb) + 1

try {
$b = get-wmiobject -computername $HostName -Class Win32_Processor | select -first 1
}
catch [Exception] {
continue
}

$CPUType = $b.name
$CoreCount = $b.NumberOfCores

try {
$b = get-wmiobject -computername $HostName -Class Win32_OperatingSystem
}
catch [Exception] {
continue
}

$OS = $b.Caption
$OSArchitecture = $b.OSArchitecture
$OSServicePack = $b.CSDVersion
$OSVersionNumber = $b.Version

$sql = "EXEC Windows.Host_Update $HostID, '$Domain', '$OS', '$OSArchitecture', '$OSServicePack', '$OSVersionNumber', '$HardwareModel', '$HardwareVendor', $MemorySizeGB, '$CPUType', $CoreCount"
Invoke-Sqlcmd -Query $sql -ServerInstance "sql1" -Database "SysMetrics"

}

