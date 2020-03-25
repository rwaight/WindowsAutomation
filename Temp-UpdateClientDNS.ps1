####### Update Client DNS
# Version 0.1
# Reference: https://docs.microsoft.com/en-us/powershell/module/dnsclient/set-dnsclientserveraddress
# Temporarily set the DNS server for a Windows system to a predetermined DNS server until
#   the user allows the script to finish, which will reset the DNS server for the windows system
#   to the default DNS server addresses specified by DHCP on the selected interface
# Use case: Troubleshoot local DNS server issues
$tempDNS="8.8.8.8","208.67.220.220"
Write-Host "In PowerShell, use `Get-DnsClientServerAddress` to identify the interface to update"
Write-Host "This script assumes the first returned object is the interface that will be updated"
Write-Host "Modify the script if a different interface should be updated"
Pause
#Get-DnsClientServerAddress
$result=Get-DnsClientServerAddress | Select -First 1
$targetInterface=$result.InterfaceIndex
Set-DnsClientServerAddress -InterfaceIndex $targetInterface -ServerAddresses $tempDNS
Get-DnsClientServerAddress | Select -First 1
Write-Host "The DNS server for interface $targetInterface has been set to $tempDNS"
Write-Host "When you are ready for the DNS server to be reset -- " -NoNewLine; Pause
Set-DnsClientServerAddress -InterfaceIndex $targetInterface -ResetServerAddresses
Get-DnsClientServerAddress | Select -First 1
Write-Host "When you are ready to exit the script -- " -NoNewLine; Pause
