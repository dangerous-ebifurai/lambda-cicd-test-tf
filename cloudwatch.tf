locals {
  log_name = "/ecs/${var.pj_name}-streamlit"
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = local.log_name
  retention_in_days = 7
  tags = {
    name = var.pj_name
  }
}