variable "aws_region" {
  type        = string
  description = "Target AWS Region"
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance sizing"
  default     = "t2.micro"
}
