
variable "aws_region" {
  default = "us-east-1"
}

variable "subnet_availability_zone_1" {
  default = "us-east-1a"
}


variable "subnet_availability_zone_2" {
  default = "us-east-1b"
}

variable "s3_bucket_name" {
  default = "madhura-notes-app-bucket-v1"
}

variable "dynamodb_table_name" {
  default = "notes"
}

variable "tags" {
  default = {
    "Name" = "notes-app"
  }
}

variable "db_instance_identifier" {
  default = "notes-db-instance"
}

variable "db_username" {
  default = "madhura"
}

variable "db_password" {
  default = "hW8z7J8z!"
}

variable "ec2_ami" {
  default = "ami-04b70fa74e45c3917" # Amazon Ubuntu 24.04 LTS
}

