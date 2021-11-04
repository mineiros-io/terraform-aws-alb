# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ----------------------------------------------------------------------------------------------------------------------

variable "subnets" {
  type        = set(string)
  description = "(Required) A list of subnet IDs to attach to the ALB. At least two subnets in two different availability zones must be specified."

  validation {
    condition     = length(var.subnets) >= 2
    error_message = "At least two subnets in two different availability zones must be specified in 'var.subnets'."
  }
}

variable "security_groups" {
  type        = set(string)
  description = "(Optional) A list of security group IDs to assign to the load balancer."
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ----------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "(Optional) The name of the Load Balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
  default     = null

  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,30}[a-zA-Z0-9]$|^[a-zA-Z0-9]$", var.name))
    error_message = "The name of the load balancer can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer."
  default     = false
}

variable "internal" {
  type        = bool
  description = "(Optional) If true, the load balancer will be internal. The nodes of an internal load balancer can only have private IP addresses. The DNS name of an internal load balancer is publicly resolvable to the private IP addresses of the nodes. Therefore, internal load balancers can only route requests from clients with access to the VPC for the load balancer."
  default     = false
}

variable "idle_timeout" {
  type        = number
  description = "(Optional) The time in seconds that the connection is allowed to be idle."
  default     = 60
}

variable "drop_invalid_header_fields" {
  type        = string
  description = "(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens."
  default     = false
}

variable "access_logs" {
  # type = object({
  #   # (Required) The S3 bucket name to store the logs in.
  #   bucket = string
  #   # (Optional) The S3 bucket prefix. Logs are stored in the root if not configured.
  #   prefix = optional(string)
  #   # (Optional) Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified.
  #   enabled = optional(bool)
  # })
  type        = any
  description = "(Optional) Block used for configuring access logs."
  default     = null
}

variable "enable_http2" {
  type        = bool
  description = "(Optional) Indicates whether HTTP/2 is enabled."
  default     = true
}

variable "customer_owned_ipv4_pool" {
  type        = string
  description = "(Optional) The ID of the customer owned ipv4 pool to use for this load balancer."
  default     = null
}

variable "ip_address_type" {
  type        = string
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are 'ipv4' and 'dualstack'."
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "The possible values for the 'ip_address_type' variable are 'ipv4' and 'dualstack'."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to apply to the created 'aws_lb' resource. Default is {}."
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# ----------------------------------------------------------------------------------------------------------------------
variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_tags" {
  type        = map(string)
  description = "(Optional) A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags."
  default     = {}
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}
