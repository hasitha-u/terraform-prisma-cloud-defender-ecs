provider "aws" {
  region = var.region
}

resource "random_string" "random" {
  length  = 4
  special = false
}

locals {
  name = "${var.name}-${random_string.random.result}"

  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.name}
    ECS_LOGLEVEL=debug
    EOF
  EOT
}

# Retrieve INSTALL_BUNDLE for ECS from Prisma Cloud
data "http" "install_bundle" {
  url = "${var.console_address}/api/v1/defenders/install-bundle?consoleaddr=${split("/", var.console_address)[2]}&defenderType=ecs"

  # Optional request headers
  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.api_token}"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Error: Unexpected http status code: ${self.status_code}"
    }
  }

}

# Retrieve defender image name from Prisma Cloud
data "http" "defender_image" {
  url = "${var.console_address}/api/v1/defenders/image-name"

  # Optional request headers
  request_headers = {
    Accept        = "application/json"
    Authorization = "Bearer ${var.api_token}"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Error: Unexpected http status code: ${self.status_code}"
    }
  }
}

# Deploy Prisma Cloud Defender
module "prisma_cloud_defender" {
  source                      = "../"
  name                        = local.name
  ecs_cluster_arn             = module.ecs.cluster_arn
  defender_install_bundle     = jsondecode(data.http.install_bundle.response_body).installBundle
  defender_memory             = 500
  defender_image              = "registry.twistlock.com/twistlock/defender:${split("\"", split(":", data.http.defender_image.response_body)[1])[0]}"
  prisma_cloud_registry_token = split("tw_", split("/", data.http.defender_image.response_body)[1])[1]
  prisma_cloud_ws_address     = jsondecode(data.http.install_bundle.response_body).wsAddress
  tags                        = var.tags

}

# Deploy ECS Cluster
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = local.name

  default_capacity_provider_use_fargate = false


  # Capacity provider - autoscaling groups
  autoscaling_capacity_providers = {
    asg = {
      auto_scaling_group_arn         = module.autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

    }
  }

  tags = var.tags
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}


module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  instance_type = var.instance_type

  name = local.name

  image_id = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(local.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = local.name
  iam_role_description        = "ECS role for ${local.name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = var.autoscalling_min_size
  max_size            = var.autoscalling_max_size
  desired_capacity    = var.autoscalling_desired_capacity

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = var.tags
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Autoscaling group security group for ${local.name}"
  vpc_id      = module.vpc.vpc_id


  egress_rules = ["all-all"]

  tags = var.tags
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "${local.name}-public"
  }

  private_subnet_tags = {
    Name = "${local.name}-private"
  }

  tags = var.tags

  vpc_tags = {
    Name = "${local.name}-vpc"
  }
}