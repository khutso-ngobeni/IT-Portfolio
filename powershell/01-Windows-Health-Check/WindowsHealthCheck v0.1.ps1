<#
.SYNOPSIS
Windows Health Check Tool

.DESCRIPTION
Collects basic Windows system information to assist IT technicians with
troubleshooting and system health assessment.

.NOTES
Author: Khutso Ngobeni
Version: 0.1
Project: IT Portfolio
#>

# ==========================================
# Collect Computer Information
# ==========================================

$ComputerName = $env:COMPUTERNAME
$CurrentUser  = $env:USERNAME

# ==========================================
# Collect Operating System Information
# ==========================================

$OS = Get-CimInstance Win32_OperatingSystem

$OperatingSystem = $OS.Caption
$OSVersion       = $OS.Version
$BuildNumber     = $OS.BuildNumber
$Architecture    = $OS.OSArchitecture

# ==========================================
# Collect Hardware Information
# ==========================================

$ComputerSystem = Get-CimInstance Win32_ComputerSystem

$Manufacturer = $ComputerSystem.Manufacturer
$Model        = $ComputerSystem.Model
$RAM          = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)

# ==========================================
# Collect Processor Information
# ==========================================

$Processor = Get-CimInstance Win32_Processor

$CPU                = $Processor.Name
$CPUManufacturer    = $Processor.Manufacturer
$CPUCores           = $Processor.NumberOfCores
$LogicalProcessors  = $Processor.NumberOfLogicalProcessors

# ==========================================
# Collect BIOS Information
# ==========================================

$BIOS = Get-CimInstance Win32_BIOS

$BIOSManufacturer = $BIOS.Manufacturer
$BIOSVersion      = $BIOS.SMBIOSBIOSVersion
$SerialNumber     = $BIOS.SerialNumber

# ==========================================
# Collect System Uptime
# ==========================================

$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)

$UptimeDisplay = "$($Uptime.Days) Days, $($Uptime.Hours) Hours"

# ==========================================
# Collect Disk Information
# ==========================================

$Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

$Drive      = $Disk.DeviceID
$FileSystem = $Disk.FileSystem
$DiskSize   = [math]::Round($Disk.Size / 1GB, 2)
$FreeSpace  = [math]::Round($Disk.FreeSpace / 1GB, 2)
$UsedSpace  = [math]::Round($DiskSize - $FreeSpace, 2)

# ==========================================
# Output Results
# ==========================================

Write-Host "Windows Health Check Tool"
Write-Host "-------------------------"
Write-Host ""

Write-Host "Computer Information"
Write-Host "--------------------"
Write-Host "Computer Name       : $ComputerName"
Write-Host "Current User        : $CurrentUser"
Write-Host ""

Write-Host "Operating System Information"
Write-Host "----------------------------"
Write-Host "Operating System    : $OperatingSystem"
Write-Host "Version             : $OSVersion"
Write-Host "Build Number        : $BuildNumber"
Write-Host "Architecture        : $Architecture"
Write-Host ""

Write-Host "Hardware Information"
Write-Host "--------------------"
Write-Host "Manufacturer        : $Manufacturer"
Write-Host "Model               : $Model"
Write-Host "Installed RAM       : $RAM GB"
Write-Host ""

Write-Host "Processor Information"
Write-Host "---------------------"
Write-Host "Processor           : $CPU"
Write-Host "CPU Manufacturer    : $CPUManufacturer"
Write-Host "CPU Cores           : $CPUCores"
Write-Host "Logical Processors  : $LogicalProcessors"
Write-Host ""

Write-Host "BIOS Information"
Write-Host "----------------"
Write-Host "BIOS Manufacturer  : $BIOSManufacturer"
Write-Host "BIOS Version       : $BIOSVersion"
Write-Host "Serial Number      : $SerialNumber"
Write-Host ""

Write-Host "System Information"
Write-Host "------------------"
Write-Host "System Uptime      : $UptimeDisplay"
Write-Host ""

Write-Host "Disk Information"
Write-Host "----------------"
Write-Host "Drive Letter       : $Drive"
Write-Host "File System        : $FileSystem"
Write-Host "Disk Size          : $DiskSize GB"
Write-Host "Free Space         : $FreeSpace GB"
Write-Host "Used Space         : $UsedSpace GB"