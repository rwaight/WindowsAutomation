# -----------------------------------------------------------------------------
# Script: Enable-O365Auditing.ps1
# Author: Rob Waight
# Created: 06/25/2018
# Version: 1.0
# Comments: Enable mailbox auditing for use with
#              the Phishing Intelligence Engine (PIE)
#           PIE is available at:  https://github.com/LogRhythm-Labs/PIE
# -----------------------------------------------------------------------------

Start-Transcript $ENV:USERPROFILE\Desktop\Transcript_O365ExchangeAuditing_$(Get-Date -format 'yyyyMMdd-HHmmss').txt; Clear
Write-Host "Your working directory is $pwd" -ForegroundColor Yellow
Write-Host "`nThis script will automatically attempt to audit mailboxes where auditing is disabled!!`n" -ForegroundColor Yellow

# Store credentials in an encoded XML, this file will need to be re-generated whenever the server reboots!
# To generate the XML:
#      PS C:\> Get-Credential | Export-Clixml $ENV:USERPROFILE\Service-Account_cred.xml
$CredentialsFile = "$ENV:USERPROFILE\Service-Account_cred.xml"

$UserCredential = Import-Clixml -Path $CredentialsFile # Comment this line if entering manually credentials at script execution
#$UserCredential = Get-Credential # Comment this line if using an encoded XML

$O365Username=$UserCredential.UserName
# Change the windows title to the username and opening the PSSession to Office 365
Write-Host "Connecting to Office 365 as $O365Username`n"
$host.ui.RawUI.WindowTitle = "PowerShell: O365: $O365Username"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection; Import-PSSession $Session

# Check if Unified Audit Log Ingestion is enabled, set to enabled if it is not enabled
$O365AuditConfig=Get-AdminAuditLogConfig
If($O365AuditConfig.UnifiedAuditLogIngestionEnabled -ne $true){
    Write-Host "Enabling Unified Audit Log Ingestion" -ForegroundColor Yellow
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
}
If($O365AuditConfig.UnifiedAuditLogIngestionEnabled -eq $true){
    Write-Host "Unified Audit Log Ingestion is already enabled!" -ForegroundColor Cyan
}

# Determine how many mailboxes exist
Write-Host "Getting Mailbox Information..." -ForegroundColor Yellow
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox"}
$MailboxCount=$Mailboxes.count
$DatabaseCount = ($Mailboxes | Group-Object {$_.Database}).count
Write-Host "There are $MailboxCount mailboxes and $DatabaseCount mailbox databases in your environment." -ForegroundColor Yellow
Write-Host "`nREMINDER: This script will automatically attempt to audit mailboxes where auditing is disabled!!`n" -ForegroundColor Yellow

# Will mailbox searches be limited?
$title = "Office 365 Exchange Auditing"
$resultsizemessage = "Do you want unlimited mailbox results? (Select No if you want to limit searches to 1000 mailboxes at a time)"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$resultsizechoice=$host.ui.PromptForChoice($title, $resultsizemessage, $options, 0)
If ($resultsizechoice -eq 0){$banner="You selected Unlimited Mailbox search results"}
If ($resultsizechoice -eq 1){$banner="You selected Limited Mailbox searches to 1000 results"}
Write-Host "`n$banner`n" -ForegroundColor Cyan

# Get Mailboxes based on user input
#If ($resultsizechoice -eq 0){$Mailboxes = (Get-Mailbox -ResultSize Unlimited)}
#If ($resultsizechoice -eq 1){$Mailboxes = (Get-Mailbox)}
#$Group = $Mailboxes | Group-Object AuditEnabled,AuditDelegate | Select-Object "Name","Count",@{Name="Account"; Expression={ $_.Group.Identity }}; $Group | Format-Table -AutoSize

# Query O365 for audit enabled mailboxes?
$auditenabledmessage = "Do you want information about mailboxes that are ALREADY being audited?"
$auditenabledchoice=$host.ui.PromptForChoice($title, $auditenabledmessage, $options, 0)
If ($auditenabledchoice -eq 0){
    # Get Mailboxes that ARE enabled for auditing, based on user input
    If ($resultsizechoice -eq 0){$AuditedMailboxes=(Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $true}).Identity}
    If ($resultsizechoice -eq 1){$AuditedMailboxes=(Get-Mailbox -Filter {AuditEnabled -eq $true}).Identity}
    $AMBCount=$AuditedMailboxes.Count
    Write-Host "`n$AMBCount mailboxes have auditing enabled`n" -ForegroundColor Yellow
}

# Get Mailboxes that are not enabled for auditing, based on user input
If ($resultsizechoice -eq 0){$UnauditedMailboxes=(Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $false}).Identity}
If ($resultsizechoice -eq 1){$UnauditedMailboxes=(Get-Mailbox -Filter {AuditEnabled -eq $false}).Identity}
$UAMBCount=$UnauditedMailboxes.Count
Write-Host "`n$UAMBCount mailboxes do not have auditing enabled`n" -ForegroundColor Yellow

If ($UAMBCount -gt 0){
    Write-Host "Attempting to enable auditing on $UAMBCount mailboxes, please wait..." -ForegroundColor Cyan
    $UnauditedMailboxes | % { Set-Mailbox -Identity $_ -AuditDelegate SendAs,SendOnBehalf,Create,Update,SoftDelete,HardDelete -AuditEnabled $true }
    Write-Host "Finished attempting to enable auditing on $UAMBCount mailboxes." -ForegroundColor Yellow

    # Check for more unaudited mailboxes?
    $auditupdatemessage = "Do you want to see how many mailboxes do not have auditing enabled?"
    $auditupdatechoice=$host.ui.PromptForChoice($title, $auditupdatemessage, $options, 0)
    If ($auditupdatechoice -eq 0){
        # Get Mailboxes that are not enabled for auditing, based on user input
        If ($resultsizechoice -eq 0){$UnauditedMailboxes=(Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $false}).Identity}
        If ($resultsizechoice -eq 1){$UnauditedMailboxes=(Get-Mailbox -Filter {AuditEnabled -eq $false}).Identity}
        $UAMBCount=$UnauditedMailboxes.Count
        Write-Host "$UAMBCount mailboxes do not have auditing enabled" -ForegroundColor Yellow
    }
}
If ($UAMBCount -eq 0){Write-Host "`nNo actions to perform, all mailboxes have auditing enabled!"}

Write-Host "`nClosing the PSSession to Office 365, please re-run the script if you wish to enable auditing on more mailboxes" -ForegroundColor Yellow
Pause; Remove-PSSession $Session; Stop-Transcript
