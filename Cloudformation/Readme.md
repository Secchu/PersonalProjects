Automate EC2 Instance
=====================
aws cloudformation create-stack --stack-name {Name of Stack} --template-url https://s3.amazonaws.com/cformation-demos/EC2Instance-Demo.yml --parameters ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=KeyName,ParameterValue={Name of predefined key} 

To create a Stack name called EC2Stack with a key called mykey and an instance type of t2.micro use the following command
aws cloudformation create-stack --stack-name EC2Stack --template-url https://s3.amazonaws.com/cformation-demos/EC2Instance-Demo.yml --parameters ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=KeyName,ParameterValue=mykey

To delete above cloudformation stack
aws cloudformation delete-stack --stack-name {stack name}

If you named your stack EC2Stack then the command to delete the stack is:
aws cloudformation delete-stack --stack-name EC2Stack 

Provision VPC and Public Subnets using CloudFormation
=====================================================
This demo provisions a VPC along with 2 public subnets

Cli Command to Automate VPC and Subnets with Parameters
aws cloudformation create-stack --stack-name {Stack name} --template-url https://s3.amazonaws.com/cformation-demos/vpc.yml --parameters ParameterKey=VpcCIDR,ParameterValue={VPC CIDR} ParameterKey=PublicSubnet1CIDR,ParameterValue={Public Subnet1 CIDR} ParameterKey=PublicSubnet2CIDR,ParameterValue={Public Subnet2 CIDR}  

For example to create a Stack named vpc-automated with VPC CIDR 10.8.0.0/22 with public subnets 10.8.1.0/24 and 10.8.1.0/24 use the following CLI command.
aws cloudformation create-stack --stack-name vpc-automated --template-url https://s3.amazonaws.com/cformation-demos/vpc.yml --parameters ParameterKey=VpcCIDR,ParameterValue=10.8.0.0/22 ParameterKey=PublicSubnet1CIDR,ParameterValue=10.8.1.0/24 ParameterKey=PublicSubnet2CIDR,ParameterValue=10.8.2.0/24 

Use the following command to delete stack
aws cloudformation delete-stack --stack-name {Stack name} 

For example if your stack name is called vpc-automated then the command is:
aws cloudformation delete-stack --stack-name vpc-automated 

Provision ELB, Instances and Auto Scaling Group using CloudFormation using Nested Stacks
========================================================================================
Uses nested stacks so you would need to run cloudformation command to provisioning the VPC and public subnets first. 

Then you use the following CLI command:
aws cloudformation create-stack --stack-name {Stack name} --template-url https://s3.amazonaws.com/cformation-demos/auto-scaling.yml --parameters ParameterKey=VPCStackName,ParameterValue={Stack name of VPC Stack that runs vpc.yml} ParameterKey=KeyName,ParameterValue={Predefined Key} --capabilities CAPABILITY_NAMED_IAM 

For example to create a Stack called auto-scaling-production that provison resources from the VPC Stack called vpc-automated with a key called mykey use the 
following Cli Command:
aws cloudformation create-stack --stack-name auto-scaling-production --template-url https://s3.amazonaws.com/cformation-demos/auto-scaling.yml --parameters ParameterKey=VPCStackName,ParameterValue=vpc-automated ParameterKey=KeyName,ParameterValue=mykey --capabilities CAPABILITY_NAMED_IAM 

To delete stack
aws cloudformation delete-stack --stack-name {Stack name of Parent Stack (Stack that runs auto-scaling-production.yml)} 

For example if the auto scaling stack is named auto-scaling-production then use the following command to delete the stack
aws cloudformation delete-stack --stack-name auto-scaling-production 

Note
====
You can substitute the template-url parameter with the template-body parameter if the cloudformation file is local 