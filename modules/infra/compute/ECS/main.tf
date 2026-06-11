resource "aws_ecs_cluster" "hmrs_np_cluster" {
  name = "hmrs_np_cluster"
}




resource "aws_cloudwatch_log_group" "hmrs_np_cloudwatch_lg" {
  name = "/ecs/hmrs_np_app"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.pvt_rt_1_id]


  tags = {
    Environment = "test",
    Name        = "hmrs-np-s3-endpoint"
  }
}


locals {
  containerports = [8080, 8081, 8082]
  sg_ports = [80, 443, 22]
}

resource "aws_security_group" "hmrs_ecs_sg" {
  name        = "hmrs_ecs_sg"
  description = "Security group for HMRS ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Environment = "test"
    Name        = "hrms_vpc_endpoints_sg"
  }
}
  
resource "aws_vpc_endpoint" "hmrs_ecs_cwlogs_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids         =  var.subnet_ids
  security_group_ids = [aws_security_group.hmrs_ecs_sg.id]

  private_dns_enabled = true

  tags = {
    Environment = "test"
    Name        = "hmrs-np-logs-endpoint"
  }
}


resource "aws_vpc_endpoint" "hmrs_ecs_ecrapi_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids         =  var.subnet_ids
  security_group_ids = [aws_security_group.hmrs_ecs_sg.id]

  private_dns_enabled = true

  tags = {
    Environment = "test"
    Name        = "hmrs-np-ecrapi-endpoint"
  }
}

resource "aws_vpc_endpoint" "hmrs_ecs_ecrdkr_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids         =  var.subnet_ids
  security_group_ids = [aws_security_group.hmrs_ecs_sg.id]

  private_dns_enabled = true
  depends_on = [aws_vpc_endpoint.hmrs_ecs_ecrapi_endpoint]
  tags = {
    Environment = "test"
    Name        = "hmrs-np-ecrdkr-endpoint"
  }
}


resource "aws_ecs_task_definition" "hmrs_ecs_taskdefinition" {

  family = "hmrs_np_app_taskdefinition"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu = "512"

  memory = "1024"

  execution_role_arn = var.ecs_execution_role_arn

   depends_on = [
    aws_cloudwatch_log_group.hmrs_np_cloudwatch_lg,
    aws_vpc_endpoint.hmrs_ecs_cwlogs_endpoint,
    aws_vpc_endpoint.hmrs_ecs_ecrapi_endpoint,
    aws_vpc_endpoint.hmrs_ecs_ecrdkr_endpoint,
    aws_vpc_endpoint.s3
  ]


  container_definitions = jsonencode([
    {
      name = "hmrs_np_app"

      image = "${var.repo_url}:latest"

      essential = true

      portMappings = [
        for port in local.containerports : {
          containerPort = port
          hostPort      = port
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = "/ecs/hmrs_np_app"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "hmrs" {

  name = "hmrs_np_app_service"

  cluster = aws_ecs_cluster.hmrs_np_cluster.id

  task_definition = aws_ecs_task_definition.hmrs_ecs_taskdefinition.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
  }
}


