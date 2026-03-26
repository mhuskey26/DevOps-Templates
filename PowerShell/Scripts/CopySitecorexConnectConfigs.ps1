#set variables
$today = Get-Date -format yyyyMMdd
$ComputerName = hostname

$sharePaths = ('\Websites\xConnect\App_Config\',
            '\Websites\MarketingAutomation\App_Config\',
            '\Websites\MarketingAutomationReporting\App_Config\',
            '\Websites\ReferenceData\App_Config\',
            '\Websites\xconnect\App_Data\jobs\continuous\AutomationEngine\App_Config\',
            '\Websites\xconnect\App_Data\jobs\continuous\IndexWorker\App_Config\'
            )


ForEach ($sharePath in $sharePaths){

    $ToBeCopieds = Get-ChildItem -Path D:$sharePath -include AppSettings.config,ConnectionStrings.config -Recurse

    ForEach ($ToBeCopied in $ToBeCopieds){
            $FileName = ($ToBeCopied | Select-Object Name)
            Copy-Item $ToBeCopied -Destination H:\PS\outputs\$ComputerName\$sharePath -Force
    }
}

$oMachineStore = New-Object System.Security.Cryptography.X509Certificates.X509Store(“My”,”LocalMachine”)
$oMachineStore.Open("ReadOnly")
$oMachineStore.Certificates|select-object Subject,Thumbprint,Issuer|ft -AutoSize -Wrap | Out-File H:\PS\outputs\$ComputerName\Certificates$today.txt

