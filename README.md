# incremental-backup

A script to perform incremental backups using rsync. This will create hardlinks on the destination when a file is not modified. This saves space but also allows incremental backups that only save the changed files again.
