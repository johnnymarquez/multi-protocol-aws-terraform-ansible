variable "filename" {
  default = ""
}

variable "eventbridge_rule_arn" {
  default = ""
}

variable "function_name" {
  default = ""
}

variable "role" {
  default = "service-role/"
}

variable "handler" {
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  default = "python3.9"
}

variable "timeout" {
  default = 15
}

variable "name" {
  default = ""
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