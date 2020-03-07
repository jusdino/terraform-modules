resource "aws_instance" "server" {
  ami = data.aws_ami.server.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  key_name = data.terraform_remote_state.minecraft_infra.outputs.public_key_name
  iam_instance_profile = aws_iam_instance_profile.server.name
  vpc_security_group_ids = [data.terraform_remote_state.minecraft_infra.outputs.security_group_id]
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_ids[0]
  associate_public_ip_address = true
  tags = merge({Name = var.name }, var.tags)
  volume_tags = merge({Name = var.name }, var.tags)
  user_data = <<USER_DATA
#!/bin/bash
export DATA_BUCKET=${data.terraform_remote_state.minecraft_infra.outputs.data_bucket_id}
export SERVER_NAME=${var.name}
yum install -y java-11-amazon-corretto-headless
env >/home/ec2-user/cloud-init.env
cat >server.sh <<SCRIPT
#!/bin/bash
set -x
cd /home/ec2-user
aws s3 cp "s3://$${DATA_BUCKET}/$${SERVER_NAME}.tar.gz" "$${SERVER_NAME}.tar.gz"
tar -xzvf "$${SERVER_NAME}.tar.gz"
(
  cd "$${SERVER_NAME}"
  java -Xmx${var.memory} -Xms${var.memory} -jar server.jar
)
tar -czvf "$${SERVER_NAME}.tar.gz" "$${SERVER_NAME}"
aws s3 cp "$${SERVER_NAME}.tar.gz" "s3://$${DATA_BUCKET}/$${SERVER_NAME}.tar.gz"
shutdown -h now
SCRIPT
chmod +x server.sh
screen -dm -S minecraft ./server.sh
USER_DATA
}

resource "aws_iam_role" "server" {
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

resource "aws_iam_policy" "server" {
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

resource "aws_iam_role_policy_attachment" "server" {
  role = aws_iam_role.server.name
  policy_arn = aws_iam_policy.server.arn
}

resource "aws_iam_instance_profile" "server" {
  name = "minecraft-server"
  role = aws_iam_role.server.name
}

data "aws_ami" "server" {
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
