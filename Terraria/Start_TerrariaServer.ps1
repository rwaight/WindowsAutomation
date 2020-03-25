# ------------------------------------------------------------------------------
# Script  : Start_TerrariaServer.ps1
# Author  : Robert (Rob) Waight
# Date    : 3/24/2020
# Version : 1.1
# Keywords: Terraria Server, TShock Terraria Server
# Comments: Start T-Shock 4.3.26 with a modified logpath directory.  No other
#             command line options are issued.  Using a separate logpath is
#             helpful to retain logs when users restart the Terraria server
#
# Command line options: https://tshock.readme.io/docs/command-line-parameters
# ------------------------------------------------------------------------------

$tshockServer="T:\Path\To\TerrariaServer"
$tshockVersion="4.3.26"
cd $tshockServer

# Create the directory for the transcript, if it does not exist
if(-not(Test-Path -path "$tshockServer\logs"))
  {
    Write-Host -ForegroundColor Yellow "The log directory $tshockServer\logs has not been found."
    New-Item -ItemType Directory -Path "$tshockServer\logs" -Confirm
  }

Start-Transcript .\logs\run_terraria-server_$(Get-Date -format 'yyyyMMdd-HHmmss').log
cd ".\tshock_$tshockVersion"

# Create the directory for the server logs, if it does not exist
if(-not(Test-Path -path "$tshockServer\tshock_$tshockVersion\serverLogs"))
  {
    Write-Host -ForegroundColor Yellow "The log directory $tshockServer\tshock_$tshockVersion\serverLogs has not been found."
    New-Item -ItemType Directory -Path "$tshockServer\tshock_$tshockVersion\serverLogs" -Confirm
  }

# Start TShock Terraria Server with a modified logpath directory
Write-Host "Command line options are available at: https://tshock.readme.io/docs/command-line-parameters"
.\TerrariaServer.exe -logpath .\serverLogs\
