variable "vpc_id" {
  default = ""
}

variable "name" {
  default = ""
}

variable "description" {
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

variable "r1_ingress_source_security_group_id" {
  default = ""
}

variable "r1_ingress_sg_rule_description" {
  default = ""
}

variable "r1_ingress_port" {
  default = 22
}

variable "r1_ingress_ipv6_cidr_blocks" {
  default = ["::/0"]
}

variable "r2_ingress_sg_rule_description" {
  default = ""
}

variable "r2_ingress_port" {
  default = 22
}

variable "r2_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "r2_ingress_ipv6_cidr_blocks" {
  default = ["::/0"]
}

variable "r3_ingress_sg_rule_description" {
  default = ""
}

variable "r3_ingress_port" {
  default = 80
}

variable "r3_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "r3_ingress_ipv6_cidr_blocks" {
  default = ["::/0"]
}

variable "r1_egress_protocol" {
  default = "all"
}

variable "r1_egress_sg_rule_description" {
  default = ""
}

variable "r1_egress_port" {
  default = 22
}

variable "r1_egress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "r1_egress_ipv6_cidr_blocks" {
  default = ["::/0"]
}