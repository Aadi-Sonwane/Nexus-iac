# =================================================================
# Module: infra | File: security_groups.tf
# Description: Layered Security Perimeter (ALB -> App -> Storage)
# =================================================================

# --- 1. ALB Security Group (Front Door) ---
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env}-alb-sg"
  description = "Accepts public web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.env}-alb-sg" }
}

# --- 2. Application Security Group (Nexus Server) ---
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.env}-app-sg"
  description = "Restricted traffic for Nexus Application"
  vpc_id      = aws_vpc.main.id

  # Traffic from Load Balancer
  ingress {
    description     = "Nexus UI from ALB"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Health Checks from VPC Infrastructure
  ingress {
    description      = "Internal VPC Health Checks"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  # Docker Registry Inbound
  ingress {
    description     = "Docker Registry via ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH Management (Limited to Internal Network)
  ingress {
    description      = "Internal SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    description      = "Internet access for downloads"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.env}-app-sg" }
}

# --- 3. Storage Security Group (EFS) ---
resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-${var.env}-efs-sg"
  description = "Allows NFS traffic only from the App Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "NFS from App SG"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.env}-efs-sg" }
}