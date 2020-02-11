### Configure NTP Server on Windows

1. Open the local Group Policy Editor (`gpedit.msc`)
2. Navigate to `Administrative templates` -> `System` -> `Windows Time Service` -> `Time Providers`
3. Open `Enable Windows NTP Server`, then select `Enabled` and click `OK`
4. Navigate back to the `Windows Time Service` window
5. Open `Global Configuration Settings`, then select `Enabled`
6. Review the [_Windows Time Service_ docs](https://docs.microsoft.com/en-us/windows-server/networking/windows-time-service/windows-time-service-tools-and-settings) and update settings, then click `OK`
7. Validate and update any Windows Firewall settings, if needed
- To add a new rule, issue the following command in an administrative PowerShell console:
- `New-NetFirewallRule -DisplayName "NTP Server UDP 123" -Direction Inbound -LocalPort 123 -Protocol UDP -Action Allow -RemoteAddress LocalSubnet`

8. In an administrative PowerShell console, issue:
- `Start-Service w32time`
