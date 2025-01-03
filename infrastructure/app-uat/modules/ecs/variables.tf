variable "project_name" {
  description = "The project name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type        = string
}

variable "ec2_instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "ec2_instance_ami" {
  description = "The AMI for the EC2 instance"
  type        = string
}

variable "backend_port" {
  description = "The port for the backend API"
  type        = number
}

variable "frontend_port" {
  description = "The port for the frontend"
  type        = number
}

variable "database_port" {
  description = "The port for the database"
  type        = number
}

variable "backend_container_definition" {
  description = "Container definition for ECS task"
}

variable "frontend_container_definition" {
  description = "Container definition for ECS task"
}

variable "database_container_definition" {
  description = "Container definition for ECS task"
}