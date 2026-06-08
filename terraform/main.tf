provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------
# ECR REPOSITORY
# -----------------------------
resource "aws_ecr_repository" "hmrs" {
  name = "hmrs-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# -----------------------------
# ECS CLUSTER
# -----------------------------
resource "aws_ecs_cluster" "hmrs" {
  name = "hmrs-cluster"
}

# -----------------------------
# CLOUDWATCH LOG GROUP
# -----------------------------
resource "aws_cloudwatch_log_group" "hmrs" {
  name = "/ecs/hmrs-app"
}

# -----------------------------
# IAM EXECUTION ROLE
# -----------------------------
resource "aws_iam_role" "ecs_execution_role" {

  name = "hmrs-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {

  role       = aws_iam_role.ecs_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# ECS TASK DEFINITION
# -----------------------------
resource "aws_ecs_task_definition" "hmrs" {

  family                   = "hmrs-app"

  requires_compatibilities = ["FARGATE"]

  network_mode             = "awsvpc"

  cpu                      = "512"

  memory                   = "1024"

  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

 

  container_definitions = jsonencode([
    {
      name  = "hmrs-app"

      image = "${aws_ecr_repository.hmrs.repository_url}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = "/ecs/hmrs-app"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# -----------------------------
# ECS SERVICE
# -----------------------------
resource "aws_ecs_service" "hmrs" {

  name            = "hmrs-service"

  cluster         = aws_ecs_cluster.hmrs.id

  task_definition = aws_ecs_task_definition.hmrs.arn

  desired_count   = 1

  launch_type     = "FARGATE"

   network_configuration {
    subnets = data.aws_subnets.default.ids
    assign_public_ip = true
  }
}
