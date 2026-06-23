# Assumes the muhammadmuddasir.cloud hosted zone already exists (per your
# earlier CloudFront/Java app setup). This only looks it up, it does not
# create or modify the zone itself.
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1
  domain   = var.domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "alb" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

# ---------------- DNS records pointing at the actual resources ----------------

resource "aws_route53_record" "frontend" {
  for_each = toset(local.frontend_aliases)

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.backend.dns_name
    zone_id                = aws_lb.backend.zone_id
    evaluate_target_health = true
  }
}
