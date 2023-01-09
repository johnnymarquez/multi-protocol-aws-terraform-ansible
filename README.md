# AWS ALB target group for NLB Infrastructure, Nginx Configuration & Security Hardening

This repository contains a complete example & workflow of an AWS architecture. The infrastructure is backed up by
terraform, configuration management by Ansible, Linux security hardening scripts and workflow automated deployment with
GitHub Actions. The most important feature of this sample architecture is the provisioning of both Layer 7 & layer 4 by
implementing an Application Load Balancer and Network Load Balancer in the same traffic route. This feature is unique
and provides the possibility of using static IP, AWS PrivateLink for ALB, and multiprotocol connections.

[Application Load Balancer target group for Network Load Balancer](https://aws.amazon.com/blogs/networking-and-content-delivery/application-load-balancer-type-target-group-for-network-load-balancer/)

## Architecture

The code implements EC2 instances with the latest Amazon Linux 2 image, backed up by en Autoscaling Group which
implements a Launch Template configured with a Linux security hardening script at ./scripts/cis.sh. The instances are
configured behind an Application Load balancer, which at the same time it's configured behind a Network Load Balancer.

## Terraform

In the root directory terraform files can be found with the necessary values to implement an example infrastructure with
customized modules.
Resource include:

- Providers.
- Local backend.
- Autoscaling group.
- Application load balancer.
- Network load balancer.
- Cloudwwatch alarms.
- Security groups.
- Eventbridge rules.
- Lambda functions.

# Ansible

Once the infrastructure is fully provisioned, the EC2 instances can be configured as Nginx servers by Ansible playbook at ./playbook/nginx.yaml
