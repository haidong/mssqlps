function updateHostSQL($h) {
    $HostName = $h.HostName
    $HostID = $h.HostID

    try {
       $WmiResults = get-wmiobject -computername $HostName -Class Win32_ComputerSystem
       $BiosResults = get-wmiobject -computername $HostName -Class Win32_BIOS
        }
    catch [Exception] {
       continue
    }

    $Domain = $WmiResults.Domain
    $HardwareVendor = $WmiResults.Manufacturer
    $HardwareModel = $WmiResults.Model
    $MemorySizeGB = ($WmiResults.TotalPhysicalMemory / 1gb) + 1
    
    $SMBiosVersion = $BiosResults.SMBIOSBIOSVersion
    $BiosReleaseDate = $BiosResults.ReleaseDate.substring(0, 8)
    $SerialNumber = $BiosResults.SerialNumber

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

    $sql = "EXEC Windows.Host_Update $HostID, '$Domain', '$OS', '$OSArchitecture', '$OSServicePack', '$OSVersionNumber', '$HardwareModel', '$HardwareVendor', $MemorySizeGB, '$CPUType', $CoreCount, '$SMBiosVersion', '$BiosReleaseDate', '$SerialNumber'"
    return $sql
}