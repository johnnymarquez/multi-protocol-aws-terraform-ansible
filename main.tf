# ----------------------------------------------------------------------------------------------------

# ------------------------------------- Backend Configuration ----------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "http" {
    address  = "https://gitlab.com/api/v4/projects//terraform/state/prd"
    username = ""
    password = ""
  }
}

# ----------------------------------------- AutoScaling Group ----------------------------------------

module "prd-asg-01" {
  source                  = "./../../../General/modules/autoscaling-group"
  asg_name                = "prd-asg"
  asg_lt_name             = "prd-lt"
  instances_name          = "prd-asg"
  instance_type           = "t3.micro"
  asg_policy_in_name      = "prd-autoscaling-in-policy"
  asg_policy_out_name     = "prd-autoscaling-out-policy"
  lifecycle_hook_name     = "LogAutoScalingEvent-hook-prd"
  vpc_zone_identifier     = [
    "subnet-", # prd-private-1a
    "subnet-", # prd-private-1b
  ]
  security_groups         = [module.sg.sg_id] # ["sg-"] prd-web-sg-02
  max_size                = 2
  min_size                = 1
  desired_capacity        = 1
  disable_api_termination = true
  target_group_arns       = [module.prd-alb-asg.tg_443_arn]
  template                = ("../../../General/user-data/cis-userdata-.sh.tpl")
  #template                = ("../../../General/user-data/cis-userdata-.sh.tpl")
  cost_center             = ""
  stack                   = "Development"
  creator                 = ""
}

# ------------------------------------------ NLB LINKED TO ALB -----------------------------------------------

module "prd-nlb-asg" {
  source                   = "./../../../General/modules/network-load-balancer-v1"
  nlb_name                 = "prd-nlb-asg"
  nlb_target_group_80_name = "prd-nlb-asg-tg"
  security_groups          = ["sg-0b1edb9baa17cdf10"] # prd-alb-sg
  subnets                  = [
    "subnet-075c45245e685d747", # prd-public-1a
    "subnet-048f6adf9d6736ac1"  # prd-public-1b
  ]
  vpc_id                   = "vpc-00e88c24d6fb45665" # VPC-PRD
  target_id                = module.prd-alb-asg.alb_arn
  target_type              = "alb"
  access_logs_bucket       = "-stg-nlb-05feb-logs"
  cost_center              = ""
  stack                    = "Development"
  creator                  = ""
}

# ------------------------------------------ ALB LINKED TO ASG -----------------------------------------------

module "prd-alb-asg" {
  source                       = "./../../../General/modules/application-load-balancer"
  alb_name                     = "prd-alb-asg"
  alb_target_group_80_name     = "prd-alb-asg-tg80"
  alb_target_group_443_name    = "prd-alb-asg-tg443"
  security_groups              = ["sg-0b1edb9baa17cdf10"] # prd-alb-sg
  subnets                      = [
    "subnet-02fa0b12a895a0891", # prd-private-1a
    "subnet-006dd194ee3cbd0f4"  # prd-private-1b
  ]
  vpc_id                       = "vpc-00e88c24d6fb45665" # VPC-PRD
  listener_443_certificate_arn = "arn:aws:acm:us-east-1:045837062796:certificate/48ef8de7-314a-400a-811c-f5ed71a5769b"
  # *.
  listener_443_ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  cost_center                  = ""
  stack                        = "Development"
  creator                      = ""
}

# ------------------------------------------ CLOUDWATCH ALARMS -----------------------------------------------

# Cloudwatch Alarm Remove Capacity. CPUUtilization <= 50 for 20 datapoints within 20 minutes
module "prd-alarm-asg-tg-removecapacity" {
  source              = "./../../../General/modules/cloudwatch-alarm"
  alarm_name          = "prd-asg-tg-cpuutilization-removecapacity"
  alarm_description   = "Inicia con el decremento de 2 en 2 instancias hasta llegar a un mínimo de 2"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  metric_name         = "CPUUtilization"
  threshold           = 50
  datapoints_to_alarm = 20
  evaluation_periods  = 60
  comparison_operator = "LessThanOrEqualToThreshold"
  alarm_actions       = [
    module.prd-asg-01.asg_policy_in_arn,
  ]
  dimensions          = {
    "AutoScalingGroupName" = module.prd-asg-01.asg_name
  }
}

# Cloudwatch Alarm Add Capacity. CPUUtilization >= 80 for 5 datapoints within 5 minutes
module "prd-alarm-asg-tg-addcapacity" {
  source              = "./../../../General/modules/cloudwatch-alarm"
  alarm_name          = "prd-asg-tg-cpuutilization-addcapacity"
  alarm_description   = "Inicia con el decremento de 2 en 2 instancias hasta llegar a un mínimo de 2"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  metric_name         = "CPUUtilization"
  threshold           = 80
  datapoints_to_alarm = 5
  evaluation_periods  = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [
    module.prd-asg-01.asg_policy_out_arn,
  ]
  dimensions          = {
    "AutoScalingGroupName" = module.prd-asg-01.asg_name
  }
}

# Security Group
module "sg" {
  source                              = "./../../../General/modules/security-group"
  vpc_id                              = "vpc-00e88c24d6fb45665" # VPC-PRD
  name                                = "prd-asg-sg"
  description                         = "Security Group"
  creator                             = ""
  r1_ingress_sg_rule_description      = ""
  r1_ingress_source_security_group_id = "sg-233bc046" #
  r1_ingress_port                     = 22
  r2_ingress_sg_rule_description      = ""
  r2_ingress_port                     = 443
  r2_ingress_cidr_blocks              = ["0.0.0.0/0"]
  r2_ingress_ipv6_cidr_blocks         = ["::/0"]
  r3_ingress_sg_rule_description      = ""
  r3_ingress_port                     = 80
  r3_ingress_cidr_blocks              = ["0.0.0.0/0"]
  r3_ingress_ipv6_cidr_blocks         = []
  r1_egress_sg_rule_description       = ""
  r1_egress_port                      = 0
  r1_egress_cidr_blocks               = ["0.0.0.0/0"]
  r1_egress_ipv6_cidr_blocks          = ["::/0"]
  cost_center                         = ""
  stack                               = "Development"
}


#--------------------------EventBridge------------------------------------

module "lambda_ChangeTagNameEC2ASG-" {
  source        = "./../../../General/modules/lambda-function"
  function_name = "ChangeTagNameEC2ASG-"
  role          = "service-role/ChangeTagNameEC2ASG-role-qzfd3sqz"
  handler       = "ChangeTagNameEC2ASG-.lambda_handler"
  runtime       = "python3.9"
  filename      = "./../../../General/lambda-functions/ChangeTagNameEC2ASG-.zip"
  eventbridge_rule_arn = module.eventbridge_log_asg_rule_.eventbridge_rule_arn
}


module "eventbridge_log_asg_rule_" {
  source              = "./../../../General/modules/eventbridge"
  lambda_function_arn = module.lambda_ChangeTagNameEC2ASG-.lambda_function_arn
  rule_name           = "LogAutoScaling-"
  rule_description    = "Regla para generar nombre aleatorio para las instancias de "
  rule_event_pattern  = <<EOF
  {
    "source": ["aws.autoscaling"],
    "detail-type": ["EC2 Instance-launch Lifecycle Action"]
  }
  EOF
}

