#SystemLog.ps1

<# get a breakdown of recent error sources in the System event log#>

#Set target parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory, HelpMessage = "Enter the DNS or IP of the target network device to pull logs from. Type Local for the local device")]
    [string]$Target, #Set the device target to pull logs from note you need WinRM/Remote Managment enabled for this to run
    [string]$Log = "System",
    [string]$Computername = $Target,
    [int32]$Newest = 1000, #How many recent event logs to pull
    [string]$ReportTitle = "System Log Analysis",
    [Parameter(Mandatory, HelpMessage = "Enter the FilePath for the HTML File.")]
    [string]$Path #Set the export file path target
)

$Target = "Local"
if ($true) {
    $Computername = $env:COMPUTERNAME
}
elseif ($false) {
    $Computername = $Target
}

#Get report data
$ReportDate = Get-Date -Format "dddd_MM_dd_yyyy"
$ReportTime = Get-Date -Format "HH:mm"
$data = Get-Eventlog -logname $Log -EntryType Error -Newest $Newest -ComputerName $Computername | Group Source -NoElement

#Setup HTML Page
$title = "System Log Analysis"
$css = "./sample.css"
$FileTime = Get-Date -Format "_HH_mm"
$FileName = "$ReportDate$FileTime.html"
$precontent = "<H1>$Computername</H1><H2>Last $newest error sources from $Log $Target $ReportDate $ReportTime</H2>"

#Export to HTML
$data | Sort -Property Count,Name -Descending | 
    Select Count, Name | 
    ConvertTo-Html -Title $ReportTitle -PreContent $precontent -CssUri $css | 
    Out-File -FilePath $Path/$FileName

