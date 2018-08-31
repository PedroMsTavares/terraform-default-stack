resource "aws_instance" "bastion" {
  ami                         = "${var.bastion-ami}"
  instance_type               = "t2.micro"
  subnet_id                   = "${var.bastion-subnet}"
  associate_public_ip_address = "True"
  vpc_security_group_ids      = ["${aws_security_group.bastion-access.id}"]
  key_name                    = "${var.bastion-key}"
  tags                        = "${merge(var.tags, map("Name", "bastion-host"))}"
}

resource "aws_security_group" "bastion-access" {
  name        = "bastion-access"
  description = "SSH access to bastion"
  vpc_id      = "${var.vpc}"

  tags = "${merge(var.tags, map("Name", "bastion-sg-${var.env}"))}"
}

resource "aws_security_group_rule" "allow-ssh-in" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.access_from}"

  security_group_id = "${aws_security_group.bastion-access.id}"
}

resource "aws_security_group_rule" "allow-ssh-out" {
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.vpc-cidr}"]

  security_group_id = "${aws_security_group.bastion-access.id}"
}

output "public-dns" {
  value = "${aws_instance.bastion.public_dns}"
}
