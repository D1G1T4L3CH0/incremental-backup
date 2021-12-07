#!/bin/bash

# A script to perform incremental backups using rsync. This will create
# hardlinks on the destination when a file is not modified. This saves space but
# also allows incremental backups that only save the changed files again.

# For a new backup, just change the REMOTE_DIR, SOURCE_DIR, and REMOTE_HOST
# variables.

# Maybe add an option to force a backup which will remove that day's backup and
# just do it again. The symlink could just remain the same because it will still
# point to the right location. But the last backup directory name would need to
# be determined and set as the $LATEST_LINK.

## SET VARIABLES ##

# Get the script directory for use later.
readonly SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> \
/dev/null && pwd )"

# The log and excludes file names.
readonly LOG_FILE="${SCRIPT_DIR}/logfile.log"
readonly EXCLUDES_FILE="${SCRIPT_DIR}/excludes.txt"

# What you want to backup. No trailing slash.
readonly SOURCE_DIR="/path/to/directory/to/backup"

# The remote directory to backup into. Must already exist. No trailing slash.
readonly REMOTE_DIR="path/of/direcotry/on/remote/machine/to/backup/to"

# The remote hostname.
readonly REMOTE_HOST="hostname"

# This checks if the host is up. So yes, you do still need to specify the port
# here even if you have the ssh config file setup for the host.
readonly REMOTE_HOST_PORT='22'

#readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly DATE="$(date '+%Y-%m-%d')"
readonly BACKUP_PATH="${REMOTE_HOST}:~/${REMOTE_DIR}/${DATE}"
readonly LATEST_LINK="${REMOTE_DIR}/latest"

readonly OPTIONS="--progress \
                  --recursive \
                  --links \
                  --times \
                  --compress \
                  --human-readable \
                  --delete \
                  --exclude-from=${EXCLUDES_FILE} \
                  --log-file=${LOG_FILE}"

## BEGIN SCRIPT ##

printf 'Checking host and port... '
nc -z ${REMOTE_HOST} ${REMOTE_HOST_PORT}
if [ $? -ne 0 ]
then
	printf 'Aborting. Cannot connect.\n'
	exit
fi
printf 'Seems to be okay.\n'

printf 'Checking if a backup was already ran today... '
ssh ${REMOTE_HOST} [[ -d ~/${REMOTE_DIR}/${DATE} ]] && \
printf 'Already ran a backup today. Exiting.\n' && exit
printf 'No backup for today.\n'

echo 'Starting the rsync (backup) operation.'
rsync ${OPTIONS} \
  "${SOURCE_DIR}/" \
  --link-dest "~/${LATEST_LINK}" \
  "${BACKUP_PATH}"
if [ $? -ne 0 ]
then
        printf 'There was an error. Aborting.'
        exit
fi

printf 'Updating the "latest" symlink... '
ssh $REMOTE_HOST rm -rf "~/${LATEST_LINK}"
ssh $REMOTE_HOST ln -s "~/${REMOTE_DIR}/${DATE}" "~/${LATEST_LINK}"
printf 'Done.\n'

echo 'Script finished.'
