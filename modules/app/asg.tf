# =================================================================
# Module: app | File: asg.tf
# Description: Launch Template, Auto Scaling, and LB Registration
# =================================================================

# --- 1. Launch Template ---
resource "aws_launch_template" "nexus" {
  name_prefix   = "${var.project_name}-${var.env}-nexus-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile { name = aws_iam_instance_profile.nexus_profile.name }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # Link to the Cloud-Init config rendered in this module
  user_data = data.cloudinit_config.nexus_setup.rendered

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-${var.env}-nexus-server" }
  }
}

# --- 2. Auto Scaling Group ---
resource "aws_autoscaling_group" "nexus_asg" {
  name                = "${var.project_name}-${var.env}-asg"
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.nexus.id
    version = "$Latest"
  }
  target_group_arns = [var.target_group_arn, var.nexus_ec2_tg_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 900
}
