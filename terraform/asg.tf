data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  # ECR registry hostname: <account>.dkr.ecr.<region>.amazonaws.com
  ecr_registry = split("/", aws_ecr_repository.backend.repository_url)[0]

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    docker_image  = var.backend_docker_image != "" ? var.backend_docker_image : "${aws_ecr_repository.backend.repository_url}:latest"
    ecr_registry  = local.ecr_registry
    app_port      = var.app_port
    db_host       = aws_db_instance.main.address
    db_name       = var.db_name
    db_secret_arn = aws_db_instance.main.master_user_secret[0].secret_arn
    aws_region    = var.aws_region
    log_group     = aws_cloudwatch_log_group.backend.name
    cors_origin   = local.cors_origin
  })
}

resource "aws_launch_template" "backend" {
  name_prefix            = "${var.project_name}-lt-"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  user_data              = base64encode(local.user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-backend"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  target_group_arns         = [aws_lb_target_group.backend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 90

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend"
    propagate_at_launch = true
  }
}
