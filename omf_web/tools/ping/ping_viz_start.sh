#!/bin/bash -l

SOURCE="/tmp/$1.sq3"
DEST="./data_sources/db.sq3"

cp -r $SOURCE $DEST

rvm use ruby-1.9.3-p286@omf
sleep 1
ruby -I../../lib ./ping_viz_server.rb start




