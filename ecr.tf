resource "aws_ecr_repository" "test" {
  for_each = toset(var.images)
  name     = "${var.pj_name}/${each.value}"
  tags = {
    name = var.pj_name
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

data "aws_ecr_lifecycle_policy_document" "test" {
  rule {
    priority    = 1
    description = "This is a test."

    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["latest"]
      count_type      = "imageCountMoreThan"
      count_number    = 5
    }
  }
}

resource "aws_ecr_lifecycle_policy" "test" {
  for_each   = toset(var.images)
  repository = aws_ecr_repository.test[each.value].name
  policy     = data.aws_ecr_lifecycle_policy_document.test.json
}

resource "aws_ecr_repository_policy" "lambda" {
  for_each   = toset(var.images)
  repository = aws_ecr_repository.test[each.value].name
  policy     = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}