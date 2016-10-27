variable "public_key_path" {
  default = "~/.ssh/id_rsa_terraform.pub"
}

variable "key_name" {
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

# F5 Networks Hourly BIGIP-12.1.1.1.0.196 - Better 25Mbps - built on Sep 07 20-6f7c56e1-c69f-4c47-9659-e26e27406220-ami-1d31460a.3 (ami-8f007b98)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-8f007b98"
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
