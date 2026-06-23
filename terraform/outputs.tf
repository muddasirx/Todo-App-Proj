output "frontend_url" {
  value = "https://${local.frontend_domain}"
}

output "frontend_aliases" {
  value = local.frontend_aliases
}

output "api_url" {
  value = "https://${var.api_subdomain}.${var.domain_name}"
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN holding the auto-generated DB master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

# Outputs:

# alb_dns_name = "m-todo-proj-alb-12110006.us-east-2.elb.amazonaws.com"
# api_url = "https://api.muhammadmuddasir.cloud"
# cloudfront_domain_name = "d1vcp6y5rggx63.cloudfront.net"
# ecr_repository_url = "395063533284.dkr.ecr.us-east-2.amazonaws.com/m-todo-proj-backend"
# frontend_aliases = tolist([
#   "muhammadmuddasir.cloud",
#   "www.muhammadmuddasir.cloud",
# ])
# frontend_bucket_name = "m-todo-proj-frontend"
# frontend_url = "https://muhammadmuddasir.cloud"
# rds_endpoint = "m-todo-proj-db.c5m0c60ykcap.us-east-2.rds.amazonaws.com"
# rds_secret_arn = "arn:aws:secretsmanager:us-east-2:395063533284:secret:rds!db-cbdb826c-8aa4-47db-b7ae-e650bf6144db-sdt2Ip"
# vpc_id = "vpc-0e53f6ecb8efde2de"