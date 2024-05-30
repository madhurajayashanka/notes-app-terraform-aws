output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_1_id" {
  description = "The ID of the first subnet"
  value       = aws_subnet.subnet_1.id
}

output "subnet_2_id" {
  description = "The ID of the second subnet"
  value       = aws_subnet.subnet_2.id
}

output "instance_sg_id" {
  description = "The ID of the security group for the instance"
  value       = aws_security_group.instance_sg.id
}

output "app_sg_id" {
  description = "The ID of the security group for the app"
  value       = aws_security_group.app_sg.id
}

output "rds_sg_id" {
  description = "The ID of the security group for RDS"
  value       = aws_security_group.rds_sg.id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.notes_bucket.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.notes_table.name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.postgresql.endpoint
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}
