<#
Copyright 2019 Kamber Lee Borders
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

.SYNOPSIS
  Audit and report on inactive users
.DESCRIPTION
  Manage inactive users in your active directory environment.
  You can query for any domain. So this can work the same for multiple domains.
  Set the 'DaysInactive' to query inactivity based off a timespan of your
    chosing.
  Options to move, as well as options to disable the inactive users.
  Options to subscribe to data.
  Subscriptions will send emails to the subscribed like the following:
  "
    Inactive User Count:

    2 - 30 day inactive users were found in the 'foo.bar' domain.
    0 - 0.00 % of inactive users are service accounts.
    0 - 0.00 % of inactive users are admin accounts.


    Disabling statistics:

    2 - 100.00 % of AD Objects were successfully disabled.


    Movement statistics:

    2 - 100.00 % of AD Objects were successfully moved.
  "
.PARAMETER Domain
  - Mandatory
  - String
  - The Domain name where the AD users will be queried from: foobar.com
.PARAMETER DaysInactive
  - Mandatory
  - Integer
  - The amount of days inactive to query
  - Any integer: 30,60,90,91
.PARAMETER ExportLocation
  - Mandatory
  - String - System path
  - Where to output backups used for general backups and reporting
  - Path: '/export', 'C:\export'
  - If the path does not exist - it will be created
.PARAMETER DisableInactive
  - Switch (default $false)
  - Whether or not to disable inactive users
  - Only use this parameter if you want to disable users
.PARAMETER DrillDownOU
  - String (DistinguishedName)
  - Target OU for querying inactive users
.PARAMETER MoveDisabledUsers
  - Switch (default $false)
  - Whether or not to move inactive users
  - Only use this parameter if you want to move users
  - Requires TargetOU otherwise this will fail
.PARAMETER TargetOUDN
  - String (DistinguishedName)
  - Path to Organizational Unit of where to move inactive users
  - Only required if $MoveDisabledUsers is true
.PARAMETER Subscribed
  - Switch (default $false)
  - Whether or not to create a subscription to the run
.PARAMETER Subscribers
  - String (EmailAddress)
  - Email address of subscribers to get data every job
.PARAMETER SendFrom
  - String (EmailAddress)
  - Email address of what mailbox to send the email from
.PARAMETER SMTPServer
  - String
  - SMTP Server name (See Send-MailMessage)
.INPUTS
  None
.OUTPUTS Windows Event Logs, Data
  - Windows Event Log
    - Events will be in the 'Application' log
    - With the 'InactiveUsers' source
    - Event Legend:
        4500 - [Information] Begin execution of InactiveUsers.ps1
        4501 - [Information, Error] Query Active Directory For Inactive Users
        4502 - [Information, Error] Export Inactive Users to ExportLocation
        4503 - [Information, Warning] Disable Inactive Users
        4504 - [Information, Warning] Move Disabled Users
        4505 - [Information] Completion of InactiveUsers.ps1
  - Data Export
    - Data export is the InactiveUsers exported from Active Directory
    - Data will be exorted to the location specified in the $ExportLocation
        parameter.
    - The name of the export will be
        <ExportLocation>\inactiveUsers_<YYYYMMddhhmm>.csv
    - Data will be exported as a CSV
    - The CSV properties are: samaccountname, lastlogondate, emailaddress,
        and distinguishedname
    - Exports will be removed every 30 days
