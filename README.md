# incremental-backup

A script to perform incremental backups over ssh using rsync. This will create hardlinks on the destination when a file is not modified. This saves space but also allows incremental backups that only save the changed files again.

## Instructions
You will need to open the script and modify the readonly variables to fit your needs. Below are the most important ones.
- SOURCE_DIR
  - This is the directory you want to backup. No trailing slash.
- REMOTE_DIR
  - The directory on the remote server where the backup should be created. No trailing slash.
- REMOTE_HOST
  - The remote hostname or IP.
- REMOTE_HOST_PORT
  - The remote host port.

Next you just mark the script executable and run it. If you want, you could add the --dry-run option to the OPTIONS variable for a test.

### Excludes
The file excludes.txt containsa list of items to exclude, one item per line. wildcards can be used. The default one just excludes recycle / trash directories and some windows systems files.
