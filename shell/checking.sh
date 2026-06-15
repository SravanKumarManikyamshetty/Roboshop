INSTANCE_ID=(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=roboshop-$1" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text   ) 
echo "$INSTANCE_ID"