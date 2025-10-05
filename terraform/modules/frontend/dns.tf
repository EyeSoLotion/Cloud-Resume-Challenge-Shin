# Create a Hosted Zone
data "aws_route53_zone" "main" {
  name         = "eyesolotion.com"
  private_zone = false
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Create SSL Certificate
resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = "eyesolotion.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.eyesolotion.com"
  ]
}

# DNS Validation
resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 300
}

resource "aws_acm_certificate_validation" "ssl_validation" {
  provider                = aws.us-east-1
  depends_on              = [aws_acm_certificate.cert, aws_route53_record.validation_record]
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}

# CloudFront Pointers
resource "aws_route53_record" "cf-a-record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.eyesolotion.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_acm_certificate.cert, aws_cloudfront_distribution.s3_distribution]

}

resource "aws_route53_record" "cf-aa-record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "eyesolotion.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_acm_certificate.cert, aws_cloudfront_distribution.s3_distribution]

}