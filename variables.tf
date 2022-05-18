variable "vpc_id" {
  description   = "type your vpc"
  default = "vpc-0ede182f9f70a6583"
}

variable "container_port" {
  description   = "type your container port"
  type          = string
}

variable "host_port" {
  description   = "type your container port"
  default = "80"
}
variable "name" {
  description   = "type your project name"
  type          = string
}

variable "environment" {
  description   = "type your project name"
  type          = string
}

variable "container_image" {
  description   = "type your container image"
  type          = string
}

variable "health_check_path" {
  description   = "type your health check path"
  type          = string
}

variable "subnets" {
  type = list(any)
  description   = "type your existing subnet"
  default = [ "subnet-0a9d90a67dd552e24", "subnet-04e2e1fbaec52b52b", ]
}

variable "container_environment" {
  description   = "type your health check path"
  default = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created"
  default = "us-east-2"
}
variable "container_cpu" {
  description = "the AWS region in which resources are created"
  default = "1024"
}
variable "container_memory" {
  description = "the AWS region in which resources are created"
  default = "3072"
}
# variable "subnet_mapping" {
#   default     = []
#   type        = list(map(string))
#   description = "A list of subnet mapping blocks describing subnets to attach to network load balancer"
# }

