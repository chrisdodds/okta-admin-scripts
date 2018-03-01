# Okta Powershell Scripts
Based On Chris Neely's group management logic - https://github.com/chris-neely/okta-admin-scripts

## User Lifecycle Management
* **Example**: .\manageUsers.ps1 -org "tenant.okta.com" -api_token "0000" -action "activate" -send_email "true" -path "c:\data\users.csv"

This support all user lifecycle actions including:
* activate
* deactivate
* suspend
* unsuspend
* reactivate
