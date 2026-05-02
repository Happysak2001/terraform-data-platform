# ─────────────────────────────────────────
# SECURITY GROUP FOR EC2
# The security guard for our server
# Controls what traffic can come IN and go OUT
# ─────────────────────────────────────────

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 data processing server"
  vpc_id      = var.vpc_id

  # INBOUND: allow SSH from anywhere
  # Port 22 = SSH (how you connect to the server remotely)
  # For a learning project, open to all is fine
  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]   # all IPv4
    ipv6_cidr_blocks = ["::/0"]        # all IPv6
  }

  # OUTBOUND: allow all outgoing traffic
  # The server needs to download packages, talk to RDS, etc.
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 means ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# ─────────────────────────────────────────
# SECURITY GROUP FOR RDS
# Only allows connections FROM the EC2 server
# Nobody else can touch the database
# ─────────────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS - only EC2 can connect"
  vpc_id      = var.vpc_id

  # INBOUND: only allow MySQL traffic from the EC2 security group
  # Port 3306 = MySQL
  ingress {
    description     = "MySQL from EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]  # reference to EC2 SG above
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# ─────────────────────────────────────────
# FIND THE LATEST AMAZON LINUX 2 AMI
# AMI = Amazon Machine Image = the OS for your EC2
# Like choosing which operating system to install
# This data source looks it up automatically — no hardcoding
# ─────────────────────────────────────────

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]  # Amazon Linux 2023
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─────────────────────────────────────────
# EC2 INSTANCE — the work computer / processing server
# Lives in the public subnet so you can SSH into it
# ─────────────────────────────────────────

resource "aws_instance" "data_server" {
  ami                    = data.aws_ami.amazon_linux.id   # OS we found above
  instance_type          = var.instance_type              # t3.micro = free tier eligible
  subnet_id              = var.public_subnet_id           # place it in public subnet
  vpc_security_group_ids = [aws_security_group.ec2.id]   # attach the security guard
  key_name               = var.key_pair_name              # SSH key to log in with
  iam_instance_profile   = var.iam_instance_profile      # the badge — allows EC2 to access S3

  # user_data = startup script that runs when EC2 first boots
  # Like a setup checklist that runs automatically
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 pip mysql
    pip3 install boto3 pandas
    echo "Data platform server ready" >> /var/log/setup.log
  EOF

  tags = {
    Name = "${var.project_name}-data-server"
  }
}
