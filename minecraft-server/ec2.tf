resource aws_instance server {
  ami = data.aws_ami.server.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.volume_size
    delete_on_termination = true
  }
  key_name = data.terraform_remote_state.minecraft_infra.outputs.public_key_name
  iam_instance_profile = aws_iam_instance_profile.server.name
  vpc_security_group_ids = [data.terraform_remote_state.minecraft_infra.outputs.security_group_id]
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_ids[0]
  associate_public_ip_address = true
  tags = merge({Name = var.name }, var.tags)
  volume_tags = merge({Name = var.name }, var.tags)
  user_data = <<USER_DATA
#!/bin/bash
set -x

export SERVER_NAME=${var.name}
export DATA_BUCKET=${data.terraform_remote_state.minecraft_infra.outputs.data_bucket_id}

# Install java 16, jq
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-headless jq

env >/home/ec2-user/cloud-init.env
cat >/home/ec2-user/change-set.json <<JSON
{
  "Comment": "Move domain to holding",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${var.name}.${data.terraform_remote_state.dns.outputs.hosted_zone_name}",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$(dig +short start.${data.terraform_remote_state.dns.outputs.hosted_zone_name} | head -1)"
          }
        ]
      }
    }
  ]
}
JSON
cat >server.sh <<SCRIPT
#!/bin/bash
set -x
export AWS_DEFAULT_REGION=${var.aws_region}
export HOSTED_ZONE_ID=${data.terraform_remote_state.dns.outputs.hosted_zone_id}
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

cd /home/ec2-user
aws s3 cp "s3://$${DATA_BUCKET}/$${SERVER_NAME}.tar.gz" "$${SERVER_NAME}.tar.gz"
tar -xzvf "$${SERVER_NAME}.tar.gz"
rm "$${SERVER_NAME}.tar.gz"
(
  cd "$${SERVER_NAME}"
  java -Xmx${var.memory} -Xms${var.memory} -jar server.jar
)
tar -czvf "$${SERVER_NAME}.tar.gz" "$${SERVER_NAME}"
aws s3 cp "$${SERVER_NAME}.tar.gz" "s3://$${DATA_BUCKET}/$${SERVER_NAME}.tar.gz"

# Move route53 to holding, release Elastic IP
ADDRESS_DATA=\$(aws ec2 describe-addresses --filter "Name=instance-id,Values=\$INSTANCE_ID")
ASSOCIATION_ID=\$(echo "\$ADDRESS_DATA" | jq -r '.Addresses[].AssociationId')
ALLOCATION_ID=\$(echo "\$ADDRESS_DATA" | jq -r '.Addresses[].AllocationId')

aws route53 change-resource-record-sets --hosted-zone-id "\$HOSTED_ZONE_ID" --change-batch file:///home/ec2-user/change-set.json
aws ec2 disassociate-address --association-id "\$ASSOCIATION_ID"
aws ec2 release-address --allocation-id "\$ALLOCATION_ID"

DATE="\$(date -u --iso-8601=seconds)"
journalctl -t cloud-init | aws s3 cp - "s3://$${DATA_BUCKET}/$${SERVER_NAME}/logs/$${DATE}.txt"

shutdown -h now
SCRIPT
chmod +x server.sh
screen -dm -L -S minecraft ./server.sh
USER_DATA
}

resource aws_iam_role server {
  name = "${var.name}-server"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource aws_iam_policy server {
  name = "${var.name}-server"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListObjectsInBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": ["${data.terraform_remote_state.minecraft_infra.outputs.data_bucket_arn}"]
    },
    {
      "Sid": "AllObjectActions",
      "Effect": "Allow",
      "Action": "s3:*Object",
      "Resource": ["${data.terraform_remote_state.minecraft_infra.outputs.data_bucket_arn}/*"]
    },
    {
      "Sid": "AllowUpdateRoute53",
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetChange",
        "route53:ListResourceRecordsSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/${data.terraform_remote_state.dns.outputs.hosted_zone_id}"
    },
    {
      "Sid": "AllowUpdateEIP",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAddresses",
        "ec2:DisassociateAddress",
        "ec2:ReleaseAddress"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource aws_iam_role_policy_attachment server {
  role = aws_iam_role.server.name
  policy_arn = aws_iam_policy.server.arn
}

resource aws_iam_instance_profile server {
  name = "${var.name}-minecraft-server"
  role = aws_iam_role.server.name
}

data aws_ami server {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
