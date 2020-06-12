#!/bin/bash
##
## Description: Back up bitwarden_rs data to Dropbox.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##
## Usage: ./bw_backup.sh [--all|--db]
##   --all  back up all data
##   --db   back up database only (default)
##

DROPBOX="$HOME/Dropbox/BitWBackups"

# Back up all data.
backup_all () {
	DATA_FOLDER="/opt/bitwarden_rs"
	BACKUP_FILE="bitwarden_rs_$(date "+%F-%H%M%S")"

	cd $DATA_FOLDER
	tar -czf $DROPBOX/$BACKUP_FILE.tgz ./*

	~/.dropbox-dist/dropboxd &> /dev/null &

	sleep 30

	pkill dropbox
}

# Back up database only.
backup_db () {
	DATA_FOLDER="/opt/bitwarden_rs/bw-data"
	BACKUP_FILE="db.sqlite3_$(date "+%F-%H%M%S")"

	if [[ ! -d $DATA_FOLDER/db-backup ]]; then
		mkdir $DATA_FOLDER/db-backup
	fi
	
	sqlite3 $DATA_FOLDER/db.sqlite3 ".backup '$DATA_FOLDER/db-backup/db.sqlite3'"

	cd $DATA_FOLDER/db-backup
	tar -czf $DROPBOX/$BACKUP_FILE.tgz db.sqlite3
	cd && rm -f $DATA_FOLDER/db-backup/*
	
	~/.dropbox-dist/dropboxd &> /dev/null &

	sleep 30

	pkill dropbox
}

# Delete old backups.
backup_del () {
	count=`ls ${DROPBOX} | wc -l`
	while [[ ${count} -gt 7 ]]; do
		ls -t ${DROPBOX} | tail -n 1 | xargs -i rm -f ${DROPBOX}/{}
		count=$(( ${count} - 1 ))
	done
}

case "$1" in
	--all) backup_all ;;
	--db|'') backup_db ;;
	*) echo "Unrecognized option '$1'" ;;
esac

backup_del