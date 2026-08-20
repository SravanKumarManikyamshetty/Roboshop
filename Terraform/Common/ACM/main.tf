
resource "aws_acm_certificate" "roboshop" {
  domain_name       = "*.sravan.click"
  validation_method = "DNS"
  tags = {
    Name = "${var.project}-${var.environment}-certificate"
  }
}
data "aws_route53_zone" "roboshop" {
  name         = "sravan.click"
  private_zone = false
}

resource "aws_route53_record" "roboshop" {
  for_each = {
    for dvo in aws_acm_certificate.roboshop.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.roboshop.zone_id
}

resource "aws_acm_certificate_validation" "roboshop" {
  certificate_arn         = aws_acm_certificate.roboshop.arn
  validation_record_fqdns = [for record in aws_route53_record.roboshop : record.fqdn]
}
