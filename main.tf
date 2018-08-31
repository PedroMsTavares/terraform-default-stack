provider "aws" {
  region = "${var.region}"
}

module "network" {
  source   = "modules/network"
  region   = "${var.region}"
  vpc-cidr = "${var.vpc-cidr}"
  tags     = "${var.tags}"
}

module "bastion" {
  source         = "modules/bastion"
  bastion-subnet = "${module.network.public-subnets[0]}"
  bastion-ami    = "${lookup(var.aws_amis, var.region)}"
  bastion-key    = "${var.ssh-key}"
  access_from    = "${var.bastion-access-from}"
  vpc            = "${module.network.vpc-id}"
  vpc-cidr       = "${var.vpc-cidr}"
  env            = "${var.env}"
}

resource "aws_elb" "web-elb" {
  name = "${var.env}-application-elb"

  subnets         = ["${module.network.public-subnets}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "web-asg" {
  vpc_zone_identifier  = ["${module.network.private-subnets}"]
  name                 = "${var.env}-web-asg"
  health_check_type    = "ELB"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  tag {
    key                 = "Name"
    value               = "${var.env}-web-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "web-lc" {
  name_prefix   = "${var.env}-web-lc"
  image_id      = "${lookup(var.aws_amis, var.region)}"
  instance_type = "${var.web_instance_type}"

  # Security group
  security_groups = ["${aws_security_group.webserver-sg.id}"]
  user_data       = "${file("scripts/userdata.sh")}"
  key_name        = "${var.ssh-key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb-sg" {
  name        = "terraform_example_sg"
  description = "Used in the terraform"
  vpc_id      = "${module.network.vpc-id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "webserver-sg" {
  name        = "webservers sg"
  description = "Used in the terraform"
  vpc_id      = "${module.network.vpc-id}"

  # HTTP access from the vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc-cidr}"]
  }
  # ssh access from the vpc
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc-cidr}"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* outputs */

output "bastion-dns" {
  value = "${module.bastion.public-dns}"
}

output "web-url" {
  value = "${aws_elb.web-elb.dns_name}"
}
