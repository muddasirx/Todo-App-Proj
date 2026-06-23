variable "aws_region" {
  description = "AWS region for all resources except the CloudFront ACM cert (always us-east-2)."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Short name used to prefix/tag resources."
  type        = string
  default     = "m-todo-proj"
}

# ---- Networking ----

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ---- Domain ----

variable "domain_name" {
  description = "Apex hosted zone, must already exist in Route 53."
  type        = string
  default     = "muhammadmuddasir.cloud"
}

variable "frontend_subdomain" {
  description = "Subdomain for the CloudFront/S3 frontend. Leave empty to use the bare apex domain."
  type        = string
  default     = ""
}

variable "include_www" {
  description = "Also alias www.<domain_name> to the same CloudFront distribution. Only applies when frontend_subdomain is empty (apex)."
  type        = bool
  default     = true
}

variable "api_subdomain" {
  description = "Subdomain for the ALB-fronted backend API."
  type        = string
  default     = "api"
}

# ---- S3 frontend ----

variable "frontend_bucket_name" {
  description = "Must be globally unique across all of S3. Change this before applying."
  type        = string
  default     = "m-todo-proj-frontend"
}

# ---- Compute ----

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "backend_docker_image" {
  description = "ECR image URI. Populated automatically from the ecr_repository_url output — run terraform apply once to create the repo, push your image, then apply again (or pass -var at apply time)."
  type        = string
  default     = ""  # set via ecr_repository_url output after first apply
}

variable "app_port" {
  type    = number
  default = 3000
}

# ---- Database ----

variable "db_name" {
  type    = string
  default = "tododb"
}

variable "db_username" {
  type    = string
  default = "todoadmin"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "cf_cert_arn" {
  description = "ARN of the ACM certificate to use for the CloudFront distribution. Must be in us-east-1."
  type        = string
  default = "arn:aws:acm:us-east-1:395063533284:certificate/46e0cabf-000d-454f-896e-d7b23c655173"
}

variable "alb_cert_arn" {
  description = "ARN of the ACM certificate to use for the ALB. Must be in us-east-2."
  type        = string
  default = "arn:aws:acm:us-east-2:395063533284:certificate/65185d64-5452-4842-a4cc-93617865f52b"
}
