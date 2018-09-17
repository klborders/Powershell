using namespace System.Collections

# begin region functions


# Function names are based off of the STIG-ID

Function Test-Verify_SV_77809r3_rule {
  Param()
  Begin {
    $domain = (Get-WmiObject win32_computersystem).partofdomain
  }
  Process {
    If (!$domain) {
        $Result = 'Pass'  
    }
    Else {
      $OS = (Get-WmiObject win32_operatingsystem).name
      if ($OS -like '*Enterprise*') {
        $Result = 'Pass'
      }
      else {
        $Result = 'Fail'
      }
    }
  }
  End {
    Return $Result
  }
}

Function Test-SV_77813r4_rule {
  Param()
  Begin {
    $domain = (Get-WmiObject win32_computersystem).partofdomain
  }
  Process {
    If (!$domain) {
      $Result = 'Pass'
    }
    Else {
      If ((Get-TPM).tpmReady) {
        $Result = 'Pass'
      }
      Else {
        $Result = 'Fail'
      }
    }
  }
  End {
    Return $Result
  }
}

Function Test-SV_91779r2_rule {
  Param()
  Begin {
    # 1       {"Legacy BIOS"}
    # 2       {"UEFI"}
    . .\getFirmware.ps1
    $Bios = Get-BiosType
  }
  Process {
    If ($Bios -like 2) {
      $Result = 'Pass'
    }
    Else {
      $Result = 'Fail'
    }
  }
  End {
    Return $Result
  }
}

Function Test-SV_91781r1_rule {
  Param()
  Begin {
    Try {
      $SecureBoot = Confirm-SecureBootUEFI
    }
    Catch {
      Continue
      $Result = 'Fail'
    }
  }
  Process {
    If ($SecureBoot) {
      $Result = 'Pass'
    }
    Else {
      $Result = 'Fail'
    }
  }
  End {
    Return $Result
  }
}

Function Test-SV_77833r1_rule {
  Param()
  Begin {
    $BitLockerVolumes = (Get-BitLockerVolume).ProtectionStatus
    $VolumeResult = New-Object arraylist
  }
  Process {
    ForEach ($BitLockerVolume in $BitLockerVolumes) {
      If ($BitLockerVolume -like 'off') {
        $VolumeResult += 'Fail'
      }
      Else {
        $VolumeResult += 'Pass'
      }
    }
  }
  End  {
    If ($VolumeResult.Contains('Fail')) {
      Return 'Fail'
    }
    Else {
      Return 'Pass'
    }
  }
}

Function Test-SV_77835r3_rule {
  Param()
  Return '[N/A] See NSA Doc: https://www.iad.gov/iad/library/ia-guidance/' +
    'tech-briefs/application-whitelisting-using-microsoft-applocker.cfm'
}

Function Test-SV_77839r6_rule {
  Param()
  Begin {
    $Build = [int64](gwmi win32_operatingsystem).BuildNumber
  }
  Process {
    If ($Build -gt 14393) {
      $Result = 'Pass'
    }
    Else {
      $Result = 'Fail'
    }
  }
  End {
    Return $Result
  }
}

Function Test-SV_77841r4_rule {
  Param()
  Return '[N/A] Validate AntiMalware System is running.'
}

Function Test-SV_77843r2_rule {
  Param()
  Begin {
    $Volumes = (Get-Volume | 
      Where-Object {
        $_.DriveLetter -and ($_.DriveType -eq 'Fixed')
      }).FileSystemType
    $VolumeResult = New-Object arraylist
  }
  Process {
    ForEach ($Volume in $Volumes) {
      If ($Volume -like 'NTFS') {
        $VolumeResult += 'Pass'
      }
      Else {
        $VolumeResult += 'Fail'
      }
    }
  }
  End {
    If ($VolumeResult.Contains('Fail')) {
      Return 'Fail'
    }
    Else {
      Return 'Pass'
    }
  }
}

Function Test-SV_77845r1_rule {
  Param()
  Begin {
    $BootMgrs = bcdedit | Select-String 'Description'
    $BootResults = New-Object arraylist
  }
  Process {
    ForEach ($BootMgr in $BootMgrs) {
      If ($BootMgr -like 'Windows') {
        $BootResults += 'Pass'
      }
      Else {
        $BootResults += 'Fail'
      }
    }
  }
  End {
    If ($BootResults.Contains('Fail')) {
      Return 'Fail'
    }
    Else {
      Return 'Pass'
    }
  }
}

