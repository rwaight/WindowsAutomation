# -----------------------------------------------------------------------------
# Script: Pull-ADUsersGroups.ps1
# Author: Robert Waight
# Date: 01/21/2016
# Keywords: 
# comments: 
#
# -----------------------------------------------------------------------------

function Pull-ADUsersGroups{

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
	}
} | Select SamAccount,UserName,Enabled,Groups

$userGrp | Export-CSV $OutFile -NoTypeInformation
Write-Host -ForegroundColor Cyan "Pull-ADUsersGroups finished!"
}

Pull-ADUsersGroups