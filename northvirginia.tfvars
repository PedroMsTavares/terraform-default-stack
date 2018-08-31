region="us-east-1"

vpc-cidr = "10.10.20.0/24"

ssh-key="pedro"

bastion-access-from = ["92.0.174.123/32"]

tags = {
  "env" = "nv-dev-pt",
  "live" = "no"
}

env = "nv-dev-pt"
asg_desired = "5"
