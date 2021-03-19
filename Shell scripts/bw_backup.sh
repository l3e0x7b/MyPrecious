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

dropbox="$HOME/Dropbox/BitWBackups"

# Back up all data.
backup_all () {
	data_folder="/opt/bitwarden_rs"
	backup_file="bitwarden_rs_$(date "+%F-%H%M%S")"

	cd ${data_folder} || exit
	tar -czf "${dropbox}"/"${backup_file}".tgz ./*

	~/.dropbox-dist/dropboxd &> /dev/null &

	sleep 30

	pkill dropbox
}

# Back up database only.
backup_db () {
	data_folder="/opt/bitwarden_rs/bw-data"
	backup_file="db.sqlite3_$(date "+%F-%H%M%S")"

	if [[ ! -d $data_folder/db-backup ]]; then
		mkdir $data_folder/db-backup
	fi
	
	sqlite3 $data_folder/db.sqlite3 ".backup '$data_folder/db-backup/db.sqlite3'"

	cd $data_folder/db-backup || exit
	tar -czf "${dropbox}"/"${backup_file}".tgz db.sqlite3
	cd && rm -f $data_folder/db-backup/*
	
	~/.dropbox-dist/dropboxd &> /dev/null &

	sleep 30

	pkill dropbox
}

# Delete old backups.
backup_del () {
	count=$(ls "${dropbox}" | wc -l)
	while [[ ${count} -gt 7 ]]; do
		ls -t "${dropbox}" | tail -n 1 | xargs -i rm -f "${dropbox}"/{}
		count=$((count - 1))
	done
}

case "$1" in
	--all) backup_all ;;
	--db|'') backup_db ;;
	*) echo "Unrecognized option '$1'" ;;
esac

backup_del
