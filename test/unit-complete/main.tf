# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPLETE FEATURES UNIT TEST
# This module tests a complete set of most/all non-exclusive features
# The purpose is to activate everything the module offers, but trying to keep execution time and costs minimal.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "aws_region" {
  description = "(Optional) The AWS region in which all resources will be created."
  type        = string
  default     = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_default_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  # valid account id for the US East (N. Virginia) region
  # for the full list please see https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
  alb_root_account_id = "127311923021"
  s3_bucket_name      = "terraform-aws-alb-unit-complete-s3-bucket"
  s3_bucket_arn       = "arn:aws:s3:::${local.s3_bucket_name}"
}

# define a policy that permit the ALB to send logs to the created s3 bucket
data "aws_iam_policy_document" "allow_alb_to_write_logs_to_s3" {
  statement {
    sid = "AllowELBRootAccount"

    actions = [
      "s3:PutObject",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.alb_root_account_id}:root"
      ]
    }

    resources = [
      "${local.s3_bucket_arn}/*",
    ]
  }

  statement {
    sid = "AWSLogDeliveryWrite"

    actions = [
      "s3:PutObject",
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
      ]
    }

    resources = [
      "${local.s3_bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    actions = [
      "s3:*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
      ]
    }

    resources = [
      local.s3_bucket_arn,
    ]
  }
}


# create the s3 bucket for storing access logs
module "access_logs_bucket" {
  source  = "mineiros-io/s3-bucket/aws"
  version = "~> 0.6.0"
  bucket  = local.s3_bucket_name

  force_destroy = true

  apply_server_side_encryption_by_default = {
    sse_algorithm = "AES256"
  }

  policy = data.aws_iam_policy_document.allow_alb_to_write_logs_to_s3.json
}


# DO NOT RENAME MODULE NAME
module "test" {
  source = "../.."

  module_enabled = true

  # add all required arguments
  subnets         = data.aws_subnet_ids.default.ids
  security_groups = [aws_default_security_group.default.id]
  access_logs = {
    bucket = module.access_logs_bucket.bucket.bucket
    prefix = "test-with-access-logs-alb"
  }

  # add all optional arguments that create additional resources

  # add most/all other optional arguments
  drop_invalid_header_fields = true
  enable_http2               = true
  ip_address_type            = "ipv4"

  tags = {
    Department = "engineering"
  }

  module_tags = {
    Environment = "unknown"
  }

  module_depends_on = ["nothing"]
}

# outputs generate non-idempotent terraform plans so we disable them for now unless we need them.
# output "all" {
#   description = "All outputs of the module."
#   value       = module.test
# }
