output "log_group_name" {
  description = "name of the log group"
  value       = aws_flow_log.vpc_flow_log.log_group_name
}