.NOTES
  Version:        1.0
  Author:         Kamber Borders (https://github.com/klborders)
  Creation Date:  3/6/2019
  Purpose/Change: Initial OpenSource Deployment
.EXAMPLE
  Pull 90 day inactive users from foobar.com

  $InactiveUsersSplat = @{
    Domain = 'foobar.com'
    DaysInactive = 90
    ExportLocation = 'C:\Export'
  }
  .\InactiveUsers.ps1 @InactiveUsersSplat 
.EXAMPLE
  Pull 90 day inactive users from foobar.com and email foo.bar@email.com

  $InactiveUsersSplat = @{
    Domain = 'foobar.com'
    DaysInactive = 90
    ExportLocation = 'C:\Export'
    Subscribed = $true
    Subscribers = 'foo.bar@email.com'
    SendFrom = 'noreply@email.com'
    SMTPServer = 'mail.foobar.com'
  }
  .\InactiveUsers.ps1 @InactiveUsersSplat
.EXAMPLE
  Pull 90 day inactive users from foobar.com, disable them, and
  email foo.bar@email.com.

  $InactiveUsersSplat = @{
    Domain = 'foobar.com'
    DaysInactive = 90
    ExportLocation = 'C:\Export'
    Subscribed = $true
    Subscribers = 'foo.bar@email.com'
    SendFrom = 'noreply@email.com'
    SMTPServer = 'mail.foobar.com'
    DisableInactive = $true
  }
  .\InactiveUsers.ps1 @InactiveUsersSplat
.EXAMPLE
  Pull 90 day inactive users from foobar.com, disable them,
  move them to an 'inactiveusers' organizational unit,
  and email foo.bar@email.com

  $InactiveUsersSplat = @{
    Domain = 'foobar.com'
    DaysInactive = 90
    ExportLocation = 'C:\Export'
    Subscribed = $true
    Subscribers = 'foo.bar@email.com'
    SendFrom = 'noreply@email.com'
    SMTPServer = 'mail.foobar.com'
    DisableInactive = $true
    MoveDisabledUsers = $true
    TargetOUDN = 'OU=inactiveusers,DC=foobar,DC=com'
  }
  .\InactiveUsers.ps1 @InactiveUsersSplat

.EXAMPLE
  Pull 90 day inactive users from the 'Users' OU in foobar.com,
  disablethem, move them to an 'inactiveusers' organizational unit,
  and email foo.bar@email.com

  $InactiveUsersSplat = @{
    Domain = 'foobar.com'
    DaysInactive = 90
    ExportLocation = 'C:\Export'
    Subscribed = $true
    Subscribers = 'foo.bar@email.com'
    SendFrom = 'noreply@email.com'
    DrillDownOU = 'OU=Users,DC=foobar,DC=com'
    SMTPServer = 'mail.foobar.com'
    DisableInactive = $true
    MoveDisabledUsers = $true
    TargetOUDN = 'OU=inactiveusers,DC=foobar,DC=com'
  }
  .\InactiveUsers.ps1 @InactiveUsersSplat
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

param (
    [Parameter(Mandatory=$true)]
    [string]$Domain,
    [Parameter(Mandatory=$true)]
    [int]$DaysInactive,
    [Parameter(Mandatory=$true)]
    [string]$ExportLocation,
    [switch]$DisableInactive,
    [string]$DrillDownOU,
    [switch]$MoveDisabledUsers,
    [string]$TargetOUDN,
    [switch]$Subscribed,
    [string[]]$Subscribers,
    [string]$SendFrom,
    [string]$SMTPServer
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module ActiveDirectory

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Global Variables

# Log information
# N/A Using EventLog logging

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Write-InactiveUserLog {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Information','Error','Warning')]
        [string]$EntryType,
        [Parameter(Mandatory=$true)]
        [int]$eventID,
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    if (-Not([System.Diagnostics.EventLog]::SourceExists('InactiveUsers'))) {
        $newLogSplat = @{
            source = 'InactiveUsers'
            LogName = 'Application'
        }
        New-EventLog @newLogSplat
    }
    $writeLogSplat = @{
        LogName = 'Application'
        Source = 'InactiveUsers'
        EventID = $eventID
        EntryType = $EntryType
        Message = $message
    }
    Write-EventLog @writeLogSplat
}

Function Get-InactiveUsers {
    param(
        [string]$Domain,
        [int]$DaysInactive,
        [string]$DrillDownOU
    )
    $days = (get-date).adddays([int]"-$daysinactive")
    $filter = {
        (lastlogondate -le $days) -and
        (enabled -eq $true)
    }
    $properties = @(
        'samaccountname',
        'LastlogonDate',
        'EmailAddress',
        'DistinguishedName'
    )
    $getUsers = @{
        Filter = $filter
        Properties = $properties
        SearchBase = $DrillDownOU
        Server = $Domain
    }
    try {
        $users = Get-ADuser @getUsers | Select-Object $properties
        $message = "Successfully queried $DaysInactive day inactive "+
            "users from the $Domain domain. There are $($users.count) "+
            'inactive users.'
        $4501Splat = @{
            EntryType = 'Information'
            EventID = 4501
            Message = $message
        }
        Write-InactiveUserLog @4501Splat
    }
    catch {
        $message = "Failed to query $DaysInactive day inactive "+
            "users from the $Domain domain. This is a fatal error."
        $4501Splat = @{
            EntryType = 'Error'
            EventID = 4501
            Message = $message
        }
        Write-InactiveUserLog @4501Splat
        exit
    }
    return $users
}


Function Export-InactiveUsers {
	param (
        [array]$InactiveUsers,
		[string]$ExportLocation
	)
	begin {
        if (-Not(Test-Path $ExportLocation)) {
            try {
                New-Item -ItemType Directory -Path $ExportLocation
            }
            catch {
                $message = "Failed to export inactive users due to the "+
                    "inability to create the $ExportLocation export location."
                $4502Splat = @{
                    EntryType = 'Error'
                    EventID = 4502
                    Message = $message
                }
                exit
            }
        }
        $fileName = "inactiveUsers_$(Get-Date -f yyyyMMddhhmm).csv"
        $exportFile = Join-Path $ExportLocation $fileName
        $lim = (Get-Date).AddDays(-30)
        Get-ChildItem -Path $ExportLocation -Recurse -Force |
            Where-Object { 
                (!$_.PSIsContainer) -and
                ($_.CreationTime -lt $lim) -and 
                ($_.name -like 'inactiveUsers*')
            } |
            Remove-Item -Force
    }
	process {
        try {
            $exportSplat = @{
                Path = $exportFile
                NoTypeInformation = $true
            }
            $InactiveUsers | Export-CSV @exportSplat
            $message = "Successfully exported inactive users to $exportFile."
            $4502Splat = @{
                EntryType = 'Information'
                EventID = 4502
                Message = $message
            }
            Write-InactiveUserLog @4502Splat
        }
        catch {
            $message = "[Fatal]: Failed to export inactive users "+
                "to $exportFile."
            $4502Splat = @{
                EntryType = 'Error'
                EventID = 4502
                Message = $message
            }
            Write-InactiveUserLog @4502Splat
            exit
        }
	}
	end {
        return $exportFile
    }
}

Function Disable-InactiveUsers {
    param(
        [string]$Domain,
        [array]$InactiveUsers
    )
    $inactive = $InactiveUsers | Select-Object *,'Disabled'
    foreach ($user in $inactive) {
        try {
            Get-ADUser $user.DistinguishedName -Server $Domain |
                Set-ADUser -Enabled $false
            $user.Disabled = 'true'
        }
        catch {
            $user.Disabled = 'false'
            continue
        }
    }
    $failures = $inactive | Where-Object {$_.Disabled -eq 'false'}
    if ($failures.count -gt 0) {
        [string]$message = ''
        $message += "Failed to disable the following users:`n"
        ForEach ($user in $failures) {
            $message += $user.SamAccountName
        }
        $4503Splat = @{
            EntryType = 'Warning'
            EventID = 4503
            Message = $message
        }
        Write-InactiveUserLog @4503Splat
    }
    else {
        $message = "Successfully disabled $($InactiveUsers.count) "+
            "inactive users."
        $4503Splat = @{
            EntryType = 'Information'
            EventID = 4503
            Message = $message
        }
        Write-InactiveUserLog @4503Splat
    }
    return $inactive
}

Function Move-InactiveUsers {
    param(
        [array]$InactiveUsers,
        [string]$Domain,
        [string]$TargetOU
    )
    $inactive = $InactiveUsers | Select-Object *,'MovedStatus'
    ForEach ($user in $inactive) {
        try {
            $moveSplat = @{
                Identity = $user.DistinguishedName
                TargetPath = $TargetOU
                Server = $Domain
            }
            Move-ADObject @moveSplat
            $user.MovedStatus = 'success'
        }
        catch {
            $user.MovedStatus = 'failure'
            continue
        }
    }
    $failures = $inactive | Where-Object {$_.MovedStatus -eq 'failure'}
    if ($failures.count -gt 0) {
        [string]$message = ''
        $message += "Failed to move the following users:`n"
        ForEach ($user in $failures) {
            $message += $user.SamAccountName
        }
        $4504Splat = @{
            EntryType = 'Warning'
            EventID = 4504
            Message = $message
        }
        Write-InactiveUserLog @4504Splat
    }
    else {
        $message = "Successfully moved inactive users to $TargetOU."
        $4504Splat = @{
            EntryType = 'Information'
            EventID = 4504
            Message = $message
        }
        Write-InactiveUserLog @4504Splat
    }
    return $inactive
}

Function Send-InactiveUsersSubscription {
    param (
        [string[]]$Subscribers,
        [string]$SendFrom,
        [string]$SMTPServer,
        [array]$InactiveUsers,
        [string]$Domain,
        [int]$DaysInactive,
        [string]$ExportedData
    )
    $properties = $inactiveUsers[0].psobject.properties.name

    $message += "Inactive User Count:`n`n"
    if ($inactiveUsers.count -le 0) {
        $message += "No Inactive Users were found in $Domain. `n"
    }
    else {
        $message += "$($inactiveUsers.count) - $DaysInactive day inactive "+
            "users were found in the '$Domain' domain.`n"
        $services = $inactiveUsers |
            Where-Object {$_.samaccountname -like '*svc*'}
        $servAmount = $services.count/$inactiveUsers.count
        $message += "$($services.count) - $($servAmount.tostring("P")) "+
            "of inactive users are service accounts.`n"
        $admins = $inactiveUsers |
            Where-Object {$_.distinguishedName -like '*admin*'}
        $adminAmount = $admins.Count/$inactiveUsers.count
        $message += "$($admins.count) - $($adminAmount.tostring("P")) "+
            "of inactive users are admin accounts.`n`n`n"
    }

    if ($properties -contains 'Disabled') {
        $message += "Disabling statistics:`n`n"
        $failures = $inactiveUsers |
            Where-Object {$_.Disabled -eq 'false'}
        if ($failures.count -gt 0) {
            $failAmount = $failures.count/$inactiveUsers.count
            $message += "$($failures.count) - $($failAmount.tostring("P")) "+
                "of AD Objects failed to be disabled.`n"
        }
        $success = $inactiveUsers |
            Where-Object {$_.Disabled -eq 'true'}
        $scsAmount = $success.count/$inactiveUsers.count
        $message += "$($success.count) - $($scsAmount.toString("P")) "+
            "of AD Objects were successfully disabled.`n`n`n"
    }

    if ($properties -contains 'MovedStatus') {
        $message += "Movement statistics:`n`n"
        $failures = $inactiveUsers |
            Where-Object {$_.MovedStatus -eq 'failure'}
        if ($failures.count -gt 0) {
            $failAmount = $failures.count/$inactiveUsers.count
            $message += "$($failures.count) - $($failAmount.tostring("P")) "+
                "of AD Objects failed to move to the disabled OU.`n"
        }
        $success = $inactiveUsers |
            Where-Object {$_.MovedStatus -eq 'success'}
        $scsAmount = $success.count/$inactiveUsers.count
        $message += "$($success.count) - $($scsAmount.toString("P")) "+
            "of AD Objects were successfully moved.`n`n`n"
    }
    $emailSplat = @{
        From = $SendFrom
        To = $Subscribers
        Subject = 'InactiveUsers.ps1: Data Report'
        Body = $message
        Attachments = $ExportedData
        SMTPServer = $SMTPServer
    }
    Send-MailMessage @emailSplat
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------
$4500Splat = @{
    EntryType = 'Information'
    EventID = 4500
    Message = 'Beginning run of InactiveUsers.ps1.'
}
Write-InactiveUserLog @4500Splat

# Query AD for inactive users
if ([string]::IsNullOrEmpty($DrillDownOU)) {
	$DrillDownOU = (Get-ADDomain $Domain).DistinguishedName
}
$inactiveSplat = @{
    Domain = $Domain
    DaysInactive = $DaysInactive
    DrillDownOU = $DrillDownOU
}
$inactiveUsers = Get-InactiveUsers @inactiveSplat

# Disable inactive users if requested
if ($DisableInactive) {
    $disableInactiveSplat = @{
        Domain = $Domain
        InactiveUsers = $inactiveUsers
    }
    $inactiveUsers = Disable-InactiveUsers @disableInactiveSplat
}

# Move Inactive users if requested
if ($MoveDisabledUsers) {
    $moveSplat = @{
        InactiveUsers = $inactiveUsers
        Domain = $Domain
        TargetOU = $TargetOUDN
    }
    $inactiveUsers = Move-InactiveUsers @moveSplat
}

# Export inactive users to exportlocation
if ($inactiveUsers.count -gt 0) {
    $exportSplat = @{
        InactiveUsers = $inactiveUsers
        ExportLocation = $ExportLocation
    }
    $export = Export-InactiveUsers @exportSplat
}

# Send data to subscribers if requested
if ($Subscribed) {
    $subscriptionSplat = @{
        Subscribers = $Subscribers
        SendFrom = $SendFrom
        SMTPServer = $SMTPServer
        InactiveUsers = $inactiveUsers
        Domain = $Domain
        DaysInactive = $DaysInactive
        ExportedData = $export
    }
    Send-InactiveUsersSubscription @subscriptionSplat
}

$4505Splat = @{
    EntryType = 'Information'
    EventID = 4505
    Message = 'Successfully completed run of InactiveUsers.ps1.'
}
Write-InactiveUserLog @4505Splat
