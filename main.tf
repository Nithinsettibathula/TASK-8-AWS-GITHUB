provider "aws" {
  region = "us-east-1"
}

# Fetching the existing VPC from your screenshot
data "aws_vpc" "existing" {
  id = "vpc-0295253d470704295" 
}

# Automatically fetching subnets from this VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi-nithin"
  retention_in_days = 7
}

# ECS Cluster
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-nithin"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-nithin"
  vpc_id      = data.aws_vpc.existing.id
  description = "Allow Strapi traffic"

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

# ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-nithin"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = "strapi-task"
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.existing.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "Strapi-Monitoring-Nithin"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ServiceName", "strapi-service-nithin", "ClusterName", "strapi-cluster-nithin" ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          period = 60, stat = "Average", region = "us-east-1", title = "ECS CPU & Memory"
        }
      }
    ]
  })
}