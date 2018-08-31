#### In the variables file you need to specify :

* region    : aws region where you want the resources to be created
* vpc-cdir  : the vpc cidr ( the network module will calculate automatically the subnets based on the az number , creating one subnet public and another private per az  )
* ssh-key   : ssh key-pair to use in the stack to access to the aws instances
* bastion-access-from : list of cdir that will be whitelisted to access the bastion
* tags                : map of tags to use on all the enviroment
* env                 : enviroment name , this name will be a prefix for all the resource names

This paramaters are optional :

* asg_max : max number of autoscaling group machines
* asg_min : min number of autoscaling group machines
* asg_desired : desire number of autoscaling group machines
* web_instance_type : instance type to use in the web servers


#### To run this use one of the following commands:  :

```
terraform apply -var-file=dublin.tfvars
terraform apply -var-file=northvirginia.tfvars
```

#### You can test the solution using the following command:

```
terraform output web-url | xargs curl
```

###### This code its only design to run in eu-west-1 and us-east-1 , if you need to test in a different region please change the io.tf in the network module.




*Note : For better resilience terraform should be configured to use a s3 bucket to save the state file and a dynamodb table to control locks
