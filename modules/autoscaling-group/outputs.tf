output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "asg_policy_in_arn" {
  value = aws_autoscaling_policy.policy_in.arn
}

output "asg_policy_out_arn" {
  value = aws_autoscaling_policy.policy_out.arn
}