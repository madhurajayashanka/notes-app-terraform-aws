# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# VPC, Subnets, and Security Groups
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"  # Updated CIDR block
  availability_zone = var.subnet_availability_zone_1
  map_public_ip_on_launch = true  # Enables auto-assignment of public IP addresses
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.subnet_availability_zone_1
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.subnet_availability_zone_2
}

resource "aws_security_group" "instance_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "instance_sg"
  description = "Allow traffic from EC2 within the VPC"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.rds_sg.id
    ]
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "app_sg"
  description = "Allow inbound traffic from internet only to Express.js app"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "rds_sg"
  description = "Allow inbound traffic to RDS instance"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# S3 Bucket
resource "aws_s3_bucket" "notes_bucket" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "notes_bucket_access_block" {
  bucket = aws_s3_bucket.notes_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "notes_bucket_policy" {
  bucket = aws_s3_bucket.notes_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.notes_bucket.arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      },
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "${aws_s3_bucket.notes_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "aws:sourceVpc" = aws_vpc.main.id
          }
        }
      }
    ]
  })
}

# DynamoDB Table
resource "aws_dynamodb_table" "notes_table" {
  name           = var.dynamodb_table_name
  hash_key       = "note_id"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "note_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "postgresql_subnet_group" {
  name       = "postgresql_subnet_group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "postgresql_subnet_group"
  }
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier              = var.db_instance_identifier
  allocated_storage       = 10
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "12"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.postgres12"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.postgresql_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  final_snapshot_identifier = "notes-db-snapshot"
}

# EC2 Instance in Public Subnet
resource "aws_instance" "web" {
  ami                         = var.ec2_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id  # Use the public subnet ID
  associate_public_ip_address = true
  tags                        = var.tags
}
# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policies for EC2 Role
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  description = "Allows access to DynamoDB, S3, RDS within VPC"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "rds-db:connect"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}
