variable "vpc_ids" {
  type        = list(string)
  description = "List of VPC IDs for which you want to create Flow Logs"
}

locals {
  # For more details: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-custom
  custom_log_format_v5 = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}

resource "aws_flow_log" "centralized" {
  for_each             = toset(var.vpc_ids)
  log_destination      = "arn:aws:s3:::sec-chronicle-all-vpcflowlogs" # Optionally, a prefix can be added after the ARN.
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = each.value
  log_format           = local.custom_log_format_v5 # If you want fields from VPC Flow Logs v3+, you will need to create a custom log format.
  destination_options {
    file_format        = "plain-text"
    per_hour_partition = true
  }
  tags                 = {
    Name = "centralized_flow_log_${each.value}"
  }
}