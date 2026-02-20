# Task 8: Strapi Deployment & Infrastructure

* **Name**: Nithin Settibathula


## 🎯 Objectives
* Deploy Strapi application on **AWS ECS Fargate**.
* Manage Infrastructure as Code (IaC) using **Terraform**.
* Implement real-time monitoring with **CloudWatch Dashboards**.

## 🛠️ Implementation Highlights
* **VPC**: Integrated with existing VPC `vpc-0295253d470704295`.
* **Compute**: Configured Task Definition with **1024 CPU** and **2048 Memory** for optimal performance.
* **IAM**: Utilized organization role `arn:aws:iam::811738710312:role/ecs_fargate_taskRole`.
* **Observability**: Created a custom dashboard for tracking CPU, Memory, and Network metrics.

## 📁 Repository Contents
* `main.tf`: Terraform scripts for AWS resource provisioning.
* `.aws/task-definition.json`: ECS container and role configurations.
* `.github/workflows/`: CI/CD pipelines for automated deployment.

## 🚀 How to Review
1. Access the branch: `nithin-settibathula`.
2. Inspect `main.tf` for infrastructure logic.
3. Refer to the Pull Request for deployment logs and screenshots.
