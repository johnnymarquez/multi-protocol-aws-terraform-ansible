variable "instance_type" {
  default = "t3.micro"
}

variable "image_id" {
  default = "ami-0ed9277fb7eb570c9"
}

variable "disable_api_termination" {
  default = true
}

variable "iam_instance_profile" {
  description = "Role required for Systems Manager"
  default     = "infra-role-ssm2"
}

variable "key_name" {
  default = "ansible"
}

variable "vpc_security_group_ids" {
  description = "Default security group zerorate-prd-sg-01"
  default     = ["sg-xxxxx"]
}

variable "creator" {
  default = ""
}

variable "cost_center" {
  default = ""
}

variable "stack" {
  default = "Production"
}

variable "device_name" {
  default = "/dev/xvda"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "volume_size" {
  default = 16
}

variable "logrotate" {
  default = "infra-instance-log-"
}

variable "application" {
  default = "-nginx"
}

variable "enabled_metrics" {
  default = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]
}

variable "security_groups" {
  default = ["sg-"]
}

variable "subnet_id" {
  default = "subnet-"
}

variable "vpc_zone_identifier" {
  default = [""]
}

variable "controlled_by_ansible" {
  default = false
}

variable "asg_name" {
  default = ""
}

variable "asg_lt_name" {
  default = ""
}

variable "asg_policy_in_name" {
  default = ""
}

variable "asg_policy_out_name" {
  default = ""
}

variable "target_group_arns" {
  default = []
}

variable "desired_capacity" {
  default = 10
}

variable "max_size" {
  default = 10
}

variable "min_size" {
  default = 2
}

variable "instances_name" {
  default = ""
}

variable "scaling_adjustment_in" {
  default = 2
}

variable "scaling_adjustment_out" {
  default = -2
}

variable "adjustment_type" {
  default = "ChangeInCapacity"
}

variable "template" {
  default = ("")
}

variable "termination_policies" {
  default = ["NewestInstance"]
}

variable "lifecycle_hook_name" {
  default = ""
}