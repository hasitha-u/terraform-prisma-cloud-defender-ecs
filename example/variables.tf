variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "name" {
  description = "Deployment Name"
  type        = string
  default     = "prisma-cloud-defender"
}

variable "instance_type" {
  description = "The type of ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "autoscalling_min_size" {
  description = "ECS Autoscalling min size"
  type        = number
  default     = 1
}

variable "autoscalling_max_size" {
  description = "ECS Autoscalling max size"
  type        = number
  default     = 3
}

variable "autoscalling_desired_capacity" {
  description = "ECS Autoscalling desired capacity"
  type        = number
  default     = 2
}


variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "console_address" {
  description = "Prisma Cloud CWP/Compute console address"
  type        = string
}

variable "api_token" {
  description = "Prisma Cloud CWP/Compute API token"
  type        = string
  sensitive   = true
}
