resource "aws_ecs_cluster" "test" {
  name = "${var.pj_name}-cluster"
  tags = {
    name = var.pj_name
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

data "aws_ecr_image" "test" {
  for_each        = toset(var.images)
  repository_name = "${var.pj_name}/${each.value}"
  image_tag = "latest"
}

# タスク定義の作成
resource "aws_ecs_task_definition" "test" {
  for_each = toset(var.images)
  family                   = "${var.pj_name}-${each.value}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.pj_name}-container"
      image = data.aws_ecr_image.test[each.value].image_uri
      portMappings = [
        {
          containerPort = 8501
          hostPort      = 8501
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ECS実行ロールの作成
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.pj_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECSサービスの作成
# resource "aws_ecs_service" "test" {
#     for_each = toset(var.images)

#   name            = "${var.pj_name}-${each.value}"
#   cluster         = aws_ecs_cluster.test.id
#   task_definition = aws_ecs_task_definition.test[each.value].arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     security_groups = [aws_security_group.ecs_tasks.id]
#     subnets         = aws_subnet.public[*].id
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.app.arn
#     container_name   = "${var.pj_name}-container"
#     container_port   = 8501
#   }

#   depends_on = [aws_lb_listener.http]
# }