variable "bastion-ami" {}

variable "tags" {
  type = "map"

  default = {
    "live" = "no"
  }
}

variable "vpc" {}
variable "bastion-subnet" {}
variable "bastion-key" {}

variable "access_from" {
  type = "list"
}

variable "vpc-cidr" {}

variable "env" {}
