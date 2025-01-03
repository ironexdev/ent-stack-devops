resource "aws_ecs_cluster" "ent-uat-cluster" {
  name = var.project_name
}

data "aws_iam_policy_document" "ecs_instance_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_cloudwatch_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_s3_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_cloudwatch_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.project_name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecr_readonly" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_security_group" "ecs_instance_sg" {
  name        = "${var.project_name}-ecs-instance-sg"
  description = "Security group for ECS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port = var.frontend_port
    to_port   = var.frontend_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.backend_port
    to_port   = var.backend_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.database_port
    to_port   = var.database_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ecs_ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = [var.ec2_instance_ami]
  }
}

data "template_file" "ecs_instance_user_data" {
  template = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ent-uat-cluster.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_instance" "ecs_instance" {
  ami                  = data.aws_ami.ecs_ami.id
  instance_type        = var.ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ecs_instance_sg.id]
  user_data            = data.template_file.ecs_instance_user_data.rendered
  monitoring           = false

  tags = {
    Name = "${var.project_name}-ecs-instance"
  }
}

resource "aws_eip" "ecs_instance_eip" {
  instance = aws_instance.ecs_instance.id
}

resource "aws_ecs_task_definition" "backend_task" {
  family       = "${var.project_name}-backend"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([var.backend_container_definition])
}

resource "aws_ecs_task_definition" "frontend_task" {
  family       = "${var.project_name}-frontend"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([var.frontend_container_definition])
}

resource "aws_ecs_task_definition" "database_task" {
  family       = "${var.project_name}-database"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([var.database_container_definition])
}

resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-backend"
  cluster         = aws_ecs_cluster.ent-uat-cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.project_name}-frontend"
  cluster         = aws_ecs_cluster.ent-uat-cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}

resource "aws_ecs_service" "database_service" {
  name            = "${var.project_name}-database"
  cluster         = aws_ecs_cluster.ent-uat-cluster.id
  task_definition = aws_ecs_task_definition.database_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/ent/uat/backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/ent/uat/frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "database" {
  name              = "/ecs/ent/uat/database"
  retention_in_days = 7
}