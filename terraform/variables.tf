variable "aws_region" {
  description = "AWS region where the website server will be created."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name used for AWS resource tags."
  type        = string
  default     = "devops-final-site"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name used for SSH access."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to connect over SSH. For a real submission, restrict this to your public IP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
