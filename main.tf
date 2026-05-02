terraform {
  required_version = ">= 1.6" # minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # use any 5.x version
    }
  }
}

# ─────────────────────────────────────────
# PROVIDER — the plugin that knows how to talk to AWS
# Every AWS resource you create goes through this
# ─────────────────────────────────────────
provider "aws" {
  region = var.aws_region

  # These tags get automatically added to EVERY resource we create
  # Makes it easy to find all resources for this project in AWS console
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ─────────────────────────────────────────
# PHASE 2: NETWORKING
# Builds the VPC, subnets, internet gateway, route tables
# ─────────────────────────────────────────

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  aws_region   = var.aws_region
}

# ─────────────────────────────────────────
# PHASE 3: COMPUTE
# Security groups + EC2 server
# ─────────────────────────────────────────

module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  vpc_id               = module.networking.vpc_id                       # from Phase 2
  public_subnet_id     = module.networking.public_subnet_id             # from Phase 2
  key_pair_name        = var.key_pair_name
  iam_instance_profile = module.iam.ec2_instance_profile_name           # from Phase 5
}

# ─────────────────────────────────────────
# PHASE 4: DATABASE
# RDS MySQL in the private subnet
# ─────────────────────────────────────────

module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  private_subnet_id     = module.networking.private_subnet_id     # from Phase 2
  private_subnet_2_id   = module.networking.private_subnet_2_id   # from Phase 2
  rds_security_group_id = module.compute.rds_security_group_id    # from Phase 3
  db_username           = var.db_username
  db_password           = var.db_password
}

# ─────────────────────────────────────────
# PHASE 5: IAM ROLES
# Badges for EC2 and Lambda
# ─────────────────────────────────────────

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

# ─────────────────────────────────────────
# PHASE 6: DATA ENGINEERING LAYER
# S3 raw bucket + Lambda trigger + CloudWatch logs
# ─────────────────────────────────────────

module "data_layer" {
  source          = "./modules/data_layer"
  project_name    = var.project_name
  lambda_role_arn = module.iam.lambda_role_arn    # badge from Phase 5
}
