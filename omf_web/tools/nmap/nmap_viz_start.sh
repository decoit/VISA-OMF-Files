#!/bin/bash -l

SOURCE="/tmp/$1.sq3"
DEST="./data_sources/db.sq3"

cp -r $SOURCE $DEST

sqlite3 /tmp/$1.sq3 'select fingerprint from nmap_os' > ./repository/fingerprint.md

rvm use 1.9.3-p286@omf
sleep 1
ruby -I../../lib ./nmap_viz_server.rb start

