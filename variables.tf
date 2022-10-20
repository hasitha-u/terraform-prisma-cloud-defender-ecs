
variable "name" {
  description = "Defender Deployment name"
  type        = string
  default     = "prisma-cloud-defender"
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "defender_image" {
  description = "Prisma Cloud Defender Image"
  type        = string
}

variable "prisma_cloud_ws_address" {
  description = "Websocket address for the Prisma Cloud CWP console (Ex: wss://us-east1.cloud.twistlock.com:443)"
  type        = string
}

variable "prisma_cloud_registry_token" {
  description = "Prisma Cloud registry (registry.twistlock.com) access token"
  type        = string
  sensitive   = true
}

variable "defender_install_bundle" {
  description = "Prisma Cloud Defender INSTALL_BUNDLE "
  type        = string
  sensitive   = true
}

variable "defender_memory" {
  description = "Memory (in MiB) for the Defender task "
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
