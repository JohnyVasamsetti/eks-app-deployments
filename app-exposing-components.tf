resource "aws_route53_zone" "hosted_zone" {
  name = local.domain
}

resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = local.domain
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "dns_validation_records" {
  for_each = { for dns_validation_records in aws_acm_certificate.acm_certificate.domain_validation_options : dns_validation_records.domain_name => {
    name    = dns_validation_records.resource_record_name
    type    = dns_validation_records.resource_record_type
    records = dns_validation_records.resource_record_value
  }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.records]
  ttl             = 60
  zone_id         = aws_route53_zone.hosted_zone.id
}

resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation_records : record.fqdn]
}

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true
  origin {
    domain_name = "k8s-app-staticap-bbe82d6698-1376719538.us-east-1.elb.amazonaws.com"
    origin_id   = "alb-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  aliases     = [local.website_url]
  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.acm_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}