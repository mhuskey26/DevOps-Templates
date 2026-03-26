#DevOps_Get-ServerInfo – script contents:
# Author: Cindy Muesing
# Date: 8/31/18

###############################################################################################

function DevOps_Get-ServerInfo {
    [cmdletbinding()]
                #set variables
                $today = Get-Date -format yyyyMMdd
                $ComputerName = hostname
 
    $ServerInfo = Invoke-Command  {
        $services = Get-Service | select DisplayName | sort DisplayName
        $wmiapps = Get-WmiObject -Class Win32_Product | select Name | sort Name
        $features = Get-WindowsFeature | Where Installed       
        $sizeFree = Get-WmiObject Win32_Logicaldisk -filter "deviceid='C:'" | Select PSComputername,DeviceID,@{Name="SizeGB";Expression={$_.Size/1GB -as [int]}},
                    @{Name="FreeGB";Expression={[math]::Round($_.Freespace/1GB,2)}}
        $sizeMem = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
        $netCore = dotnet --info
        $programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                    Select-Object DisplayName, Publisher | sort DisplayName
        $netFrameworks = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name Version,Release -EA 0 |
                    Where { $_.PSChildName -match '^(?!S)\p{L}'} | Select PSChildName, Version, Release
        Try{
        If(Test-RegistryValue('HKLM:\SOFTWARE\Microsoft\InetStp','InstallPath') -eq $true) 
        {$websites = get-IISSite | select name,id,state,physicalpath,@{n="Bindings"; e= { ($_.bindings | select -expa collection) -join ';' }} ,
                    @{n="LogFile";e={ $_.logfile | select -expa directory}}, @{n="attributes"; e={($_.attributes | % { $_.name + "=" + $_.value }) -join ';' }}
        $appPools = Get-IISAppPool | sort Name}
        Else {        
            $websites = 'IIS not installed'
            $appPools = 'No AppPool and no IIS'
            }
        }
        Catch{
        $websites = 'IIS not installed - error'
        $appPools = 'No AppPool and no IIS - error'
        }
    return $services,$wmiapps,$features, $sizeFree, $sizeMem, $netCore, $programs, $netFrameworks, $websites, $appPools
    }

    $ServerInfo[0] | Export-Csv H:\PS\outputs\$($computername)_Services_$today.csv -Force
    $ServerInfo[1] | Export-Csv H:\PS\outputs\$($computername)_wmiapps_$today.csv -Force 
    $ServerInfo[6] | Out-file   H:\PS\outputs\$($computername)_Programs_$today.txt -Force
    $ServerInfo[8] | Out-file H:\PS\outputs\$($ComputerName)_WebsiteInfo_$today.txt -Force
    $ServerInfo[9] | Out-file H:\PS\outputs\$($ComputerName)_AppPools_$today.txt -Force
    $ServerInfo[2],$ServerInfo[3],"RAM",$ServerInfo[4],$ServerInfo[5], $ServerInfo[7] | Out-File H:\PS\outputs\$($computername)_Features_$today.txt -Encoding Ascii -Force
}
###############################################################################################
Function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    ) 

    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}
###############################################################################################

DevOps_Get-ServerInfo

