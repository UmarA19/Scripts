Connect-Graph -Scopes "User.Read.All", "GroupMember.Read.All"
Get-MgUserMemberOf -UserId "sarah.donnison@onmo.app" | ForEach-Object { Get-MgGroup -GroupId $_.Id | Select-Object DisplayName, Id }

# List group name and group ID 


