#AzureADRoster.ps1

#Exports a full list of all users in AzureAD

param(
    [string] $path = "AzureADRoster_$(Get-Date -format "MM-dd-yyyy").csv"
)
& {
    foreach($azuser in Get-AzureADUser -All $true -Filter 'accountEnabled eq true') {
        [pscustomobject]@{
            "Employee ID"   = $azuser.ExtensionProperty["employeeId"]
            "First Name"    = $azuser.surname
            "Last Name"     = $azuser.givenName
            "Work Email"    = $azuser.UserPrincipalName
            "Job Title"     = $azuser.JobTitle
            "Department"    = $azuser.CompanyName
            "Manager Email" = (Get-AzureADUserManager -ObjectId $azuser.ObjectId).UserPrincipalName
            "License"       = $azuser.ExtensionProperty["extension_a92a_msDS_cloudExtensionAttribute1"]
        }
    }
}

Export-CSV -Path $path -NoTypeInformation

Function main()
{
 #Check for AzureAD module 
 $Module=Get-Module -Name AzureAD -ListAvailable  
 if($Module.count -eq 0) 
 { 
  Write-Host AzureAD module is not available  -ForegroundColor yellow  
  $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No 
  if($Confirm -match "[yY]") 
  { 
   Install-Module AzureAD 
   Import-Module AzureAD
  } 
  else 
  { 
   Write-Host AzureAD module is required to connect AzureAD.Please install module using Install-Module AzureAD cmdlet. 
   Exit
  }
 } 
 Write-Host Connecting to AzureAD...
 #Storing credential in script for scheduling purpose/ Passing credential as parameter  
 if(($UserName -ne "") -and ($Password -ne ""))  
 {  
  $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force  
  $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword  
  Connect-AzureAD -Credential $credential 
 }  
 else  
 {  
  Connect-AzureAD | Out-Null  
  Invoke-Item "$ExportCSV"
 }
}
 . main





