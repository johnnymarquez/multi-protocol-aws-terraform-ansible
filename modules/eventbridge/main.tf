resource "aws_cloudwatch_event_rule" "rule" {
  name          = var.rule_name
  description   = var.rule_description
  event_pattern = var.rule_event_pattern
    tags = {
    Creator             = var.creator
    "Cost Center"       = var.cost_center
    Stack               = var.stack
    Name                = var.name
  }
}

resource "aws_cloudwatch_event_target" "target" {
  arn  = var.lambda_function_arn
  rule = aws_cloudwatch_event_rule.rule.id
}
