output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  description = "The IDs of the private subnets"
}

output "public_route_table_id" {
  value = aws_route_table.public.id
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value = aws_route_table.private.id
  description = "The ID of the private route table"
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
  description = "The ID of the NAT gateway"
}

output "additional_security_group_id" {
  value = aws_security_group.eks_additional_sg.id
  description = "The ID of the additional security group for EKS cluster"
}

output "cluster_name" {
  value = module.eks.cluster_id
  description = "The name of the EKS cluster"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The endpoint for your EKS Kubernetes API"
}

output "eks_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
  description = "The role ARN of the EKS cluster"
}

output "eks_cluster_sg_id" {
  value = module.eks.cluster_security_group_id
  description = "The sg of the EKS cluster"
}

output "cluster_identity_oidc_issuer" {
  value = module.eks.cluster_oidc_issuer_url
  description = "The OIDC issuer URL of the EKS cluster"
}

output "cluster_service_account_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
  description = "The ARN of the IAM role for the cluster autoscaler service account"
}

