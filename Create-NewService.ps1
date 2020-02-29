# -----------------------------------------------------------------------------
# Script: Create-NewService.ps1
# Author: Rob Waight
# Created: 10/06/2018
# Version: 0.1
# Creates a new service based on user input
#
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-service
# If you are using this script, why not just use the New-Service PowerShell command?
# -----------------------------------------------------------------------------
[CmdLetBinding()]
param( 
    [switch]$svcName,
    [switch]$svcDisp,
    [switch]$svcDesc,
    [switch]$svcStartType,
    [switch]$binPath
)
Start-Transcript $ENV:USERPROFILE\Desktop\Create-NewService_Transcript_$(Get-Date -format 'yyyyMMdd-HHmmss').txt; Clear
$WorkDir = (Get-Item -Path ".\" -Verbose).FullName
Write-Host "I'm writing the transcript to your desktop. Your working directory is $WorkDir" -ForegroundColor Yellow

# Service Name
If ( ! $svcName ){$svc_Name = Read-Host -Prompt 'Enter the service name'}
Else{
  Write-Host "Why aren't you just using the New-Service PowerShell command?" -ForegroundColor Yellow
  $svc_Name = $svcName
  }

# Service Display Name
If ( ! $svcDisp ){$svc_DisplayName = Read-Host -Prompt 'Enter the service display name'}
Else{
  Write-Host "Why aren't you just using the New-Service PowerShell command?" -ForegroundColor Yellow
  $svc_DisplayName = $svcDisp
  }

# Service Description
If ( ! $svcDesc ){$svc_Description = Read-Host -Prompt 'Enter the service description'}
Else{
  Write-Host "Why aren't you just using the New-Service PowerShell command?" -ForegroundColor Yellow
  $svc_Description = $svcDesc
  }

# Service Startup Type
Do {
  If ( ! $svcStartType ){$svc_StartType = Read-Host -Prompt 'Enter the service startup type, options are: Manual, Automatic, Disabled'}
  Else{
    Write-Host "Why aren't you just using the New-Service PowerShell command?" -ForegroundColor Yellow
    $svc_StartType = $svcStartType
    }
  }
  Until(($svc_StartType -eq "Manual") -or ($svc_StartType -eq "Automatic") -or ($svc_StartType -eq "Disabled"))

# Service Binary Path
If ( ! $binPath ){$svc_binPath = Read-Host -Prompt 'Enter the full binary path'}
Else{
  Write-Host "Why aren't you just using the New-Service PowerShell command?" -ForegroundColor Yellow
  $svc_binPath = $binPath
  }

Clear; Write-Host "Your working directory is $WorkDir" -ForegroundColor Yellow


# Exit if the service name already exists
if (Get-Service $svc_Name -ErrorAction SilentlyContinue) {
  Write-Host "The service $svc_Name already exists, re-run the script and try again!" -ForegroundColor Red
  Sleep 3; Pause; Exit
}


Try {
  # Attempt to creat the service
  New-Service -Name $svc_Name -BinaryPathName $svc_binPath `
    -DisplayName $svc_DisplayName -StartupType $svc_StartType -Description $svc_Description
}
Catch { Write-Host "An error occured." -ForegroundColor Red -NoNewline; Sleep 3; Pause }

Write-Host "Getting information about the new service:"; Get-Service -Name $svc_Name

Write-Host "I've written the transcript to your desktop." -ForegroundColor Yellow
Write-Host "The script will exit after you.. " -NoNewLine; Pause
Stop-Transcript; Exit
