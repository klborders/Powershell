<#
.SYNOPSIS
Connect to VCenter Servers.
.DESCRIPTION
This automatically loads vmware modules to set up use for powercli
.PARAMETER server
Define the vcenter server or servers to connect to. If not specified it will
connect to VMwareServer1, VMwareServer2, VMwareServer3, VMwareServer4.
.PARAMETER AllSites
Bool - whether or not to connect to all VCenter sites.
.EXAMPLE
Connect to all sites:
Connect-VCenter -AllSites
Connect to one site:
Connect-VCenter -Server VMwareServer1 -AllSites:$false
#>
  Param (
    [Parameter(
      ParameterSetName='Server'
    )]
    [ValidateSet(
      'VMwareServer1',
      'VMwareServer2',
      'VMWareServer3',
      'VMWareServer4')][string]$Server,
    [Parameter(
      ParameterSetName='AllSites'
    )]
    [switch]$AllSites = $false
  )
  begin {
    $AllServers = @(
      'VMwareServer1',
      'VMwareServer2',
      'VMwareServer3',
      'VMwareServer4',
    )
    import-module vmware.vimautomation.core
  } process {
    if ($AllSites) {
      ForEach ($s in $AllServers) {
        Connect-ViServer $s
      }
    } else {
      Connect-ViServer $Server
    }
  } end {
    if ($? -eq $false) {
      throw $error[0].exception
    }
  }
