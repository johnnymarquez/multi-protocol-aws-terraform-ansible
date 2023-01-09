output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nlb_arn_suffix" {
  value = aws_lb.nlb.arn_suffix
}
output "dns_name" {
  value = aws_lb.nlb.dns_name
}

output "zone_id" {
  value = aws_lb.nlb.zone_id
}

# output "tg_443_arn_suffix" {
#   value = aws_lb_target_group.tg_443.arn_suffix
# }

# output "tg_443_arn" {
#   value = aws_lb_target_group.tg_443.arn
# }

output "tg_arn" {
  description = "Targets groups 443 y 80 para el network load balancer"
  value = [for tg in aws_lb_target_group.tg : tg.arn] 
}

output "tg_arn_suffix" {
  description = "Sufijo para los target groups creados"
  value = [ for suffix in aws_lb_target_group.tg : suffix.arn_suffix ]
}
