resource "aws_lb" "alb" {
  count = var.module_enabled ? 1 : 0

  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"

  security_groups = var.security_groups
  subnets         = var.subnets

  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_http2               = var.enable_http2
  customer_owned_ipv4_pool   = var.customer_owned_ipv4_pool
  ip_address_type            = var.ip_address_type
  idle_timeout               = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []

    content {
      bucket  = access_logs.value.bucket
      prefix  = try(access_logs.value.prefix, null)
      enabled = try(access_logs.value.enabled, false)
    }
  }

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.module_tags, var.tags)

  depends_on = [var.module_depends_on]
}
