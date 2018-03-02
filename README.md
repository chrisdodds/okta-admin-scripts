# Okta Powershell Scripts
Based On Chris Neely's group management logic - https://github.com/chris-neely/okta-admin-scripts

**General Paramaters**

* -org - Your Okta tenant URL. ie tenant.okta.com or tenant.oktapreview.com
* -api_token - Your Okta API token.
* -action - What do you want to do
* -path - The CSV file you are writing to or reading from, depending on the action.

## User Lifecycle Management
Handles user lifecycle tasks.

**Example**: .\manageUsers.ps1 -org "tenant.okta.com" -api_token "0000" -action "activate" -send_email "true" -path "c:\data\users.csv"

**Task Specific Params**

* -send_email - True or false; dictates whether or not the end-user gets an activation/re-activation email.

**Actions**
* activate
* deactivate
* suspend
* unsuspend
* reactivate

## Group Management
Handles group management tasks.

**Example**: .\manageGroups.ps1 -org "tenant.okta.com" -gid "0000" -action "get_members" -api_token "0000" -path "c:\data\groupdata.csv"

**Task Specific Params**

* -gid - https://tenant-admin.okta.com/admin/group/**00000000000000000000**

**Actions**
* get_members - exports group members to a csv file
* add_members - adds members from a csv file to the specified group
* remove_members - removes members in a csv from from the specified group


