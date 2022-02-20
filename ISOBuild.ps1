$Date = Get-Date -Format "yyyyMMddHHmm"
$ISOMediaFolder = '/isomedia'
$ADKPath = '/Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'
$PathToOscdimg = "$ADKPath\Deployment Tools\x86\Oscdimg"
$ISOFile = "/temp\win10vm_$Date.iso"


$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$ISOMediaFolder\boot\etfsboot.com","$ISOMediaFolder\efi\Microsoft\boot\efisys.bin"
  
$procSplat = @{
    FilePath = "$PathToOscdimg\oscdimg.exe"
    ArgumentList = @(
                        "-bootdata:$BootData",
                        '-u2',
                        '-udfver102',
                        "$ISOMediaFolder",
                        "$ISOFile"
                    )
    PassThru = $True
    Wait = $True
    NoNewWindow = $True
}
Try {
    Start-Process @procSplat
} 
Catch {
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}
