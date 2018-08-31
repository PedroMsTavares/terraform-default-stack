region="eu-west-1"

vpc-cidr = "10.10.10.0/24"

ssh-key="pedro"

bastion-access-from = ["92.0.174.123/32"]

tags = {
  "env" = "dbn-dev-pt",
  "live" = "no"
}

env = "dbn-dev-pt"
