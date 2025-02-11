# Define the group name and get the group ID
$groupName = "Monitoring-Standard"
$group = Get-MgGroup -Filter "displayName eq '$groupName'"
$groupId = $group.Id

# Check if the group ID was retrieved
if (-not $groupId) {
    Write-Host "❌ Error: Group '$groupName' not found in Entra ID."
    exit
}

$standardEmails = @(

)

# Get existing members to avoid duplicate errors
$existingMembers = Get-MgGroupMember -GroupId $groupId | Select-Object -ExpandProperty Id

foreach ($email in $standardEmails) {
    try {
        $user = Get-MgUser -Filter "mail eq '$email'"
        
        if ($user) {
            if ($existingMembers -contains $user.Id) {
                Write-Host "🔹 $email is already in Monitoring-Standard"
            } else {
                New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id
                Write-Host "✅ Added $email to Monitoring-Standard"
            }
        } else {
            Write-Host "❌ User not found: $email"
        }
    }
    catch {
        Write-Host "⚠️ Error processing ${email}: $_"
    }
}
