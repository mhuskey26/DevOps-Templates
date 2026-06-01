# ============================================
# CPU Troubleshooting Script
# ============================================

# -------- SETTINGS --------
$IntervalSeconds = 2
$DurationMinutes = 5      # 0 = infinite
$OutputPath = "$env:USERPROFILE\Desktop\cpu_usage_log.csv"

# -------- INIT --------
$StartTime = Get-Date
$cpuHistory = @()

if ($DurationMinutes -gt 0) {
    $EndTime = $StartTime.AddMinutes($DurationMinutes)
}

# Write CSV header
"Timestamp,CPU_Total,CPU_User,CPU_System,TopProcesses,HealthFlag" | Out-File $OutputPath

Write-Host "Started advanced CPU monitoring..."

# Track previous CPU per process
$prevCPU = @{}

# -------- LOOP --------
while ($true) {

    if ($DurationMinutes -gt 0 -and (Get-Date) -ge $EndTime) {
        break
    }

    # --- CPU Counters ---
    $counters = Get-Counter @(
        '\Processor(_Total)\% Processor Time',
        '\Processor(_Total)\% User Time',
        '\Processor(_Total)\% Privileged Time'
    )

    $samples = $counters.CounterSamples

    $cpuTotal  = [math]::Round(($samples | Where-Object Path -like "*Processor Time").CookedValue,2)
    $cpuUser   = [math]::Round(($samples | Where-Object Path -like "*User Time").CookedValue,2)
    $cpuSystem = [math]::Round(($samples | Where-Object Path -like "*Privileged Time").CookedValue,2)

    # --- Track CPU history for trend detection ---
    $cpuHistory += $cpuTotal
    if ($cpuHistory.Count -gt 10) {
        $cpuHistory = $cpuHistory[-10..-1]
    }

    $avgCPU = [math]::Round(($cpuHistory | Measure-Object -Average).Average,2)

    # --- Process Delta Tracking (better than raw CPU time) ---
    $current = @{}
    $topList = @()

    Get-Process | Where-Object { $_.CPU -ne $null } | ForEach-Object {
        $name = $_.ProcessName
        $cpuTime = $_.CPU

        if ($prevCPU.ContainsKey($name)) {
            $delta = $cpuTime - $prevCPU[$name]
            if ($delta -gt 0) {
                $current[$name] = $delta
            }
        }

        $prevCPU[$name] = $cpuTime
    }

    $topProcesses = $current.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object -First 5

    $procSummary = ($topProcesses | ForEach-Object {
        "$($_.Key):$([math]::Round($_.Value,2))"
    }) -join " | "

    # --- Health Detection ---
    $health = ""

    # 10% baseline detection
    if ($avgCPU -ge 8 -and $avgCPU -le 12) {
        $health += "Baseline10%; "
    }

    # High system CPU (drivers/kernel)
    if ($cpuSystem -gt 5) {
        $health += "HighKernel; "
    }

    # Hidden CPU usage
    $sumTop = ($topProcesses | Measure-Object Value -Sum).Sum
    if ($cpuTotal -gt 8 -and $sumTop -lt 2) {
        $health += "HiddenCPU; "
    }

    # --- Output row ---
    $line = "$((Get-Date)),$cpuTotal,$cpuUser,$cpuSystem,""$procSummary"",""$health"""
    Add-Content -Path $OutputPath -Value $line

    # --- Console ---
    Write-Host "$((Get-Date)) | CPU:$cpuTotal% User:$cpuUser% Sys:$cpuSystem% | $health"
    Write-Host "Processes: $procSummary"
    Write-Host "-------------------------------------------"

    Start-Sleep -Seconds $IntervalSeconds
}

Write-Host "Monitoring complete. Log saved to $OutputPath"