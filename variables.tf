variable "public_key_path" {
  default = "~/.ssh/id_rsa_mcgonagle_redhat.pub"
}

variable "key_name" {
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

variable "aws_amis" {
  default = {
    us-east-1 = "ami-2051294a"
  }
}

variable "availability_zones" {
  default = "us-east-1b,us-east-1c,us-east-1d,us-east-1e"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default = "1"
}

variable "instance_type" {
  default = "t2.micro"
  description = "AWS instance type"
}