# SIG # Begin signature block
# MIIRcgYJKoZIhvcNAQcCoIIRYzCCEV8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxRK/ESHA7Pkmx7j7SGBtkKwE
# PwSggg7MMIIGfDCCBGSgAwIBAgIKERQ+ugAAAAAABzANBgkqhkiG9w0BAQsFADAd
# MRswGQYDVQQDExJPVFMtQ09SUC1ST09UQ0EtQ0EwHhcNMTQwMzEwMjAxNDQyWhcN
# MjQwMzEwMjAyNDQyWjBYMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxGjAYBgoJkiaJ
# k/IsZAEZFgpvcGVuLXRlY2hzMSMwIQYDVQQDExpvcGVuLXRlY2hzLU9UUy1DT1JQ
# LURDMi1DQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALhpKqr00v3j
# GDh+t01Z5/kldBpV7HlhMmi+04hMB19cLW8sQclgkW8cafb5B5LJbg3yDftdh0Op
# TKFfC/Z7ObeFCn/gpH0fBHlPwcZ4xwX3PRIqBIT6GgQe3noKnlM15iZDHGaTCeNI
# jjnnq5jOMiEgetfAsQaNVs4B7sNfSnV+g5d8R96qaBedjnUHyaSJ4sl/ffZpNMcQ
# wSMkULFZbweJdQ5LUgXY7jp8qz2qMSQ4tGqu/dc6zGCUwnHW96OpGGW8HwY4A/eJ
# m0MBH5gqbwrmqcF24qCynDayPMPtychQxYSi8E0W6+r1T2wWSWW1XphWWZVT9o8A
# 2zpIzNBArhy72bb6NDQ4DeGuC6+a1OsSPPHnOOJLWBQgikgU7YhRs6JbKKNrDbWA
# qAHvUYXvj5Jk6MYOpgOEiLktRN46iqioxHlC+DWao79Ypy31/vEfpkOKqMSXbTyb
# 9KYI+lu0GMmCjCCEDh8yYOps/1wUhz61q5vcu7otfodSQ8B+EHNFBohF/kP3fKcT
# pzOCghbepRvwRfUOYn94acY7nKg24b1tkkFLCgglodMKn+dO959X2aveDct6EMKj
# 4H3l8LLEhnqSwHdznel8SGSTTu+hgDeC0wVWXK1/DBFZWhCkXRgtCOv/7kPm0a7J
# X00Ro6oBgiF3XdL8mSAb3ILIrxRtaGllAgMBAAGjggGBMIIBfTAQBgkrBgEEAYI3
# FQEEAwIBAzAjBgkrBgEEAYI3FQIEFgQUjhMQzsvinwa38lSsg4FGBLIr3SswHQYD
# VR0OBBYEFJgCWbTikt4gs3GmP4trHjb9214qMBkGCSsGAQQBgjcUAgQMHgoAUwB1
# AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaA
# FL9chNIpOsbh/MX7SBh6iouTQIy+MFcGA1UdHwRQME4wTKBKoEiGRmh0dHA6Ly9v
# dHMtY29ycC1kYzIub3Blbi10ZWNocy5sb2NhbC9DZXJ0RW5yb2xsL09UUy1DT1JQ
# LVJPT1RDQS1DQS5jcmwwcgYIKwYBBQUHAQEEZjBkMGIGCCsGAQUFBzAChlZodHRw
# Oi8vb3RzLWNvcnAtZGMyLm9wZW4tdGVjaHMubG9jYWwvQ2VydEVucm9sbC9PVFMt
# Q09SUC1ST09UQ0FfT1RTLUNPUlAtUk9PVENBLUNBLmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEAkZxrReP68hSenTdyKsCs2kCOImJfmeusSAMzweWXOnsAqY0ymWtsW455
# sCznrBxTsB4/O/ayVspLBJunB01+f5zAgQh6RT1HdFUH4qLcNS/pTHLirSdS4cqY
# 1j6Jq/gWNAalrP7Tv2dwSSaxMw8UIshJKhW/QErvkIuoKdNoyEMqTnNlotjhi0Q8
# KsBouZW8XunQP4kUE3iKLRxvpH6j70BZbJUUzx1xsEY06oV1yMo91pn/SU3Em6wd
# KDPdW38qarDIHwykppbm60i+A+pxfQEb1xkjQAlHqfKyUbwiDkXvWaMVcKznfaNk
# 9HA2tXd7BjuqdcDdciyTAES0MsP1r4BiSH2T8jnjYVabprWYzJz57PnbSo2ssUli
# YL9wxNn9y6eCNsBN/BC8we6rKX2rhCE1YabIuoXjCOf65WiJruG8Mjth5M+QRZ5t
# HcSG8VzRw6MVMpNC/w2rFyZl61xzmYkEp6HOpj0crJcfy/O2NUEnA5mEJGgGXK27
# My5qQwjcgZ8szjobBN+6CyS7VlrJwjWLc0U6zrwC407VzHtqldMMD9UekGtMS3Ij
# S4Mqqs2XiIyNJ966sADOdCU3zNvxrjIe3+nliqk09WtcW/tprhB1K5GkkBIyEXxn
# AjpW2Y5blydoJ51nPQ8LfiLNSBReKt+R/EAfbtS/NeYnhRfd1d0wgghIMIIGMKAD
# AgECAhMeAAO3dX6KcPCxWoJkAAMAA7d1MA0GCSqGSIb3DQEBCwUAMFgxFTATBgoJ
# kiaJk/IsZAEZFgVsb2NhbDEaMBgGCgmSJomT8ixkARkWCm9wZW4tdGVjaHMxIzAh
# BgNVBAMTGm9wZW4tdGVjaHMtT1RTLUNPUlAtREMyLUNBMB4XDTE5MTEyNzE3NTUw
# N1oXDTI0MDMxMDIwMjQ0MlowgZkxFTATBgoJkiaJk/IsZAEZFgVsb2NhbDEaMBgG
# CgmSJomT8ixkARkWCm9wZW4tdGVjaHMxDDAKBgNVBAsTA09UUzEZMBcGA1UECxMQ
# RGlnaXRhbCBTdHJhdGVneTENMAsGA1UECxMEU0NDTTEUMBIGA1UECxMLQ29udHJh
# Y3RvcnMxFjAUBgNVBAMTDUNpbmR5IE11ZXNpbmcwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDh2DFvcvF5m9rtK/veAjnz11fcRbSqoaXuE/52CsCRVXsN
# n63zo4MpwEX/ZBrzwPhkgiWCQlwu4QN4aBlPgzWnSNHgR7nhtd5QNJypYbQ9WFy5
# pUNj2igNuiP6MFHWkYKMCk+LgqSSROlLCfAdR4BQPSlbwc+BNlOSfEnVSeWfvjh9
# esHRuph63LQZTMKx2B7FCnsc1jakQyuMieaYXdHjK8ol2ecT7jvh/q/QOSsOhe/s
# U/q1kqFud3KrKLVI7MYi22R6pqNioUYfbw1uI01yyuGY7f6hR9zALUxo95Eh99AI
# 7n/19+nF74g6QTDMJb/qnjFFFcYSrehKEeiEnyEdAgMBAAGjggPHMIIDwzA+Bgkr
# BgEEAYI3FQcEMTAvBicrBgEEAYI3FQiF4ec2hPPfW4fBmRKH3MkigfHIa4FshIuA
# bofd9A0CAWQCAQMwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeA
# MBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFOELHzM3guIY
# CdEVMdyGatFOu+WNMB8GA1UdIwQYMBaAFJgCWbTikt4gs3GmP4trHjb9214qMIIB
# dQYDVR0fBIIBbDCCAWgwggFkoIIBYKCCAVyGgctsZGFwOi8vL0NOPW9wZW4tdGVj
# aHMtT1RTLUNPUlAtREMyLUNBLENOPU9UUy1DT1JQLURDMixDTj1DRFAsQ049UHVi
# bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
# bixEQz1vcGVuLXRlY2hzLERDPWxvY2FsP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxp
# c3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIZOaHR0cDov
# L09UUy1DT1JQLURDMi5vcGVuLXRlY2hzLmxvY2FsL0NlcnRFbnJvbGwvb3Blbi10
# ZWNocy1PVFMtQ09SUC1EQzItQ0EuY3JshjxodHRwOi8vZGEub3Blbi10ZWNocy5j
# b20vY3JsZC9vcGVuLXRlY2hzLU9UUy1DT1JQLURDMi1DQS5jcmwwggFQBggrBgEF
# BQcBAQSCAUIwggE+MIG+BggrBgEFBQcwAoaBsWxkYXA6Ly8vQ049b3Blbi10ZWNo
# cy1PVFMtQ09SUC1EQzItQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZp
# Y2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9b3Blbi10ZWNocyxE
# Qz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTB7BggrBgEFBQcwAoZvaHR0cDovL09UUy1DT1JQLURDMi5v
# cGVuLXRlY2hzLmxvY2FsL0NlcnRFbnJvbGwvT1RTLUNPUlAtREMyLm9wZW4tdGVj
# aHMubG9jYWxfb3Blbi10ZWNocy1PVFMtQ09SUC1EQzItQ0EoMykuY3J0MDIGA1Ud
# EQQrMCmgJwYKKwYBBAGCNxQCA6AZDBdjbXVlc2luZ0BvcGVuLXRlY2hzLmNvbTAN
# BgkqhkiG9w0BAQsFAAOCAgEAsoaRGhnpLPeDRu3HGGrxHpG1pSpMbcLLIEMnilOu
# 8IFzS2sXbkQKr9X7/5obtJjdLEv/c0Bog8dy18vl3XPUXTeSHHxzIRMXRUVgVvVt
# m6U51XGb81RnjLjOsOmiMNVmVi1wBXwMWKbtwUNJJgHC8tARSJpoqd5Gnp0tHKC4
# l+Kc6FekME0zk2smp9SpsuKR4DtBQ5GhDyqNzus6/OxbGUluxwW+OtwF/I9uLL02
# 7D0bPyB/VtApBKBQoXyn955tYArdaSeLAvnjmGoCEaxZQTJZG0T3O+kBUiIyGf4Q
# mThaAYuBh3P4TQLuCmz/lsKcedlWRtqBP/94C1BvTQNZbri1XNbU2jSVlDrW/gjD
# 1/ZirVXXxQS730YXJODpVVZCKB5wB35j5ARPpeXADr913KkicA3JG6UZ5puDeHPt
# mIdLy+JGJQtbBcH7j9ScRkNwph/CNd9CIvAzUB6XV2mvAo7imY7s3ymzHRG0IALk
# t+Y3pfTtulTdxMX4s8ttcUATCdpACEnU0UYQoiiMvMdZkVgltqMdr7hFRWkfb7zZ
# qyEPeBJ5In91LR2ioRSuEsi67KRB7F+v5yvhDq8ID9RXB38KZCLol4WysVE96sN0
# 3oICilZLq7UamHM3dIGn/qcgT4E070Cv4274lrAp0u+Xua+mvdzmDWUWLsSKxwDK
# Q7oxggIQMIICDAIBATBvMFgxFTATBgoJkiaJk/IsZAEZFgVsb2NhbDEaMBgGCgmS
# JomT8ixkARkWCm9wZW4tdGVjaHMxIzAhBgNVBAMTGm9wZW4tdGVjaHMtT1RTLUNP
# UlAtREMyLUNBAhMeAAO3dX6KcPCxWoJkAAMAA7d1MAkGBSsOAwIaBQCgeDAYBgor
# BgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEE
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRe
# d+vdIeHHYEwAdPvo7no438UK0jANBgkqhkiG9w0BAQEFAASCAQBRrgIa4MrDl0Wa
# gFRKIXzKEgoW5v0yY3o2lXR7h3PZBiZSbkHf2cSu/o6elSAPviE7aVaIPhIix7pI
# cK5USzLEraJZMWpZHNAKCyzyol0sLZIPLyZexgDszSNQ7WLTFOzP4wMa/GGs7Aft
# IPLCEtBvZKOTX5aePwke1SI9eGBU9+k08Y41gJtWnyNTC8nhaEm7t4FRlEdIM/NO
# HhhmOrC9Lang7IPG/d6FS8DNJqc8mKtIWEL+ngpblvaQ94FLyHTH3rmxDHWg2Xfe
# VwRd/N8OOom4JWZ/oAHQaqvK2Ena/yEGNOmFQdQTG4hbD4Oj88ATTme6LVyvIrQd
# kGOrrGs7
# SIG # End signature block
