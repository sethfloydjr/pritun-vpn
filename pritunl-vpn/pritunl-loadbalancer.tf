resource "aws_lb" "pritunl_alb" {
  name                          = "pritunl-alb"
  internal                      = false
  load_balancer_type            = "application"
  subnets                       = [var.public_subnets[0], var.public_subnets[1], var.public_subnets[2]]
  enable_deletion_protection    = false #If you set to true you will have to maually turn off the delete protection
  security_groups               = [aws_security_group.pritunl_alb_sg.id]

  tags = {
    Name                        = "pritunl_alb"
  }
}

resource "aws_lb_listener" "Pritunl_ALB_Forward_443" {
  load_balancer_arn             = aws_lb.pritunl_alb.arn
  port                          = "443"
  protocol                      = "HTTPS"
  ssl_policy                    = "ELBSecurityPolicy-2015-05"
  certificate_arn               = var.ACM_CERT

  default_action {
    type                        = "forward"
    target_group_arn            = aws_lb_target_group.Pritunl_ALB_Forward_TG_443.arn
  }
}


resource "aws_lb_listener" "Pritunl_ALB_REDIRECT_80" {
  load_balancer_arn             = aws_lb.pritunl_alb.arn
  port                          = "80"
  protocol                      = "HTTP"
  default_action {
    type                        = "redirect"
    redirect {
      port                      = "443"
      protocol                  = "HTTPS"
      status_code               = "HTTP_302"
    }
  }
}

resource "aws_lb_target_group" "Pritunl_ALB_Forward_TG_443" {
  name                          = "Pritunl-ALB-Forward-TG-443"
  port                          = 443
  protocol                      = "HTTPS"
  vpc_id                        = var.vpc_id
  health_check {
    protocol                    = "HTTPS"
    path                        = "/"
    matcher                     = "302"
  }
}

resource "aws_eip" "pritunl_eip" {
  vpc                           = true
  tags = {
    Name                        = "pritunl_eip"
  }
}
