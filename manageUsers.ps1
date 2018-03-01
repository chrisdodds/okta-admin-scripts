# Example: .\manageUsers.ps1 -org "tenant.okta.com" -api_token "0000" -action "activate" -path "c:\data\users.csv"

param(
    [Parameter(Mandatory=$true)]$org, 
    [Parameter(Mandatory=$true)]$api_token, 
    [Parameter(Mandatory=$true)]$action,
    [Parameter(Mandatory=$false)]$send_email,
    [Parameter(Mandatory=$true)]$path
    )

$headers = @{"Authorization" = "SSWS $api_token"; "Accept" = "application/json"; "Content-Type" = "application/json"}
$userlist = Import-CSV -Path "$path" -Header "email"

if ($send_email -eq "true") {
    $sendEmail = "true" }
else {
    $sendEmail = "false"
}        

$activateEndpoint = "activate?sendEmail=$sendEmail"
$activateMsg = "activating"
$reactivateEndpoint = "reactivate?sendEmail=$sendEmail"
$reactivateMsg = "reactivating"
$deactivateEndpoint = "deactivate"
$deactivateMsg = "deactivating"
$suspendEndpoint = "suspend"
$suspendMsg = "suspending"
$unsuspendEndpoint = "unsuspend"
$unsuspendMsg = "unsuspending"

switch ($action){
    "activate" { 
        $endpoint = $activateEndpoint
        $taskMsg = $activateMsg
    }
    "reactivate" {
        $endpoint = $reactivateEndpoint
        $taskMsg = $reactivateMsg
    }
    "deactivate" {
        $endpoint = $deactivateEndpoint
        $taskMsg = $deactivateMsg
    }
    "suspend" {
        $endpoint = $suspendEndpoint
        $taskMsg = $suspendMsg
    }
    "unsuspend" {
        $endpoint = $unsuspendEndpoint
        $taskMsg = $unsuspendMsg
    }
}

foreach ($user in $userlist) {
    $email = $user.email
    try {
        $webrequest = Invoke-WebRequest -Headers $headers -Method Get -Uri "https://$org/api/v1/users/$email" -ErrorAction:Stop
        $json = $webrequest | ConvertFrom-Json
        $uid = $json | Select-Object -ExpandProperty id
        

        if ($uid) {
            try {
                $result = Invoke-WebRequest -Headers $headers -Method Post -Uri "https://$org/api/v1/users/$uid/lifecycle/$endpoint" -ErrorAction:Stop
                if ( $result.StatusCode -eq 200 ) { Write-Output "Success $taskMsg $($user.email)" }
            } catch {
                Write-Output "Failed $taskMsg $($user.email) - error: $($_.Exception.Response.StatusCode.Value__)"
            }
        }

    } catch {
        Write-Output "Failed looking up user $($user.email) - error: $($_.Exception.Response.StatusCode.Value__)"
    }
}