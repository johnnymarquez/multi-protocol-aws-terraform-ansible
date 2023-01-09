resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  metric_name               = var.metric_name
  namespace                 = var.namespace
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  dimensions                = var.dimensions
  datapoints_to_alarm       = var.datapoints_to_alarm
  alarm_description         = var.alarm_description
  insufficient_data_actions = []
  tags                      = var.tags
  treat_missing_data        = var.treat_missing_data
}