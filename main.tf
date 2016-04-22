# Specify the provider and access details
#https://www.terraform.io/docs/providers/aws/
provider "aws" {
  region = "us-east-1"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "elb_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTPS access from anywhere
  ingress {
    from_port   = 443 
    to_port     = 443 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "jenkins_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "web-elb" {
  name = "web-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::313092853311:server-certificate/my-server-cert"
  }

   health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/ha/health-check"
    interval = 30
  }
}

#A key pair is used to control login access to EC2 instances
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_launch_configuration" "cjoc01-lc" {
  name = "terraform-cjoc01-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data = "${file("userdata_cjoc.sh")}"
  key_name = "${var.key_name}"
  lifecycle {
      create_before_destroy = true
  }
  ebs_block_device {
        device_name = "/dev/sdf"
        volume_type = "standard"
        volume_size = 50 
  }
}

resource "aws_autoscaling_group" "cjoc01-asg" {
  #availability_zones = ["${split(",", var.availability_zones)}"]
  name = "terraform-cjoc01-asg"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.cjoc01-lc.id}"
  load_balancers = ["${aws_elb.web-elb.name}"]
  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${aws_subnet.default.id}"]
  tag {
    key = "Name"
    value = "cjoc01-asg"
    propagate_at_launch = "true"
  }
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_launch_configuration" "jenkins01-lc" {
  name = "terraform-jenkins01-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data = "${file("userdata.sh")}"
  key_name = "${var.key_name}"
  lifecycle {
      create_before_destroy = true
  }
  ebs_block_device {
        device_name = "/dev/sdf"
        volume_type = "standard"
        volume_size = 50 
  }
}

resource "aws_autoscaling_group" "jenkins01-asg" {
  #availability_zones = ["${split(",", var.availability_zones)}"]
  name = "terraform-jenkins01-asg"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.jenkins02-lc.id}"
  load_balancers = ["${aws_elb.web-elb.name}"]
  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${aws_subnet.default.id}"]
  tag {
    key = "Name"
    value = "jenkins01-asg"
    propagate_at_launch = "true"
  }
  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_launch_configuration" "jenkins02-lc" {
  name = "terraform-jenkins02-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  user_data = "${file("userdata.sh")}"
  key_name = "${var.key_name}"
  lifecycle {
      create_before_destroy = true
  }
  ebs_block_device {
        device_name = "/dev/sdf"
        volume_type = "standard"
        volume_size = 50 
  }
}

resource "aws_autoscaling_group" "jenkins02-asg" {
  #availability_zones = ["${split(",", var.availability_zones)}"]
  name = "terraform-jenkins02-asg"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.jenkins02-lc.id}"
  load_balancers = ["${aws_elb.web-elb.name}"]
  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${aws_subnet.default.id}"]
  tag {
    key = "Name"
    value = "jenkins02-asg"
    propagate_at_launch = "true"
  }
  lifecycle {
      create_before_destroy = true
  }
}

