[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-aws-alb)

[![Build Status](https://github.com/mineiros-io/terraform-aws-alb/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-aws-alb/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-alb.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-aws-alb/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version](https://img.shields.io/badge/AWS-3-F8991D.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-aws-alb

A [Terraform] module for [Load Balancing](https://aws.amazon.com/elasticloadbalancing/)
on [Amazon Web Services (AWS)][aws].

**_This module supports Terraform version 1
and is compatible with the Terraform AWS Provider version 3.27.0**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Main Resource Configuration](#main-resource-configuration)
  - [Module Configuration](#module-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [AWS Documentation](#aws-documentation)
  - [Terraform AWS Provider Documentation](#terraform-aws-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

This module implements the following Terraform resources

- `aws_lb`

## Getting Started

Most common usage of the module:

```hcl
module "terraform-aws-alb" {
  source = "git@github.com:mineiros-io/terraform-aws-alb.git?ref=v0.0.1"

  subnets         = ["subnet-1", "subnet-2"]
  security_groups = ["group-1", "group-2"]
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Main Resource Configuration

- [**`subnets`**](#var-subnets): *(**Required** `set(string)`)*<a name="var-subnets"></a>

  A list of subnet IDs to attach to the ALB. At least two subnets in two
  different availability zones must be specified.

- [**`security_groups`**](#var-security_groups): *(**Required** `set(string)`)*<a name="var-security_groups"></a>

  A list of security group IDs to assign to the load balancer.

- [**`name`**](#var-name): *(Optional `string`)*<a name="var-name"></a>

  The name of the Load Balancer. This name must be unique within your
  AWS account, can have a maximum of 32 characters, must contain only
  alphanumeric characters or hyphens, and must not begin or end with a
  hyphen. If not specified, Terraform will autogenerate a name beginning
  with `tf-lb`.

- [**`enable_deletion_protection`**](#var-enable_deletion_protection): *(Optional `bool`)*<a name="var-enable_deletion_protection"></a>

  If `true`, deletion of the load balancer will be disabled via the AWS
  API. This will prevent Terraform from deleting the load balancer.

  Default is `false`.

- [**`internal`**](#var-internal): *(Optional `bool`)*<a name="var-internal"></a>

  If `true`, the load balancer will be internal. The nodes of an
  internal load balancer can only have private IP addresses. The DNS
  name of an internal load balancer is publicly resolvable to the
  private IP addresses of the nodes. Therefore, internal load balancers
  can only route requests from clients with access to the VPC for the
  load balancer.

  Default is `false`.

- [**`idle_timeout`**](#var-idle_timeout): *(Optional `number`)*<a name="var-idle_timeout"></a>

  The time in seconds that the connection is allowed to be idle.

  Default is `60`.

- [**`drop_invalid_header_fields`**](#var-drop_invalid_header_fields): *(Optional `bool`)*<a name="var-drop_invalid_header_fields"></a>

  Indicates whether HTTP headers with header fields that are not valid
  are removed by the load balancer (`true`) or routed to targets
  (`false`). Elastic Load Balancing requires that message header names
  contain only alphanumeric characters and hyphens.

  Default is `false`.

- [**`access_logs`**](#var-access_logs): *(Optional `list(access_log)`)*<a name="var-access_logs"></a>

  Block used for configuring access logs.

  Default is `[]`.

  Each `access_log` object in the list accepts the following attributes:

  - [**`bucket`**](#attr-access_logs-bucket): *(**Required** `string`)*<a name="attr-access_logs-bucket"></a>

    The S3 bucket name to store the logs in.

  - [**`enabled`**](#attr-access_logs-enabled): *(Optional `bool`)*<a name="attr-access_logs-enabled"></a>

    Boolean to enable / disable `access_logs`. Defaults to `false`,
    even when `bucket` is specified.

    Default is `true`.

  - [**`prefix`**](#attr-access_logs-prefix): *(Optional `string`)*<a name="attr-access_logs-prefix"></a>

    The S3 bucket prefix. Logs are stored in the root if not configured.

- [**`enable_http2`**](#var-enable_http2): *(Optional `bool`)*<a name="var-enable_http2"></a>

  Indicates whether HTTP/2 is enabled.

  Default is `true`.

- [**`customer_owned_ipv4_pool`**](#var-customer_owned_ipv4_pool): *(Optional `string`)*<a name="var-customer_owned_ipv4_pool"></a>

  The ID of the customer owned ipv4 pool to use for this load balancer.

- [**`ip_address_type`**](#var-ip_address_type): *(Optional `string`)*<a name="var-ip_address_type"></a>

  The type of IP addresses used by the subnets for your load balancer.
  The possible values are `ipv4` and `dualstack`.

  Default is `"ipv4"`.

- [**`tags`**](#var-tags): *(Optional `map(string)`)*<a name="var-tags"></a>

  A map of tags to apply to the created `aws_lb` resource.

  Default is `{}`.

### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_tags`**](#var-module_tags): *(Optional `map(string)`)*<a name="var-module_tags"></a>

  A map of tags that will be applied to all created resources that accept tags.
  Tags defined with `module_tags` can be overwritten by resource-specific tags.

  Default is `{}`.

  Example:

  ```hcl
  module_tags = {
    environment = "staging"
    team        = "platform"
  }
  ```

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies.
  Any object can be _assigned_ to this list to define a hidden external dependency.

  Default is `[]`.

  Example:

  ```hcl
  module_depends_on = [
    null_resource.name
  ]
  ```

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`alb`**](#output-alb): *(`object(alb)`)*<a name="output-alb"></a>

  All attributes of the created `aws_lb` application load balancer resource.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

- [**`module_tags`**](#output-module_tags): *(`map(string)`)*<a name="output-module_tags"></a>

  The map of tags that are being applied to all created resources that accept tags.

## External Documentation

### AWS Documentation

- https://aws.amazon.com/elasticloadbalancing/

### Terraform AWS Provider Documentation

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-aws-alb
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[aws]: https://aws.amazon.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-aws-alb/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-aws-alb/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-aws-alb/issues
[license]: https://github.com/mineiros-io/terraform-aws-alb/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-aws-alb/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-aws-alb/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-aws-alb/blob/main/CONTRIBUTING.md
