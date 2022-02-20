<#
.SYNOPSIS
Converts ESD Image to WiM Image
.DESCRIPTION
This will automatically convert an encrypted image (.esd) to an unencrypted
image (.wim). A .wim image can be leveraged to mount the image to modify
the system structure, as this can not be written with an encrypted image.
.PARAMETER ESDPath
String - File path where install.esd is located
.PARAMETER WIMPath
String - File path on where you want your install.wim to be exported to
.PARAMETER ImgName
String - Image Name you would like to specify:
Windows 10 S
Windows 10 S N
Windows 10 Home
Windows 10 Home N
Windows 10 Home Single Language
Windows 10 Education
Windows 10 Education N
Windows 10 Pro
Windows 10 Pro N
.EXAMPLE
Convert-ESDtoWIM
Convert-ESDtoWIM -ESDPath '/iso/install.esd' -WIMPath '/iso/install.wim'
$splat = @{
    ESDPath = '/iso/install.esd'
    WIMPath = '/iso/install.wim'
    ImgName = 'Windows 10 Home'
}
Convert-ESDtoWim @splat
#>

Function Convert-ESDtoWIM {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ESDPath = '/isomedia\sources\install.esd',
        [Parameter(Mandatory=$true)]
        [string]$WIMPath = '/isomedia\sources\install.wim',
        [Parameter(Mandatory=$true)]
        [string]$ImgName = 'Windows 10 Pro'
    )
    Try {
    $Index = Get-WindowsImage -ImagePath $ESDPath |
        Where-Object {$_.ImageName -eq $ImgName} |
        Select-Object -ExpandProperty ImageIndex
    }
    Catch {
        Throw "Failed to capture Index: $($Proc.ExitCode)"
    }

    Try {
        dism /Export-Image`
             /SourceImageFile:$ESDPath`
             /SourceIndex:$Index`
             /DestinationImageFile:$DestinationPath`
             /Compress:Max`
             /CheckIntegrity
    }
    Catch {
        Throw "Failed to Convert $ESDPath to $WIMPath: $($Proc.ExitCode)"
    }
}
