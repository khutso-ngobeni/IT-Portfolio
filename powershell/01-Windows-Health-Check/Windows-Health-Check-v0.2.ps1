# ==========================================
# Script Name : Windows Health Check v0.2
# Author      : Khutso Ngobeni
# Version     : 0.2
# Description : Collects Windows system information
#               and performs basic health checks.
# ==========================================

# ==========================================
# Collect System Information
# ==========================================

# General Information
$ComputerInfo = Get-ComputerInfo
$CurrentTime = Get-Date

# Operating System
$OSInfo = Get-CimInstance Win32_OperatingSystem

# Hardware Information
$CPUInfo = Get-CimInstance Win32_Processor
$BIOSInfo = Get-CimInstance Win32_BIOS
$ComputerSystemInfo = Get-CimInstance Win32_ComputerSystem

# Storage Information
$DiskInfo = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

# Installed RAM
$RAMInfo = $ComputerSystemInfo.TotalPhysicalMemory

# Windows Activation
$ActivationInfo = Get-CimInstance SoftwareLicensingProduct |
Where-Object {
    $_.PartialProductKey -and $_.Name -like "*Windows*"
} |
Select-Object -First 1

# Microsoft Defender
$DefenderInfo = Get-MpComputerStatus

# Pending Restart
$PendingRestart = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"

# Internet Connectivity
$InternetConnection = Test-NetConnection www.google.com -InformationLevel Quiet

# ==========================================
# Calculate Health Information
# ==========================================

# System Uptime
$Uptime = New-TimeSpan -Start $OSInfo.LastBootUpTime -End $CurrentTime

if ($Uptime.Days -gt 30)
{
    $UptimeStatus = "Restart Recommended"
}
else
{
    $UptimeStatus = "Healthy"
}

# Disk Health
$DiskSize = $DiskInfo.Size
$FreeSpace = $DiskInfo.FreeSpace
$DiskFreePercent = ($FreeSpace / $DiskSize) * 100

if ($DiskFreePercent -ge 20)
{
    $DiskStatus = "Healthy"
}
elseif ($DiskFreePercent -ge 10)
{
    $DiskStatus = "Warning"
}
else
{
    $DiskStatus = "Critical"
}

# Memory Health
$AvailableRAM = $OSInfo.FreePhysicalMemory * 1KB
$UsedRAM = $RAMInfo - $AvailableRAM
$MemoryUsagePercent = ($UsedRAM / $RAMInfo) * 100

if ($MemoryUsagePercent -lt 70)
{
    $MemoryStatus = "Healthy"
}
elseif ($MemoryUsagePercent -lt 90)
{
    $MemoryStatus = "Warning"
}
else
{
    $MemoryStatus = "Critical"
}

# Windows Activation Status
switch ($ActivationInfo.LicenseStatus)
{
    1
    {
        $ActivationStatus = "Activated"
    }

    0
    {
        $ActivationStatus = "Not Activated"
    }

    default
    {
        $ActivationStatus = "Unknown"
    }
}

# Microsoft Defender Status

if ($DefenderInfo.RealTimeProtectionEnabled)
{
    $DefenderStatus = "Healthy"
}
else
{
    $DefenderStatus = "Critical"
}
# Defender Service
if ($DefenderInfo.AMServiceEnabled)
{
    $DefenderService = "Running"
}
else
{
    $DefenderService = "Stopped"
}

# Antivirus
if ($DefenderInfo.AntivirusEnabled)
{
    $AntivirusStatus = "Enabled"
}
else
{
    $AntivirusStatus = "Disabled"
}

# Real-Time Protection
if ($DefenderInfo.RealTimeProtectionEnabled)
{
    $RealTimeProtection = "Enabled"
}
else
{
    $RealTimeProtection = "Disabled"
}

# Pending Restart Status
if ($PendingRestart)
{
    $PendingRestartStatus = "Yes"
}
else
{
    $PendingRestartStatus = "No"
}

# Internet Status

if ($InternetStatus)
{
    $InternetStatus = "Connected"
}
else
{
    $InternetStatus = "Disconnected"
}

# Overall Health Status

if (
    $DiskStatus -eq "Critical" -or
    $MemoryStatus -eq "Critical" -or
    $DefenderStatus -eq "Critical" -or
    $InternetStatus -eq "Disconnected"
)
{
    $OverallStatus = "Critical"
}
elseif (
    $DiskStatus -eq "Warning" -or
    $MemoryStatus -eq "Warning" -or
    $UptimeStatus -eq "Restart Recommended" -or
    $PendingRestartStatus -eq "Yes"
)
{
    $OverallStatus = "Warning"
}
else
{
    $OverallStatus = "Healthy"
}

