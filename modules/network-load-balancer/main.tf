# ------------------------------------------------------------------------------------------------------------
# ------- Network Load Balancer No Attachment - Autoscaling Group Only - Target Group & Listener 443 ---------
# ------------------------------------------------------------------------------------------------------------

resource "aws_lb" "nlb" {
  name                       = var.nlb_name
  internal                   = false
  load_balancer_type         = "network"
  subnets                    = var.subnets
  enable_http2               = true
  enable_deletion_protection = true
  tags                       = {
    "Cost Center" = var.cost_center
    Stack         = var.stack
    Creator       = var.creator
  }

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }
}

# NLB Listener Port 443
resource "aws_lb_listener" "listener_443" {
  for_each = {
  for name, arn in aws_lb_target_group.tg : name => arn
  if arn.port == 443
  }

  load_balancer_arn = aws_lb.nlb.arn
  port              = var.listener_443_port
  protocol          = var.listener_443_protocol
  ssl_policy        = var.listener_443_ssl_policy
  certificate_arn   = var.listener_443_certificate_arn
  alpn_policy       = var.listener_443_alpn_policy

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

# NLB Listener Port 80
resource "aws_lb_listener" "listener_80" {
  for_each = {
  for name, arn in aws_lb_target_group.tg : name => arn
  if arn.port == 80
  }
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = var.target_groups


  name        = "${var.target_group}-${each.value.name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.healthcheck_path
    protocol            = each.value.health_check_protocol
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
  }
}
