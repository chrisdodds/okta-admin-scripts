#Example: .\manageGroups.ps1 -org "tenant.okta.com" -gid "0000" -action "get_members" -api_token "0000" -path "c:\data\groupdata.csv"

param(
    [Parameter(Mandatory=$true)]$org,
    [Parameter(Mandatory=$true)]$gid,
    [Parameter(Mandatory=$true)]$action,  
    [Parameter(Mandatory=$true)]$api_token,
    [Parameter(Mandatory=$true)]$path
    )

$allusers = @()

$headers = @{"Authorization" = "SSWS $api_token"; "Accept" = "application/json"; "Content-Type" = "application/json"}

switch($action){
    "add_members" {
        $method = "Put"
        $taskMsg = "adding"
    }
    "remove_members" {
        $method = "Delete"
        $taskMsg = "removing"
    }
    "get_members"{
        $uri = "https://$org/api/v1/groups/$gid/users"

        do {
            $webresponse = Invoke-WebRequest -Headers $headers -Method Get -Uri $uri
            $links = $webresponse.Headers.Link.Split("<").Split(">") 
            $uri = $links[3]
            $users = $webresponse | ConvertFrom-Json
            $allusers += $users
        } while ($webresponse.Headers.Link.EndsWith('rel="next"'))
    
        $activeUsers = $allusers | Where-Object { $_.status -ne "DEPROVISIONED" }
    
        $activeUsers | Select-Object -ExpandProperty profile | 
            Select-Object -Property email, displayName, primaryPhone, mobilePhone, organization, department | 
            Export-Csv -Path $path -NoTypeInformation
    }
}

if ($action == "add_members" -or $action == "remove_members"){
    $userlist = Import-CSV -Path "$path" -Header "email"
    foreach ($user in $userlist) {
        $email = $user.email
    
        try {
            $webrequest = Invoke-WebRequest -Headers $headers -Method Get -Uri "https://$org/api/v1/users/$email" -ErrorAction:Stop
            $json = $webrequest | ConvertFrom-Json
            $uid = $json | Select-Object -ExpandProperty id
    
            try {
                $result = Invoke-WebRequest -Headers $headers -Method $method -Uri "https://$org/api/v1/groups/$gid/users/$uid" -ErrorAction:Stop
                if ( $result.StatusCode -eq 204 ) { Write-Output "Success $taskMsg $($user.email)" }
            } catch {
                Write-Output "Failed $taskMsg user $($user.email) to group - error: $($_.Exception.Response.StatusCode.Value__)"
            }
        } catch {
            Write-Output "Failed looking up user $($user.email) - error: $($_.Exception.Response.StatusCode.Value__)"
        }
    }
}


