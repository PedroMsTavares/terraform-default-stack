variable "region" {}

variable "vpc-cidr" {}

/*variable "subnet-cidr-a" {}

variable "subnet-cidr-b" {}

variable "subnet-cidr-c" {}*/

variable "ssh-key" {}

variable "bastion-access-from" {
  type = "list"
}

variable asg_max {
  default = 5
}

variable asg_min {
  default = 2
}

variable asg_desired {
  default = 3
}

variable web_instance_type {
  default = "t2.micro"
}

variable "env" {}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-2a7d75c0"
    us-east-1 = "ami-759bc50a"
  }
}

variable "tags" {
  type = "map"

  default = {
    "live" = "no"
  }
}
