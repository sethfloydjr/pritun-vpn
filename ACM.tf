/*
resource "aws_acm_certificate" "YOUR_DOMAIN_cert" {
  domain_name                   = "*.YOUR_DOMAIN.com"
  validation_method             = "DNS"
}

resource "aws_acm_certificate_validation" "YOUR_DOMAIN_cert" {
  certificate_arn               = aws_acm_certificate.YOUR_DOMAIN_cert.arn
  validation_record_fqdns       = ["${aws_route53_record.YOUR_DOMAIN_cert_validation.fqdn}"]
}

resource "aws_route53_record" "YOUR_DOMAIN_cert_validation" {
  name                  = aws_acm_certificate.YOUR_DOMAIN_cert.domain_validation_options.0.resource_record_name
  type                  = aws_acm_certificate.YOUR_DOMAIN_cert.domain_validation_options.0.resource_record_type
  zone_id               = var.YOUR_DOMAIN_HOSTED_ZONE_ID
  records               = ["${aws_acm_certificate.YOUR_DOMAIN_cert.domain_validation_options.0.resource_record_value}"]
  ttl                   = 60
}
*/
