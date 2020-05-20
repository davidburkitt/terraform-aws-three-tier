output "unique-name-prefix" {
  value = local.ts
}

output "aws_creds" {
  value = var.aws_creds != "~/.aws/credentials" ? "${var.aws_creds} (parameterised)" : "${var.aws_creds} (default value)"
}

output "aws_ami" {
  value = var.aws_ami
}

output "public_dns" {
  value = "${aws_elb.tf_aws_demo_1.dns_name}:8080"
}