# Recommendations

$Recommendations = @()

if ($UptimeStatus -eq "Restart Recommended")
{
    $Recommendations += "Restart the computer."
}

if ($DiskStatus -eq "Warning" -or $DiskStatus -eq "Critical")
{
    $Recommendations += "Free up disk space."
}

if ($MemoryStatus -eq "Warning" -or $MemoryStatus -eq "Critical")
{
    $Recommendations += "Close unnecessary applications."
}

if ($PendingRestartStatus -eq "Yes")
{
    $Recommendations += "Restart to complete Windows updates."
}

if ($DefenderStatus -eq "Critical")
{
    $Recommendations += "Enable Microsoft Defender."
}

if ($InternetStatus -eq "Disconnected")
{
    $Recommendations += "Check your network connection."
}

if ($Recommendations.Count -eq 0)
{
    $Recommendations += "No action required. System is healthy."
}

# ==========================================
# Display Report
# ==========================================

# Report Header
Write-Host "========================================"
Write-Host "      Windows Health Check v0.2"
Write-Host "========================================"

# ==========================================
# System Information
# ==========================================

Write-Host ""
Write-Host "System Information"
Write-Host "------------------"

Write-Host ("Computer Name     : {0}" -f $ComputerInfo.CsName)
Write-Host ("Windows Edition   : {0}" -f $ComputerInfo.WindowsProductName)
Write-Host ("Windows Version   : {0}" -f $ComputerInfo.WindowsVersion)
Write-Host ("Manufacturer      : {0}" -f $ComputerInfo.CsManufacturer)
Write-Host ("Model             : {0}" -f $ComputerInfo.CsModel)
Write-Host ("BIOS Version      : {0}" -f $BIOSInfo.SMBIOSBIOSVersion)
Write-Host ("Processor         : {0}" -f $CPUInfo.Name)
Write-Host ("Installed RAM     : {0:N2} GB" -f ($RAMInfo / 1GB))


# ==========================================
# System Health
# ==========================================

Write-Host ""
Write-Host "System Health"
Write-Host "-------------"

Write-Host ("System Uptime     : {0} Days, {1} Hours, {2} Minutes" -f $Uptime.Days, $Uptime.Hours, $Uptime.Minutes)
Write-Host ("Uptime Status     : {0}" -f $UptimeStatus)

Write-Host ""

Write-Host ("Disk Size         : {0:N2} GB" -f ($DiskSize / 1GB))
Write-Host ("Free Space        : {0:N2} GB" -f ($FreeSpace / 1GB))
Write-Host ("Free Space (%)    : {0:N2}%" -f $DiskFreePercent)
Write-Host ("Disk Status       : {0}" -f $DiskStatus)

Write-Host ""

Write-Host ("Available RAM     : {0:N2} GB" -f ($AvailableRAM / 1GB))
Write-Host ("Used RAM          : {0:N2} GB" -f ($UsedRAM / 1GB))
Write-Host ("Memory Usage      : {0:N2}%" -f $MemoryUsagePercent)
Write-Host ("Memory Status     : {0}" -f $MemoryStatus)

# ==========================================
# Security
# ==========================================

Write-Host ""
Write-Host "Security"

# Windows Activation
Write-Host ("Windows Activation : {0}" -f $ActivationStatus)

# Microsoft Defender Status
Write-Host ("Defender Service   : {0}" -f $DefenderService)
Write-Host ("Antivirus          : {0}" -f $AntivirusStatus)
Write-Host ("Real-Time Protect. : {0}" -f $RealTimeProtection)
Write-Host ("Defender Status    : {0}" -f $DefenderStatus)

# Pending Restart
Write-Host ("Pending Restart    : {0}" -f $PendingRestartStatus)

# ==========================================
# Connectivity
# ==========================================

Write-Host ""
Write-Host "Connectivity"
Write-Host "------------"

# Internet Status
Write-Host ("Internet Status : {0}" -f $InternetStatus)

# ==========================================
# Overall Health Summary
# ==========================================

Write-Host ""
Write-Host "Overall Health Summary"
Write-Host "----------------------"

Write-Host ("Overall Status : {0}" -f $OverallStatus)

Write-Host ""
Write-Host "Recommendations"
Write-Host "---------------"

foreach ($Recommendation in $Recommendations)
{
    Write-Host ("- {0}" -f $Recommendation)
}

# Overall Status
# Recommendations
