################################################################################
# AWS
################################################################################

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

################################################################################
# EKS 
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  default = "1.29"
}

variable "cluster_endpoint_public_access" {
  default = true
}

variable "ng_desired" {
  description = "Managed node group desired size"
  default     = 1
}

variable "ng_min" {
  description = "Managed node group minimum size"
  default     = 1
}

variable "ng_max" {
  description = "Managed node group maximum size"
  default     = 5
}

variable "instance_types" {
  description = "Instance types for the EKS managed node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Managed node group capacity type"
  default     = "ON_DEMAND"
}

variable "node_group_labels" {
  description = "Labels to apply to the EKS managed node groups"
  type        = map(string)
  default = {
    role = "EKS-Managed-NG"
  }
}

variable "cluster_tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default = {
    Candidate = "Andrey"
  }
}

variable "addon_vpc_cni_version" {
  description = "The version of vpc cni addon"
  default     = ""
}

variable "addon_aws_ebs_csi_driver_version" {
  description = "The version of ebs csi addon"
  default     = ""
}

variable "addon_coredns_version" {
  description = "The version of coredns addon"
  default     = ""
}

variable "addon_kube_proxy_version" {
  description = "The version of kube proxy addon"
  default     = ""
}

variable "aws_load_balancer_controller_sa" {
  description = "The name of the LB ServiceAccount"
  default     = "aws-load-balancer-controller"
}

variable "ebs_policy" {
  description = "AmazonEBSCSIDriverPolicy managed policy"
  default = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# VPC Networking
################################################################################

variable "vpc_id" {
  description = "The ID of the VPC where subnets will be created"
}

variable "igw_id" {
  description = "The ID of the Internet Gateway attached to your VPC"
}


variable "ngw_tag" {
  description = "Nat GW tag"
  default     = "eks-nat-gateway"
}

variable "sg_tag" {
  description = "Tags to apply to the additional sg"
  type        = map(string)
  default = {
    Candidate = "Andrey"
  }
}

variable "additional_sg_name" {
  description = "Name of the additional SG"
  default     = "eks-additional-sg"
}

variable "eks_public_rt" {
  description = "Public rt tag"
  default     = "eks-public-route-table"
}

variable "eks_private_rt" {
  description = "Private rt tag"
  default     = "eks-private-route-table"
}

variable "cidr_blocks_public" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["172.31.96.0/20", "172.31.112.0/20"]
}

variable "cidr_blocks_private" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["172.31.128.0/20", "172.31.144.0/20"]
}

