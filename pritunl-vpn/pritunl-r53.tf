resource "aws_route53_record" "pritunl_www" {
  zone_id                       = var.HOSTED_ZONE_ID
  name                          = "pritunl.setheryops.com"
  type                          = "CNAME"
  ttl                           = "300"
  records                       = [aws_lb.pritunl_alb.dns_name]
}

#Interesting note here: This is specifically NOT set as an alias because when Route 53 receives a DNS query for an alias record, Route 53 responds with the applicable value for that resource. Route 53 responds with one or more IP addresses for the load balancer when the alias specifies an ELB or ALB
