variable "vpc-cidr" {}

variable "tags" {
  type = "map"

  default = {
    "live" = "no"
  }
}

variable "region" {}

variable "newbits" {
  default = "4"
}

variable "aws-azs" {
  default = {
    us-east-1 = "us-east-1a,us-east-1b,us-east-1c,us-east-1d,us-east-1e"
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}
