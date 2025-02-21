Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"
Get-MgContext

New-MgUser -AccountEnabled `
    -DisplayName "John Doe" `
    -MailNickname "johndoe" `
    -UserPrincipalName "johndoe@TestAccount1919.onmicrosoft.com" `
    -PasswordProfile @{
        Password = "Testpass123!!"
        ForceChangePasswordNextSignIn = $true
    } `
    -UsageLocation "GB" `
    -GivenName "John" `
    -Surname "Doe"