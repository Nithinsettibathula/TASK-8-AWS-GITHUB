provider "aws" {
  region = "us-east-1"
}

# 1. Fetch Default VPC and Subnets automatically
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2. CloudWatch Log Group (Instruction: /ecs/strapi)
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

# 3. ECS Cluster with Name Changed to avoid Idempotency Error
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-v2" # Changed from strapi-cluster to strapi-cluster-v2
  
  setting {
    name  = "containerInsights"
    value = "enabled" # Instruction: Enable collection of ECS metrics
  }
}

# 4. IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "strapi-execution-role-v2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 5. ECS Service (Fargate)
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }
}

# 6. ECS Task Definition (Instruction: awslogs driver & ecs prefix)
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "strapi-app"
    image = "811738710312.dkr.ecr.us-east-1.amazonaws.com/strapi-repo:latest"
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/strapi"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs" # Instruction: ecs prefix
      }
    }
  }])
}

# 7. Security Group
resource "aws_security_group" "strapi_sg" {
  name   = "strapi-sg-v2"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}