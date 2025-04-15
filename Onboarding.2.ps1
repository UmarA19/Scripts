# Connect to Microsoft Graph (Ensure correct Tenant ID is used)
Connect-MgGraph -Scopes "User.ReadWrite.All", "GroupMember.ReadWrite.All", "Directory.ReadWrite.All"

# Ensure Exchange Online module is installed and loaded
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
}
Import-Module ExchangeOnlineManagement

# Define user details
$FirstName = "Rob"
$LastName = "De Rosa"
$UserPrincipalName = "Rob.DeRosa@onmo.app"  # Ensure 'onmo.app' is a verified domain!
$MailNickname = "robderosa"
$Department = "Operations"

# Set fixed password
$Password = "Testpass123!!"

# Check if user already exists
$ExistingUser = Get-MgUser -Filter "UserPrincipalName eq '$UserPrincipalName'"

if ($ExistingUser) {
    Write-Output "⚠️ User already exists: $UserPrincipalName"
    $User = $ExistingUser
} else {
    Write-Output "✅ User does not exist. Creating user..."

    try {
        # Create user
        $User = New-MgUser -AccountEnabled:$true `
            -DisplayName "$FirstName $LastName" `
            -MailNickname $MailNickname `
            -UserPrincipalName $UserPrincipalName `
            -PasswordProfile @{Password=$Password; ForceChangePasswordNextSignIn=$true} `
            -Department $Department `
            -UsageLocation "GB"

        Write-Output "✅ User created successfully: $UserPrincipalName"
    } catch {
        Write-Error "❌ Failed to create user: $_"
        exit 1
    }
}

# Assign Microsoft 365 Business Premium License
$Sku = Get-MgSubscribedSku | Where-Object {$_.SkuId -eq "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"}

if ($Sku -and $Sku.ConsumedUnits -lt $Sku.PrepaidUnits.Enabled) {
    try {
        Set-MgUserLicense -UserId $User.Id -AddLicenses @(@{SkuId="cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"}) -RemoveLicenses @()
        Write-Output "✅ Microsoft 365 Business Premium license assigned."
    } catch {
        Write-Error "❌ Failed to assign Microsoft 365 Business Premium license: $_"
    }
} else {
    Write-Error "❌ No available Microsoft 365 Business Premium licenses."
}

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName umar.akhtar@onmo.app

# Assign user to the All-Staff Distribution Group using Exchange Online
try {
    Add-DistributionGroupMember -Identity "AllStaff@onmo.app" -Member $UserPrincipalName
    Write-Output "✅ User added to All-Staff distribution list."
} catch {
    Write-Error "❌ Failed to add user to All-Staff distribution list: $_"
}

Write-Output "🎯 Script execution complete."