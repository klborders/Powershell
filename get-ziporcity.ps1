<#
If you input a City, this will output the Zip Code.
If you input a Zip Code, this will output the city name.

HOW TO USE:
Step 1)
Run this script in PowerShell

Step 2)
PS C:\> Get-ZipOrCity -ZiporCity <your_input>

Step 3)
Profit.
#>

function Get-ZipOrCity {
   Param ($ZiporCity)

  $DataItems = @{
    'San Francisco' = 55551
    'Sacramento' = 55552
    'San Jose' = 55553
    'Los Angeles' = 55554
  }

  $Target_Value = @()
  foreach ($Item in $DataItems.GetEnumerator()) {
    if ($ZiporCity -eq $Item.Name) {
      $Target_Value += [String]$Item.Value
    }
    ElseIf ($ZiporCity -eq $Item.Value) {
      $Target_Value += [String]$Item.Name
    }
    Else {
      Continue
    }
  }
  If ($target_value.Count -gt 0) {
    Write-Host $Target_Value -ForegroundColor Green
  }
  Else {
    Write-Host "Sorry, that location has not been mapped!" -ForegroundColor Red
  }
}
