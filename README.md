# aft-eks-module

# Awesome EKS Terraform Module

This Terraform module simplifies the process of setting up an Amazon EKS (Elastic Kubernetes Service) cluster. It's designed for ease of use, allowing users to quickly deploy EKS clusters with minimal configuration.

## Prerequisites

- Terraform 0.12+ installed
- AWS CLI installed
- An AWS account and your AWS credentials configured locally

## Usage

To use this module in your Terraform environment, add the following configuration(or more) to your Terraform files:

```hcl
provider "aws" {
  region  = "us-east-1"
}

module "awesome-candidate-eks-module" {
  source            = "../module/eks"
  cluster_name      = "awesome-cluster"
  vpc_id            = "vpc-06fd9e9555ac4a3cf"
  igw_id            = "igw-0b1187d94dc1eb06a"
}
```

## Addon Versions
Addon versions can be controlled by specifying a version number. If a version is not specified, the module will default to the latest version available.

## Security Groups
You can specify the CIDR blocks for your security groups. If not provided, a default value will be used.

# AWS Configuration
Before running terraform apply, you need to configure your AWS profile. This can be done by setting up your AWS config and credentials file as follows:

## AWS Config File
Create or update your AWS config file (~/.aws/config) with the following:

```
[profile candi-the-date]
region=us-east-1
output=json
```

## AWS Credentials File
Update your AWS credentials file (~/.aws/credentials) with your access key and secret access key:

```
[candi-the-date]
aws_access_key_id = AKIAVRUMB2X
aws_secret_access_key = t8PCl3K3v+QFI
```

## Setting AWS Profile in Shell
To use the specified AWS profile, you can set an alias in your shell. For bash, you can add the following line to your .bashrc or .bash_profile:
`alias aft='export AWS_PROFILE=candi-the-date'`

After adding the alias, you can use the aft command in your terminal to set the AWS profile for your session.

Running the Module
After setting up your AWS profile, navigate to your `caller` directory and run the following commands:

```
terraform init
terraform plan
terraform apply
```

Ensure you have correctly configured your AWS CLI and have sufficient permissions to create the resources required by the EKS cluster.

For more information on Terraform, visit Terraform.io.

For more details on AWS CLI configuration, visit AWS CLI Configuration.