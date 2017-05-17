# Get accounts in a specific OU that are set to Expire
Import-Module ActiveDirectory
function Get-AccountsWithExpiration {
   Param ([string]$OUDN)

   $users = Get-ADUser -SearchBase $OUDN -Filter * -Properties *
   Write-Host "Accounts with an ExpirationDate:" -ForegroundColor red

   ForEach ($u in $users.SamAccountName) {
     $expiration = Get-ADUser $u -Properties * | select AccountExpirationDate
     if ($expiration.AccountExpirationDate){
       Write-Host $u -ForegroundColor red
     }
   }

}
