variable "tags" {
  default = {
    
  }
  
}
variable "alarm_name" {
  default = ""
}

variable "country" {
  default = ""
}

variable "treat_missing_data" {
  default = "missing"
}

variable "comparison_operator" {
  default = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  default = "1"
}

variable "metric_name" {
  default = "UnHealthyHostCount"
}

variable "namespace" {
  default = "AWS/ApplicationELB"
}

variable "alarm_actions" {
  default = []
}

variable "period" {
  default = "60"
}

variable "statistic" {
  default = "Sum"
}

variable "threshold" {
  default = "0"
}

variable "datapoints_to_alarm" {
  default = "1"
}

variable "alarm_description" {
  default = ""
}

variable "dimensions" {}

variable "ok_actions" {
  default = []
}