# computing private subnets, based on region and Azs

resource "aws_subnet" "private-subnets" {
  count             = "${length(split(",", lookup(var.aws-azs, var.region)))}"
  vpc_id            = "${aws_vpc.main-vpc.id}"
  availability_zone = "${element(split(",", lookup(var.aws-azs, var.region)), count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc-cidr, var.newbits, count.index )}"
  tags              = "${merge(var.tags, map("Name", "private-subnet"))}"
}

resource "aws_subnet" "public-subnets" {
  count             = "${length(split(",", lookup(var.aws-azs, var.region)))}"
  vpc_id            = "${aws_vpc.main-vpc.id}"
  availability_zone = "${element(split(",", lookup(var.aws-azs, var.region)), count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc-cidr, var.newbits, (length(aws_subnet.private-subnets.*.id) + count.index ))}"
  tags              = "${merge(var.tags, map("Name", "public-subnet"))}"
}

### igw

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  tags   = "${var.tags}"
}

### public routes and routing table

resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  tags   = "${var.tags}"
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  route_table_id         = "${aws_route_table.public-subnet-route-table.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", lookup(var.aws-azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-subnet-route-table.id}"
}

### creation of the nat gateway

resource "aws_eip" "eip-nat" {
  vpc  = true
  tags = "${var.tags}"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.eip-nat.id}"
  subnet_id     = "${aws_subnet.public-subnets.0.id}"
  tags          = "${var.tags}"
}

### private routes

resource "aws_route_table" "private-subnet-route-table" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  tags   = "${var.tags}"
}

resource "aws_route" "private-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat-gw.id}"
  route_table_id         = "${aws_route_table.private-subnet-route-table.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", lookup(var.aws-azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.private-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-subnet-route-table.id}"
}

### outputs

output "private-subnets" {
  value = "${aws_subnet.private-subnets.*.id}"
}

output "public-subnets" {
  value = "${aws_subnet.public-subnets.*.id}"
}
