provider "aws" {
  region = "us-east-1"
}

# 1. Fetching the existing VPC from your screenshot
data "aws_vpc" "existing" {
  id = "vpc-0295253d470704295" 
}

# 2. Automatically fetching subnets from this VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# 3. CloudWatch Log Group for Strapi logs
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi-nithin"
  retention_in_days = 7
}

# 4. ECS Cluster with Monitoring enabled
resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-nithin"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# 5. Security Group for Port 1337
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

# 6. ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-nithin"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = "strapi-task" # Matches family in task-definition.json
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.existing.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }
}

# 7. CloudWatch Dashboard for Metrics (CPU, Memory, Network)
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
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "NetworkRxBytes", "ServiceName", "strapi-service-nithin", "ClusterName", "strapi-cluster-nithin" ],
            [ ".", "NetworkTxBytes", ".", ".", ".", "." ]
          ]
          period = 60, stat = "Average", region = "us-east-1", title = "Network In/Out"
        }
      }
    ]
  })
}