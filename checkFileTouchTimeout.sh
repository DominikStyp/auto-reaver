#!/bin/bash

# usage: checkFileTouchTimeout [FILE_PATH] [TIMEOUT]
# output: "1" means timeout has expired, "0" means timeout hasn't expired
checkFileTouchTimeout() {
    local ACTIVITY_FILE=$1;
    local TIMEOUT=$2;
    if [[ ! -f $ACTIVITY_FILE ]]; then 
	echo "$ACTIVITY_FILE doesn't exist";
	exit;
    fi
    local LASTMOD=$(stat -c %X $ACTIVITY_FILE);
    local NOW=$(date +%s);
    local CURRENT_INACTIVITY=$[$NOW-$LASTMOD];
    if [[ $[$NOW] > $[$LASTMOD+$TIMEOUT] ]]; then
	echo "1"; # expired
    else 
	echo "0"; # not expired
    fi
}


checkFileTouchTimeout $1 $2;