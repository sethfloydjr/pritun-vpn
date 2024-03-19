output "pritunl_alb_dns_name" {
  description                                   = "The DNS record name for ALB"
  value                                         = "${aws_lb.pritunl_alb.dns_name}"
}

output "pritunl_alb_zone_id" {
  description                                   = "The zone_id for the ALB"
  value                                         = "${aws_lb.pritunl_alb.zone_id}"
}

output "pritunl_eip_public_ip" {
  description                                   = "The public IP address of the EIP"
  value                                         = "${aws_eip.pritunl_eip.public_ip}"
}

output "pritunl_instance_sg_id" {
  description                                   = "The ID of the instance security group"
  value                                         = "${aws_security_group.pritunl_sg.id}"
}
