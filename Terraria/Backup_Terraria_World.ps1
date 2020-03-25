# ------------------------------------------------------------------------------
# Script  : Backup_Terraria_World.ps1
# Author  : Robert (Rob) Waight
# Date    : 3/24/2020
# Version : 0.1
# Keywords: Terraria Server, TShock Terraria Server, Terraria World Backups
# Comments: Create a backup of a specified Terraria world with a different
#             extension than `.wld.bak` and including a date/timestamp.
#             This script is helpful when your kids are home from school and you
#             need to create a point-in-time backup of the Terraria world.
#             
#             This script should be run as a scheduled task on an interval.
#
# Command line options: https://tshock.readme.io/docs/command-line-parameters
# ------------------------------------------------------------------------------

$terrariaWorlds="T:\Path\To\Terraria\Worlds"
$targetWorld="myWorld"
$backupExt=".myBackups"

# Write to the Windows Application log
$LogSource="Terraria_World_Backup"
New-EventLog -LogName Application -Source $LogSource

# Event Log function
function EventLog($String, $EventID, $Color){
    if ($Color -eq $null) {$Color = "white"}
    Write-Host $String -ForegroundColor $Color
    Write-EventLog Application -Source $LogSource -EventID $EventID -Message $String
}

EventLog "Starting Backup_Terraria_Worlds.ps1 at $(get-date)" 1
$worldBackup=$terrariaWorlds+"\"+$targetWorld+".wld.bak"
$targetLatest=$terrariaWorlds+"\"+$targetWorld+".wld.*"+$backupExt
$latestBackup=Get-ChildItem -Path $targetLatest | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latestName=$latestBackup.name
EventLog "The latest backup is: $latestName" 1

if(Compare-Object -ReferenceObject $(Get-Content $worldBackup) -DifferenceObject $(Get-Content $latestBackup))
  {
    EventLog "Creating a new backup file!" 3 Yellow
    EventLog "The current backup file is different from: $latestName" 3 Yellow
    $newBackup=$terrariaWorlds+"\"+$targetWorld+".wld."+$(Get-Date -format 'yyyyMMdd-HHmm')+$backupExt
    Copy-Item $worldBackup -Destination $newBackup
    EventLog "Copied the current world backup to: $newBackup" 3 Yellow
  }
  else{EventLog "The current backup file is the same as $latestName" 2 Yellow}

EventLog "Finished Backup_Terraria_Worlds.ps1 at $(get-date)" 1
