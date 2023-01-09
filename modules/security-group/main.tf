resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Creator       = var.creator
    Stack         = var.stack
    "Cost Center" = var.cost_center
    Name          = var.name
  }
}

resource "aws_security_group_rule" "ingress_r1" {
  description              = var.r1_ingress_sg_rule_description
  type                     = "ingress"
  from_port                = var.r1_ingress_port
  to_port                  = var.r1_ingress_port
  protocol                 = "tcp"
  source_security_group_id = var.r1_ingress_source_security_group_id
  prefix_list_ids          = []
  security_group_id        = aws_security_group.sg.id
}

resource "aws_security_group_rule" "ingress_r2" {
  description       = var.r2_ingress_sg_rule_description
  type              = "ingress"
  from_port         = var.r2_ingress_port
  to_port           = var.r2_ingress_port
  protocol          = "tcp"
  cidr_blocks       = var.r2_ingress_cidr_blocks
  ipv6_cidr_blocks  = var.r2_ingress_ipv6_cidr_blocks
  prefix_list_ids   = []
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "ingress_r3" {
  description       = var.r3_ingress_sg_rule_description
  type              = "ingress"
  from_port         = var.r3_ingress_port
  to_port           = var.r3_ingress_port
  protocol          = "tcp"
  cidr_blocks       = var.r3_ingress_cidr_blocks
  ipv6_cidr_blocks  = var.r3_ingress_ipv6_cidr_blocks
  prefix_list_ids   = []
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "egress_r1" {
  description       = var.r1_egress_sg_rule_description
  type              = "egress"
  from_port         = var.r1_egress_port
  to_port           = var.r1_egress_port
  protocol          = var.r1_egress_protocol
  cidr_blocks       = var.r1_egress_cidr_blocks
  ipv6_cidr_blocks  = var.r1_egress_ipv6_cidr_blocks
  prefix_list_ids   = []
  security_group_id = aws_security_group.sg.id
}
