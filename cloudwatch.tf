resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = toset(var.images)
  name              = "${var.pj_name}-${each.value}"
  retention_in_days = 7
  tags = {
    name = var.pj_name
  }
}