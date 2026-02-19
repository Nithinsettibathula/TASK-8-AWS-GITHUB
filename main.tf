provider "aws" {
  region = "us-east-1"
}

# 1. VPC and Subnets (Default resources fetch cheyadam)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2. CloudWatch Log Group (Instruction 2: Logging setup)
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi-nithin"
  retention_in_days = 7
}

# 3. ECS Cluster with Container Insights (Instruction 3: Monitoring/Metrics)
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-nithin"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 4. Security Group (Port 1337 open cheyadam)
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-nithin"
  description = "Allow Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

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

# 5. ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-nithin"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = "strapi-task" # Matches family name in task-definition.json
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }
}