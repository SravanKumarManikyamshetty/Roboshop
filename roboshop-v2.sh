#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z06319852Q2KMY0JQH97T"
DOMAIN_NAME="sravan.site"

if [ $# -le 2 ]; then
    echo "these file required 2 or more arguments"
    echo "sh $0 < create/delete > < second argu >"
    exit 1
else
    if [ "$1" != "create" ] && [ "$1" != "delete" ]; then
        echo " first argument sould always be either create nor delete"
    else
        echo " $1 "
    fi

    echo " $# "

fi