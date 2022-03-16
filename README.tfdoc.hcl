header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-aws-alb"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-aws-alb/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-aws-alb/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-alb.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-aws-alb/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-aws-provider" {
    image = "https://img.shields.io/badge/AWS-3-F8991D.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-aws/releases"
    text  = "AWS Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-aws-alb"
  toc     = true
  content = <<-END
    A [Terraform] module to deploy and manage an [Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/)
    on [Amazon Web Services (AWS)][aws].

    **_This module supports Terraform version 1
    and is compatible with the Terraform AWS Provider version 3.27.0**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
      This module implements the following Terraform resources

      - `aws_lb`
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most common usage of the module:

      ```hcl
      module "terraform-aws-alb" {
        source = "git@github.com:mineiros-io/terraform-aws-alb.git?ref=v0.0.1"

        subnets         = ["subnet-1", "subnet-2"]
        security_groups = ["group-1", "group-2"]
      }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Main Resource Configuration"

      variable "subnets" {
        required    = true
        type        = set(string)
        description = <<-END
          A list of subnet IDs to attach to the ALB. At least two subnets in two
          different availability zones must be specified.
        END
      }

      variable "security_groups" {
        required    = true
        type        = set(string)
        description = <<-END
          A list of security group IDs to assign to the load balancer.
        END
      }

      variable "name" {
        type        = string
        description = <<-END
          The name of the Load Balancer. This name must be unique within your
          AWS account, can have a maximum of 32 characters, must contain only
          alphanumeric characters or hyphens, and must not begin or end with a
          hyphen. If not specified, Terraform will autogenerate a name beginning
          with `tf-lb`.
        END
      }

      variable "enable_deletion_protection" {
        type        = bool
        default     = false
        description = <<-END
          If `true`, deletion of the load balancer will be disabled via the AWS
          API. This will prevent Terraform from deleting the load balancer.
        END
      }

      variable "internal" {
        type        = bool
        default     = false
        description = <<-END
          If `true`, the load balancer will be internal. The nodes of an
          internal load balancer can only have private IP addresses. The DNS
          name of an internal load balancer is publicly resolvable to the
          private IP addresses of the nodes. Therefore, internal load balancers
          can only route requests from clients with access to the VPC for the
          load balancer.
        END
      }

      variable "idle_timeout" {
        type        = number
        default     = 60
        description = <<-END
          The time in seconds that the connection is allowed to be idle.
        END
      }

      variable "drop_invalid_header_fields" {
        type        = bool
        default     = false
        description = <<-END
          Indicates whether HTTP headers with header fields that are not valid
          are removed by the load balancer (`true`) or routed to targets
          (`false`). Elastic Load Balancing requires that message header names
          contain only alphanumeric characters and hyphens.
        END
      }

      variable "access_logs" {
        type        = list(access_log)
        default     = []
        description = <<-END
          Block used for configuring access logs.
        END

        attribute "bucket" {
          required    = true
          type        = string
          description = <<-END
            The S3 bucket name to store the logs in.
          END
        }

        attribute "enabled" {
          type        = bool
          default     = true
          description = <<-END
            Boolean to enable / disable `access_logs`. Defaults to `false`,
            even when `bucket` is specified.
          END
        }

        attribute "prefix" {
          type        = string
          description = <<-END
            The S3 bucket prefix. Logs are stored in the root if not configured.
          END
        }
      }

      variable "enable_http2" {
        type        = bool
        default     = true
        description = <<-END
          Indicates whether HTTP/2 is enabled.
        END
      }

      variable "customer_owned_ipv4_pool" {
        type        = string
        description = <<-END
          The ID of the customer owned ipv4 pool to use for this load balancer.
        END
      }

      variable "ip_address_type" {
        type        = string
        default     = "ipv4"
        description = <<-END
          The type of IP addresses used by the subnets for your load balancer.
          The possible values are `ipv4` and `dualstack`.
        END
      }

      variable "tags" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of tags to apply to the created `aws_lb` resource.
        END
      }
    }

    section {
      title = "Module Configuration"

      variable "module_enabled" {
        type        = bool
        default     = true
        description = <<-END
          Specifies whether resources in the module will be created.
        END
      }

      variable "module_tags" {
        type           = map(string)
        default        = {}
        description    = <<-END
          A map of tags that will be applied to all created resources that accept tags.
          Tags defined with `module_tags` can be overwritten by resource-specific tags.
        END
        readme_example = <<-END
          module_tags = {
            environment = "staging"
            team        = "platform"
          }
        END
      }

      variable "module_depends_on" {
        type           = list(dependency)
        description    = <<-END
          A list of dependencies.
          Any object can be _assigned_ to this list to define a hidden external dependency.
        END
        default        = []
        readme_example = <<-END
          module_depends_on = [
            null_resource.name
          ]
        END
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "alb" {
      type        = object(alb)
      description = <<-END
        All attributes of the created `aws_lb` application load balancer resource.
      END
    }

    output "module_enabled" {
      type        = bool
      description = <<-END
        Whether this module is enabled.
      END
    }

    output "module_tags" {
      type        = map(string)
      description = <<-END
        The map of tags that are being applied to all created resources that accept tags.
      END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "AWS Documentation"
      content = <<-END
        - https://aws.amazon.com/elasticloadbalancing/
      END
    }

    section {
      title   = "Terraform AWS Provider Documentation"
      content = <<-END
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-aws-alb"
  }
  ref "hello@mineiros.io" {
    value = " mailto:hello@mineiros.io"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "aws" {
    value = "https://aws.amazon.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-aws-alb/blob/main/CONTRIBUTING.md"
  }
}
