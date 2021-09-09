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

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

module "lb_logs" {
  source  = "mineiros-io/s3-bucket/aws"
  version = "~> 0.6.0"

  bucket        = "my-tf-test-bucket-alb-logs-terraform-test-complete"
  acl           = "private"
  force_destroy = true

  policy = data.aws_iam_policy_document.policy.json

  tags = {
    Name = "SPA S3 Bucket"
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["${module.lb_logs.arn}/test-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = ["${module.lb_logs.arn}/test-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = ["${module.lb_logs.arn}"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.example.ids
  id       = each.value
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

module "test" {
  source = "../.."

  module_enabled = true

  # add all required arguments

  # add most/all optional arguments
  name            = "test-lb-tf"
  internal        = false
  subnets         = [element(sort(keys(data.aws_subnet.example)), 0), element(sort(keys(data.aws_subnet.example)), 1)]
  security_groups = [data.aws_security_group.default.id]

  access_logs = {
    bucket  = module.lb_logs.id
    prefix  = "test-lb/AWSLogs/${data.aws_caller_identity.current.account_id}"
    enabled = true
  }

  module_tags = {
    Environment = "unknown"
  }

  module_depends_on = [module.lb_logs]
}

#output "all" {
#  description = "All outputs of the module."
#  value       = module.test
#}
