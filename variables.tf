variable "aws_creds" {
  type = string 
  description = "path to AWS secret and key"
  default = "~/.aws/credentials"
}

#variable "aws_access" {
#  type = string
#  description = "AWS access key"
#}

#variable "aws_secret" {
#  type = string
#  description = "AWS secret key"
#}

variable "aws_ami" {
  type = string
  description = "AMI - please override default Ubuntu."
  default = "ami-0367b500fdcac0edc"
}

variable "aws_region" {
  type = string
  description = "default region"
  default = "us-east-2"
}