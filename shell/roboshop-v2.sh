#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z06319852Q2KMY0JQH97T"
DOMAIN_NAME="sravan.site"

if [ $# -lt 2 ]; then
    echo " these need more than 1 argument"
    exit 1
else
    if [ "$1" != "create" ] && [ "$1" != "delete" ]; then
        echo " first argu always either create or delete "
    else
        echo " $1 "
    fi
    echo " number of arguments $#"
fi