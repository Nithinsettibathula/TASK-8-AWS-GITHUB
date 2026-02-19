provider "aws" {
  region = "us-east-1"
}

# Fetch Defaults
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter { name = "vpc-id", values = [data.aws_vpc.default.id] }
}

# 1. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi"
  retention_in_days = 7
}

# 2. ECS Cluster with Metrics Enabled
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-v2"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 3. Security Group
resource "aws_security_group" "strapi_sg" {
  name   = "strapi-sg-final"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 1337
    to_port = 1337
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = "strapi-task"
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }
}