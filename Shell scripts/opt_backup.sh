#!/bin/bash
##
## Description: Back up /opt to Dropbox.
##
## Author: l3e0x7b, <lyq0x7b@foxmail.com>
##

dropbox="$HOME/Dropbox/OptBackups"

if [[ ! -d ${dropbox} ]]; then
	mkdir -p "${dropbox}"
fi

backup () {
	data_folder="/opt"
	backup_file="opt_$(date "+%F-%H%M%S")"

	cd ${data_folder} || exit
	tar -czf "${dropbox}"/"${backup_file}".tgz --exclude=MyPrecious --exclude=containerd ./*

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

backup
backup_del
