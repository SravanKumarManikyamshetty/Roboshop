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
        exit 1
    else
       for instance in $@
       do
         INSTANCE_ID=$(aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=roboshop-$instance" \
                --query "Reservations[*].Instances[*].InstanceId" \
                --output text   ) 
         if [ -n "$INSTANCE_ID"  ];then 
            echo " instance already created id is :- $INSTANCE_ID"
        else
            echo "Launching instance: $instance"
            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id $AMI_ID \
                --instance-type t3.micro \
                --security-groups "roboshop-common" "roboshop-$instance" \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
            )
            echo "instance ID: $INSTANCE_ID"
        fi
       done
    fi
    echo " number of arguments $#"
fi



 INSTANCE_ID=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=roboshop-$instance" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text   ) 