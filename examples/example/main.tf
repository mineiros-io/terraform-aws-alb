# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# EXAMPLE FULL USAGE OF THE TERRAFORM-MODULE-TEMPLATE MODULE
#
# And some more meaningful information.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

module "lb_logs" {
  source  = "mineiros-io/s3-bucket/aws"
  version = "~> 0.6.0"

  bucket        = "my-tf-test-bucket-alb-logs-terraform-example"
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

module "terraform-aws-alb" {
  source = "git@github.com:mineiros-io/terraform-aws-alb.git?ref=v0.0.1"

  # All required module arguments

  # none

  # All optional module arguments set to the default values
  name            = "test-lb-tf"
  internal        = false
  subnets         = [element(sort(keys(data.aws_subnet.example)), 0), element(sort(keys(data.aws_subnet.example)), 1)]
  security_groups = [data.aws_security_group.default.id]

  access_logs = {
    bucket  = module.lb_logs.id
    prefix  = "test-lb/AWSLogs/${data.aws_caller_identity.current.account_id}"
    enabled = true
  }
  # none

  # All optional module configuration arguments set to the default values.
  # Those are maintained for terraform 0.12 but can still be used in terraform 0.13
  # Starting with terraform 0.13 you can additionally make use of module level
  # count, for_each and depends_on features.
  module_enabled    = true
  module_depends_on = [module.lb_logs]
}

# ----------------------------------------------------------------------------------------------------------------------
# EXAMPLE PROVIDER CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  version = "~> 3.0"
}

# ----------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES:
# ----------------------------------------------------------------------------------------------------------------------
# You can provide your credentials via the
#   AWS_ACCESS_KEY_ID and
#   AWS_SECRET_ACCESS_KEY, environment variables,
# representing your AWS Access Key and AWS Secret Key, respectively.
# Note that setting your AWS credentials using either these (or legacy)
# environment variables will override the use of
#   AWS_SHARED_CREDENTIALS_FILE and
#   AWS_PROFILE.
# The
#   AWS_DEFAULT_REGION and
#   AWS_SESSION_TOKEN environment variables are also used, if applicable.
# ----------------------------------------------------------------------------------------------------------------------
