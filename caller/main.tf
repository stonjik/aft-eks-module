provider "aws" {
  region  = "us-east-1"
  profile = "candi-the-date"

}

module "awesome-candidate-eks-module" {
  source                        = "../module/eks"
#   region                        = "us-east-1"
  cluster_name                  = "awesome-cluster" 
  vpc_id                        = "vpc-06fd9e9555ac4a3cf"
  igw_id                        = "igw-0b1187d94dc1eb06a"
  
}
