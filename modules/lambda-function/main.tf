resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = "arn:aws:iam::${account_id}:role/${var.role}"
  runtime       = var.runtime
  handler       = var.handler
  timeout       = var.timeout
  filename      = var.filename
  tags = {
    Creator             = var.creator
    "Cost Center"       = var.cost_center
    Stack               = var.stack
    Name                = var.name
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
  #qualifier     = aws_lambda_alias.test_alias.name
}