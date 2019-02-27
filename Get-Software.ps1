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
#>

<#
.SYNOPSIS
Return object of installed software on a Windows machine
.DESCRIPTION
Pull a list of software installed on a windows machine including the display
name and version
.EXAMPLE
Get-Software
#>

Function Get-Software {
    $software = @()
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
        'HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($path in $paths) {
        $uninstall = Get-ChildItem -Path $path
        forEach ($keyPath in $uninstall.Name) {
            if ($keyPath -like 'HKEY_LOCAL_MACHINE*'){
                $keyPath = $keyPath.replace('HKEY_LOCAL_MACHINE','HKLM:')
            }
            $registryKey = Get-ItemProperty -path $keyPath
            if(-Not($null -eq $registryKey.DisplayName)) {
                $info = @{
                    DisplayName = $registryKey.DisplayName
                    Version = $registryKey.DisplayVersion
                }
                $softwareObject = New-Object PSObject -Property $info
                $software += $softwareObject
            }
        }
    }
    return $software | Sort-Object -Property DisplayName
}