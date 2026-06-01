# Check-BatteryHealth.ps1

# Get battery data from WMI
$static = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData
$fullcap = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity
$status = Get-CimInstance -ClassName Win32_Battery

# Extract values
$designCapacity = $static.DesignedCapacity
$fullChargeCapacity = $fullcap.FullChargedCapacity
$cycleCount = $static.CycleCount

# Calculate health
if ($designCapacity -gt 0) {
    $healthPercent = [math]::Round(($fullChargeCapacity / $designCapacity) * 100, 2)
} else {
    $healthPercent = "Unknown"
}

# Output results
Write-Host "==== Battery Health Report ====" -ForegroundColor Cyan
Write-Host "Design Capacity      : $designCapacity mWh"
Write-Host "Full Charge Capacity : $fullChargeCapacity mWh"
Write-Host "Battery Health       : $healthPercent %"
Write-Host "Cycle Count          : $cycleCount"

if ($status) {
    Write-Host "Status               : $($status.BatteryStatus)"
}

# Health interpretation
if ($healthPercent -is [double]) {
    if ($healthPercent -ge 90) {
        Write-Host "Condition            : Excellent" -ForegroundColor Green
    } elseif ($healthPercent -ge 80) {
        Write-Host "Condition            : Good" -ForegroundColor Green
    } elseif ($healthPercent -ge 70) {
        Write-Host "Condition            : Aging" -ForegroundColor Yellow
    } else {
        Write-Host "Condition            : Replace Soon" -ForegroundColor Red
    }
}