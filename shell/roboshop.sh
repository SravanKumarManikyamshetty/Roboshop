#!/bin/bash


AMI=ami-0220d79f3f480ecf5


instanceid=(aws ec2 run-instances \
    --image-id $AMI \
    --instance-type t3.micro \
    --security-group-ids "roboshop-common" "roboshop-$1" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$1}]" \
    --query 'Instances[0].InstanceId' \
    --output text
    )
    echo "Intance Id: $instanceid "
