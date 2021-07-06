# -----------------------------------------------------------------------------
# Script  : Backup-GitLab-Docker.ps1
# Author  : Robert Waight
# Date    : 14 February 2021
# Keywords: Docker, GitLab, Backup
# Comments: Run this to backup the GitLab instance running on Docker
#
# -----------------------------------------------------------------------------

$datetime=Get-Date -format "yyyyMMddTHHmmss"

$workingdir="C:\docker\gitlab"

cd $workingdir

# Cleanup old files
# Cleanup old backups (.tar) files
if(test-path -path $workingdir\data\backups\*.tar){
	write-host "cleaning up old backup (tar) files"
	remove-item -path $workingdir\data\backups\*.tar
}

# Cleanup gitlab.rb
if(test-path -path $workingdir\data\backups\gitlab.rb){
	write-host "cleaning up old gitlab.rb file"
	remove-item -path $workingdir\data\backups\gitlab.rb
}

# Cleanup gitlab-secrets.json
if(test-path -path $workingdir\data\backups\gitlab-secrets.json){
	write-host "cleaning up old gitlab-secrets.json file"
	remove-item -path $workingdir\data\backups\gitlab-secrets.json
}

# Execute gitlab-backup against the gitlab container
docker exec -t gitlab gitlab-backup

# Copy gitlab.rb and gitlab-secrets.json to .\data\backups
docker cp gitlab:/etc/gitlab/gitlab.rb .\data\backups\
docker cp gitlab:/etc/gitlab/gitlab-secrets.json .\data\backups\

# Create compressed archive of the GitLab backup files
tar -cvzf ..\backups\gitlab-backup-$datetime.tar.gz .\data\backups

# Validate the GitLab compressed archive exists, then remove old files
if(test-path -path ..\backups\gitlab-backup-$datetime.tar.gz){
    write-host "found gitlab-backup-$datetime.tar.gz , removing files from gitlab\data\backups"
	remove-item -path C:\docker\gitlab\data\backups\*
}

write-host "finished performing gitlab backup"
