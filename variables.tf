variable "vpc_id" {
  description = "VPC ID for ECS cluster"
  type        = string
  default     = "vpc-0d10393a33604e714"
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS cluster"
  type        = list(string)
  default     = ["subnet-01d80ff00b2e4cee6", "subnet-0e23ea4a450f914b4"]
}
