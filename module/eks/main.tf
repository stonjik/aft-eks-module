
################################################################################
# Locals
################################################################################

locals {
  ca_version_map = {
    "1.29" = { ca_version = "1.29", chart_version = "9.35.0" }
    "1.28" = { ca_version = "1.28", chart_version = "9.34.0" }
    "1.27" = { ca_version = "1.27", chart_version = "9.29.0" }
    "1.26" = { ca_version = "1.26", chart_version = "9.28.0" }
  }
}


################################################################################
# EKS 
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      addon_version = var.addon_coredns_version != "" ? var.addon_coredns_version : null
      most_recent   = var.addon_coredns_version == "" ? true : null
    }
    kube-proxy = {
      addon_version = var.addon_kube_proxy_version != "" ? var.addon_kube_proxy_version : null
      most_recent   = var.addon_kube_proxy_version == "" ? true : null
    }
    vpc-cni = {
      addon_version = var.addon_vpc_cni_version != "" ? var.addon_vpc_cni_version : null
      most_recent   = var.addon_vpc_cni_version == "" ? true : null
    }
    aws-ebs-csi-driver = {
      addon_version = var.addon_aws_ebs_csi_driver_version != "" ? var.addon_aws_ebs_csi_driver_version : null
      most_recent   = var.addon_aws_ebs_csi_driver_version == "" ? true : null
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = tolist(aws_subnet.private[*].id)
  cluster_additional_security_group_ids = [aws_security_group.eks_additional_sg.id]

  enable_irsa = true

  eks_managed_node_groups = {
    general = {
      desired_size                 = var.ng_desired
      min_size                     = var.ng_min
      max_size                     = var.ng_max
      labels                       = var.node_group_labels
      instance_types               = var.instance_types
      capacity_type                = var.capacity_type
      iam_role_additional_policies = { AmazonEBSCSIDriverPolicy = data.aws_iam_policy.ebs_csi_policy.arn }
    }

  }

  tags = var.cluster_tags
}

################################################################################
# IAM
################################################################################

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "eks-cluster-autoscaler"
  description = "Allows EKS Cluster Autoscaler to modify ASGs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "eks-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${module.eks.cluster_oidc_issuer_url}"
        },
        Action   = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.eks.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}


module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

################################################################################
# ServiceAccounts
################################################################################


resource "kubernetes_service_account" "service-account" {
  metadata {
    name = var.aws_load_balancer_controller_sa
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= var.aws_load_balancer_controller_sa
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

################################################################################
# Helm
################################################################################

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = local.ca_version_map[var.cluster_version]["chart_version"]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }
}



resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.aws_load_balancer_controller_sa
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}