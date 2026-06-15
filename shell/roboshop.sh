#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z06319852Q2KMY0JQH97T"
DOMAIN_NAME="sravan.site"

for instance in $@
do
        INSTANCE_ID=$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=roboshop-$instance" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text   ) 
        if [ -z "$INSTANCE_ID"  ];then 
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

    #####ip for route53 update 
    if [ $instance == "frontend" ];then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text   )
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text   )
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    ######update in Route53
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
        {
            "Comment": "Update A record to new IP",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$RECORD_NAME'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }
    '
done
  