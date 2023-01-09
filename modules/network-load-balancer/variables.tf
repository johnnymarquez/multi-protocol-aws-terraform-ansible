variable "nlb_name" {
  default = ""
}

variable "nlb_target_group_80_name" {
  default = ""
}

variable "nlb_target_group_443_name" {
  default = ""
}

variable "nlb_target_group" {
  type = string
}

variable "security_groups" {
  default = ["sg-"]
}

variable "subnets" {
  default = ["subnet-", "subnet-"]
}

variable "country" {
  default = ""
}

variable "vpc_id" {
  default = "vpc-"
}

variable "cost_center" {
  default = ""
}

variable "stack" {
  default = "Production"
}

variable "creator" {
  default = "n"
}

variable "listener_443_certificate_arn" {
  default = "a"
}

variable "listener_443_ssl_policy" {
  default = ""
}

variable "healthcheck_path" {
  default = "/_proxy/healthcheck"
}

variable "target_type" {
  default = "instance"
}

variable "access_logs_bucket" {
  default = ""
}

variable "access_logs_prefix" {
  default = ""
}

variable "access_logs_enabled" {
  default = true
}

variable "listener_443_alpn_policy" {
  type        = string
  description = "(optional) describe your variable"
  default     = "None"
}

variable "listener_443_protocol" {
  default = "TLS"
}

variable "listener_443_port" {
  default = "443"
}

variable "Nombre" {
  default = ""
}

variable "ElasticIP1" {
  default = false
}

variable "ElasticIP2" {
  default = false
}
variable "allocation_id_IP1" {
  default = ""
}

variable "allocation_id_IP2" {
  default = ""
}

variable "subnet_id_IP1" {
  default = ""
}

variable "subnet_id_IP2" {
  default = ""
}

variable "target_groups" {
  type = map(object({
    port                  = number,
    name                  = string,
    protocol              = string,
    health_check_protocol = string
  })
  )

  default = {
    "tg-80"  = { port = 80, name = "tg-80", protocol = "TCP", health_check_protocol = "HTTP" },
    "tg-443" = { port = 443, name = "tg-443", protocol = "TLS", health_check_protocol = "HTTPS" }
  }
}
