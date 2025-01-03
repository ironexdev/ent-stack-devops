variable "frontend_domain_name" {
  description = "The domain name for the frontend"
  type        = string
}

variable "backend_domain_name" {
  description = "The domain name for the backend API"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "ent-uat"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "region_shorthand" {
  description = "The shorthand name of the region"
  type        = string
  default     = "use1"
}

variable "availability_zone1" {
  description = "The first availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone2" {
  description = "The second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the first public subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "private_subnet1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
  default     = "10.2.2.0/24"
}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
  default     = "10.2.3.0/24"
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
  default     = "10.2.4.0/24"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "ec2_instance_ami" {
  description = "The AMI for the EC2 instance"
  type        = string
  default     = "al2023-ami-ecs-hvm-*-x86_64"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "backend_port" {
  description = "The port for the backend"
  type        = number
  default     = 3001
}

variable "frontend_port" {
  description = "The port for the frontend"
  type        = number
  default     = 3000
}

variable "database_port" {
  description = "The port for the database"
  type        = number
  default     = 3306
}

# Just a placeholder task, will be overwritten during deployment
variable "backend_container_definition" {
  description = "Container definition for ECS task"
  default = {
    name      = "backend"
    image     = "node:22"
    essential = true
    cpu       = 330
    memory    = 330

    portMappings = [
      {
        containerPort = 3001
        hostPort      = 3001
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/ent/uat/backend",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "backend"
      }
    }

    command = [
      "node", "-e",
      "require('http').createServer((req, res) => res.end('Backend running the default container')).listen(3001)"
    ]
  }
}

# Just a placeholder task, will be overwritten during deployment
variable "frontend_container_definition" {
  description = "Container definition for ECS task"
  default = {
    name      = "frontend"
    image     = "node:22"
    essential = true
    cpu       = 330
    memory    = 330

    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/ent/uat/frontend",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "frontend"
      }
    }

    command = [
      "node", "-e",
      "require('http').createServer((req, res) => res.end('Frontend running the default container')).listen(3000)"
    ]
  }
}

# Just a placeholder task, will be overwritten during deployment
variable "database_container_definition" {
  description = "Container definition for ECS task"
  default = {
    name      = "database"
    image     = "node:22"
    essential = true
    cpu       = 330
    memory    = 512

    portMappings = [
      {
        containerPort = 3306
        hostPort      = 3306
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/ent/uat/database",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "database"
      }
    }

    command = [
      "node", "-e",
      "require('http').createServer((req, res) => res.end('Database running the default container')).listen(3306)"
    ]
  }
}