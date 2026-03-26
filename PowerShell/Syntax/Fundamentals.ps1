"Things to remember about powershell scripting"

1. By defual Powershell will not run scripts ".ps1, .psm1, .ps1xml files"
2. Default application for ps1 files are notepad
3. To run a script you need to specify the full path to the script

"Execution Policies"
Restricted = Default policy in PowerShell
RemoteSigned = Will run only scripts created locally
AllSigned = Will only run if its be digitally signed by a certificate
Unrestricted = Good for lab and testing will let powershell run any script
ByPass = Like unrestricted

#How to set the desired PowerShell execution policie on a machine
Set-ExecutionPolicy "Policy" 
#Example 
Set-ExecutionPolicy RemoteSigned

#To see what policy is set
Get-ExecutionPolicy




