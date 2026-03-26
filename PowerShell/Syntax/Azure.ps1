#!/bin/bash
#Install Azure AD modules
install-module -name azuread

#Get list of commands for azuread modules
get-command -module azuread

#Get detailed info
get-help -azuread
get-help connect-azuread

#Connecting to Azure resources
Connect-AzureAD