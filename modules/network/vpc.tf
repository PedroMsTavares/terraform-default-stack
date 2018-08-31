resource "aws_vpc" "main-vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = "true"
  tags                 = "${var.tags}"
}

output "vpc-id" {
  value = "${aws_vpc.main-vpc.id}"
}
