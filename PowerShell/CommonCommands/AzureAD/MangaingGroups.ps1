#Azure Active Directory version 2 cmdlets for group management
#https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-settings-v2-cmdlets?view=azureadps-2.0

#Install the Azure AD PowerShell module
install-module azuread
import-module azuread


#To verify that the module is ready to use, use the following command:
get-module azuread


#Connect to the directory
Connect-AzureAD
The cmdlet prompts you for the credentials you want to use to access your directory. In this example, we are using karen@drumkit.onmicrosoft.com to access the demonstration directory. The cmdlet returns a confirmation to show the session was connected successfully to your directory:


#Retrieve groups
To retrieve existing groups from your directory, use the Get-AzureADGroups cmdlet.


#To retrieve all groups in the directory, use the cmdlet without parameters:
get-azureadgroup
The cmdlet returns all groups in the connected directory.


#You can use the -objectID parameter to retrieve a specific group for which you specify the group’s objectID:
get-azureadgroup -ObjectId e29bae11-4ac0-450c-bc37-6dae8f3da61b


#You can search for a specific group using the -filter parameter. This parameter takes an ODATA filter clause and returns all groups that match the filter, as in the following example:
Get-AzureADGroup -Filter "DisplayName eq 'Intune Administrators'"


#Create groups


#To create a new group in your directory, use the New-AzureADGroup cmdlet. This cmdlet creates a new security group called “Marketing":
New-AzureADGroup -Description "Marketing" -DisplayName "Marketing" -MailEnabled $false -SecurityEnabled $true -MailNickName "Marketing"


#Update groups
To update an existing group, use the Set-AzureADGroup cmdlet. In this example, we’re changing the DisplayName property of the group “Intune Administrators.” First, we’re finding the group using the Get-AzureADGroup cmdlet and filter using the DisplayName attribute:
Get-AzureADGroup -Filter "DisplayName eq 'Intune Administrators'"


#Next, we’re changing the Description property to the new value “Intune Device Administrators”:
Set-AzureADGroup -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df -Description "Intune Device Administrators"


#Now, if we find the group again, we see the Description property is updated to reflect the new value:
Get-AzureADGroup -Filter "DisplayName eq 'Intune Administrators'"


#Delete groups
#To delete groups from your directory, use the Remove-AzureADGroup cmdlet as follows:
Remove-AzureADGroup -ObjectId b11ca53e-07cc-455d-9a89-1fe3ab24566b


#Manage group membership


#Add members
#To add new members to a group, use the Add-AzureADGroupMember cmdlet. This command adds a member to the Intune Administrators group we used in the previous example:
Add-AzureADGroupMember -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df -RefObjectId 72cd4bbd-2594-40a2-935c-016f3cfeeeea


#The -ObjectId parameter is the ObjectID of the group to which we want to add a member, and the -RefObjectId is the ObjectID of the user we want to add as a member to the group.

#Get members
#To get the existing members of a group, use the Get-AzureADGroupMember cmdlet, as in this example:
Get-AzureADGroupMember -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df


#Remove members
#To remove the member we previously added to the group, use the Remove-AzureADGroupMember cmdlet, as is shown here:
Remove-AzureADGroupMember -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df -MemberId 72cd4bbd-2594-40a2-935c-016f3cfeeeea


#Verify members
To verify the group memberships of a user, use the Select-AzureADGroupIdsUserIsMemberOf cmdlet. This cmdlet takes as its parameters the ObjectId of the user for which to check the group memberships, and a list of groups for which to check the memberships. The list of groups must be provided in the form of a complex variable of type “Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck”, so we first must create a variable with that type:
$g = new-object Microsoft.Open.AzureAD.Model.GroupIdsForMembershipCheck


#Next, we provide values for the groupIds to check in the attribute “GroupIds” of this complex variable:
$g.GroupIds = "b11ca53e-07cc-455d-9a89-1fe3ab24566b", "31f1ff6c-d48c-4f8a-b2e1-abca7fd399df"


#Now, if we want to check the group memberships of a user with ObjectID 72cd4bbd-2594-40a2-935c-016f3cfeeeea against the groups in $g, we should use:
Select-AzureADGroupIdsUserIsMemberOf -ObjectId 72cd4bbd-2594-40a2-935c-016f3cfeeeea -GroupIdsForMembershipCheck $g


#Disable group creation by your users
You can prevent non-admin users from creating security groups. The default behavior in Microsoft Online Directory Services (MSODS) is to allow non-admin users to create groups, whether or not self-service group management (SSGM) is also enabled. The SSGM setting controls behavior only in the My Apps access panel.

T#o disable group creation for non-admin users:

#Verify that non-admin users are allowed to create groups:
Get-MsolCompanyInformation | fl UsersPermissionToCreateGroupsEnabled

#If it returns UsersPermissionToCreateGroupsEnabled : True, then non-admin users can create groups. To disable this feature:
Set-MsolCompanySettings -UsersPermissionToCreateGroupsEnabled $False

#Manage owners of groups

#To add owners to a group, use the Add-AzureADGroupOwner cmdlet:
Add-AzureADGroupOwner -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df -RefObjectId 72cd4bbd-2594-40a2-935c-016f3cfeeeea
The -ObjectId parameter is the ObjectID of the group to which we want to add an owner, and the -RefObjectId is the ObjectID of the user or service principal we want to add as an owner of the group.

#To retrieve the owners of a group, use the Get-AzureADGroupOwner cmdlet:
Get-AzureADGroupOwner -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df

#If you want to remove an owner from a group, use the Remove-AzureADGroupOwner cmdlet:
remove-AzureADGroupOwner -ObjectId 31f1ff6c-d48c-4f8a-b2e1-abca7fd399df -OwnerId e831b3fd-77c9-49c7-9fca-de43e109ef67

#Reserved aliases
#When a group is created, certain endpoints allow the end user to specify a mailNickname or alias to be used as part of the email address of the group. Groups with the following highly privileged email aliases can only be created by an Azure AD global administrator. 

abuse
admin
administrator
hostmaster
majordomo
postmaster
root
secure
security
ssl-admin
webmaster