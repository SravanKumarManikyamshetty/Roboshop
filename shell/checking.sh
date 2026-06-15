INSTANCE_ID=(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=roboshop-$instance" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text   ) 
echo "INSTANCE_ID"