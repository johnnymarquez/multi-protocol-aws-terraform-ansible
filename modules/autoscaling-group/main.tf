# ------------------------------------------------------------------------------------------------------------
# --------------------------------------------- AUTOSCALING GROUP --------------------------------------------
# ------------------------------------------------------------------------------------------------------------

resource "aws_launch_template" "asg_lt" {
  name                    = var.asg_lt_name
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = true
  ebs_optimized           = true
  user_data               = base64encode(data.template_file.init.rendered)

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = var.device_name
    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = data.aws_kms_key.ebs.arn # Arn instead of id to avoid forced replacement.
      volume_size           = var.volume_size
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = {
      Name          = var.instances_name
      Creator       = var.creator
      "Cost Center" = var.cost_center
      Stack         = var.stack
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = {
      Name                = var.instances_name
      Creator             = var.creator
      "Cost Center"       = var.cost_center
      Stack               = var.stack
      ControlledByAnsible = var.controlled_by_ansible
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = {
      Name          = var.instances_name
      Creator       = var.creator
      "Cost Center" = var.cost_center
      Stack         = var.stack
    }
  }

  tags = {
    Name                 = var.instances_name
    "Auto Scaling Group" = var.asg_name
    Creator              = var.creator
    "Cost Center"        = var.cost_center
    Stack                = var.stack
    ControlledByAnsible  = var.controlled_by_ansible
  }

  network_interfaces {
    security_groups = var.security_groups
    device_index    = 0
    ipv4_addresses  = []
    ipv6_addresses  = []
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 0
  health_check_type         = "EC2"
  default_cooldown          = 300
  service_linked_role_arn   = data.aws_iam_role.awsserviceroleforautoscaling.arn
  vpc_zone_identifier       = var.vpc_zone_identifier
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  enabled_metrics           = var.enabled_metrics

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Name"
      value               = var.asg_name
      propagate_at_launch = false
    },
    {
      key                 = "Cost Center"
      value               = var.cost_center
      propagate_at_launch = false
    },
    {
      key                 = "Creator"
      value               = var.creator
      propagate_at_launch = false
    },
    {
      key                 = "Stack"
      value               = var.stack
      propagate_at_launch = false
    },
    {
      key                 = "ControlledByAnsible"
      value               = var.controlled_by_ansible
      propagate_at_launch = false
    }
  ]
}

resource "aws_autoscaling_policy" "policy_in" {
  name                   = var.asg_policy_in_name
  scaling_adjustment     = var.scaling_adjustment_in
  adjustment_type        = var.adjustment_type
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "policy_out" {
  name                   = var.asg_policy_out_name
  scaling_adjustment     = var.scaling_adjustment_out
  adjustment_type        = var.adjustment_type
  cooldown               = 180
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_lifecycle_hook" "logautoscaling" {
  name                   = var.lifecycle_hook_name
  autoscaling_group_name = aws_autoscaling_group.asg.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

  # aws_cloudwatch_log_group.test_group will be destroyed
# resource "aws_cloudwatch_log_group" "loggroup_group" {
#   name              =  "${var.logrotate}${var.instances_name}${var.application}"
#   retention_in_days = 90 
#   tags = {
#     Creator             = var.creator
#     "Cost Center"       = var.cost_center
#     Stack               = var.stack
#     }
#   tags_all          = {
#     Creator             = var.creator
#     "Cost Center"       = var.cost_center
#     Stack               = var.stack
#     }
#  }

# ------------------------------------------- Data Sources -------------------------------------------

# Searches for user data and parameterizes it with hostname
data "template_file" "init" {
  template = file(var.template)
  #  template = file("${path.module}/cis-userdata.sh.tpl")

  vars = {
    HOSTNAME      = var.instances_name,
    linuxPlatform = "",
    isRPM         = "",
  }
}

# Searches for most recent Amazon Linux 2 AMI
data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = [137112412989]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20211201.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Account information
data "aws_caller_identity" "current" {}
# "account_id" data.aws_caller_identity.current.account_id
# "caller_arn" data.aws_caller_identity.current.arn
# "caller_user" data.aws_caller_identity.current.user_id

# AWS KMS managed key
data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

# AWS Managed Service Role for AutoScaling Group
data "aws_iam_role" "awsserviceroleforautoscaling" {
  name = "AWSServiceRoleForAutoScaling"
}

# Current Region
data "aws_region" "current" {}