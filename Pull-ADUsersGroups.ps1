# -----------------------------------------------------------------------------
# Script  : Pull-ADUsersGroups.ps1
# Author  : Robert Waight
# Date    : 01/21/2016
# Keywords: Active Directory, User reporting, Group reporting
# Comments: Run this in a scheduled task to generate auditable AD User data
#
# -----------------------------------------------------------------------------

Function Pull-ADUsersGroups{
<#
.DESCRIPTION
    Gets all the users group information from Active Directory and outputs specified properties to a csv

.EXAMPLE
    .\Pull-ADUsersGroups.ps1
#>

  Import-Module ActiveDirectory
  #$datetime=Get-Date -format "yyyyMMddTHHmmss"
  $datetime=Get-Date -format "yyyyMMdd"
  $OutFile="C:\PowerShell\ADAutomation\ADUsers-Groups_$datetime.csv"

  $userGrp=Get-ADUser -Filter * -Properties SamAccountName,DisplayName,MemberOf,Enabled | % {
    New-Object PSObject -Property @{
      SamAccount = $_.SamAccountName
      Enabled = $_.Enabled
      UserName = $_.DisplayName
      Groups = ($_.MemberOf | Get-ADGroup | Select -ExpandProperty Name) -join ";"
    } # end of: New-Object PSObject
  } | Select SamAccount,UserName,Enabled,Groups # end of: $userGrp=Get-ADUser

  $userGrp | Export-CSV $OutFile -NoTypeInformation
  Write-Host -ForegroundColor Cyan "Pull-ADUsersGroups finished!"
} # end of: Function Pull-ADUsersGroups

Pull-ADUsersGroups
