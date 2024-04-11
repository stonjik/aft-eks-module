resource "aws_security_group" "eks_additional_sg" {
  name        = var.additional_sg_name
  description = "Additional empty security group for EKS cluster"
  vpc_id      = var.vpc_id

  tags = var.cluster_tags
}
