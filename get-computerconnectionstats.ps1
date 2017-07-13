<# This function will allow you to pull all computers within your domain and
test whether or not those computers are online or not. This will output a file
in the HomeDrive directory of both online and offline computers. Offline 
computers will be stored as offline_computers.txt and online computers will be
stored as online_computers.txt #>

# HOW TO USE: Copy and paste the contents of this file into PowerShell and run:
# Get-ComputerConnectionStats
# Yes, it's that simple. Yay.

Function Get-ComputerConnectionStats {

  Import-Module ActiveDirectory
  $online_computers = @()
  $offline_computers = @()
  $servers = (Get-ADComputer -Filter *).name
  ForEach ($s in $servers) {
    if (Test-Connection -ComputerName $s -Quiet){
      write-host "$s is connected" -ForegroundColor Green
      $online_computers += $s
    }
    else {
      write-host "$s is not connected" -ForegroundColor Red
      $offline_computers += $s
    }
  }
  $online_computers | Out-File $env:HOMEDRIVE\online_computers.txt
  $offline_computers | Out-File $env:HOMEDRIVE\offline_computers.txt
}
