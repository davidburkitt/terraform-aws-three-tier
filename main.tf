# REPLACE LC with Launch Template and Classic LB with ALB
# Add scaling policy e.g. target tracking (coudwatch alarm automated) or step scaling (manual cloudwatch alarm)
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    encrypt = true
    bucket = "tf-aws-demo-1-state"
    dynamodb_table = "tf_aws_demo_1_locktable"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}

data "aws_availability_zones" "all" {}

locals {
  ts = formatdate("hhmmssDDMMYYYY", timestamp())
}

provider "aws" {
  region = "us-east-2"
  version = "~> 2.52"
  shared_credentials_file = var.aws_creds
  #access_key = var.aws_access
  #secret_key = var.aws_secret
}

resource "aws_key_pair" "tf_aws_demo_1" {
  count = 0 # i.e. don't create any - as we're using an existing key pair from the local system which has already been setup in the console
  key_name   = "tf_aws_demo_1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2bmr+Y+fDbDJ5oV7hZDG3wUM0ftpbNSvz5BlBNJYUy8LF5wiUDdlG1Ht/zk5A0CoFHB6lXOsOUrlApsHA4/lseKq9Xs8z2Vv4XIYhfn2FUUxIXnXqmQBUqHo3PHaDFJ0GJnhHu4yPFVFRrGnnlzGdneChcHpuxky7AD8lFYc4zELQdmKYTToB+rbgrCgcZEZQ8/HcLD95G6Y5U59zQVzPuBXY4QMdO4KP3Pwtg9b1jS5RYxTvb1OfoYW/JDcnNnGpEn9+CnVeZHjCob2WNHGw/3XNZTrGhTN/8iABP6lJYWSJHx0U2pIiRp63lfQXT+ZSWlHu/+d7Rchp0NmyJRlb tf_aws_demo_1_ssh_key"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "tf_aws_demo_1" {
  image_id = var.aws_ami
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tf_aws_demo_1_ec2_sg.id]
  #key_name = "tf_aws_demo_1"
  key_name = "MacBook"
  user_data = "${file("ec2_user_data.sh")}"
  iam_instance_profile = "EC2-Demo"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "tf_aws_demo_1_elb_sg" {
  name = "tf_aws_demo_1_elb_sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "tf_aws_demo_1_ec2_sg" {
  name = "tf_aws_demo_1_ec2_sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    self = true
    security_groups = [aws_security_group.tf_aws_demo_1_elb_sg.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "tf_aws_demo_1" {
  availability_zones = data.aws_availability_zones.all.names
  launch_configuration = aws_launch_configuration.tf_aws_demo_1.id

  min_size = 1
  max_size = 1

  load_balancers = [aws_elb.tf_aws_demo_1.name]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "tf_aws_demo_1"
    propagate_at_launch = true
  }
}

resource "aws_elb" "tf_aws_demo_1" {
  name = "tfawsdemo1"
  security_groups = [aws_security_group.tf_aws_demo_1_elb_sg.id]
  availability_zones = data.aws_availability_zones.all.names

  listener {
    lb_port = 8080
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 10
    interval = 30
    target = "HTTP:8080/"
  }
}
