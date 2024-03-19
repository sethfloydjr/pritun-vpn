data "aws_ami" "pritunl" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = [137112412989] # Amazon AMI owner
}


data "template_file" "scripts" {
  template = "${file("pritunl-vpn/pritunl-instance.tpl")}"
  vars = {
    pritunlbucket       = aws_s3_bucket.pritunl_bucket.id
    access_key          = var.access_key
    secret_key          = var.secret_key
    region              = var.region
    eip_id              = aws_eip.pritunl_eip.id
    mongodb_version     = var.mongodb_version
  }
}


resource "aws_launch_configuration" "pritunl_launch_config" {
  name_prefix                 = "pritunl-lc-"
  image_id                    = data.aws_ami.pritunl.id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.pritunl_key.key_name
  security_groups             = [aws_security_group.pritunl_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.pritunl_instance_profile.id
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type = "standard"
    volume_size = 20
  }
  user_data = data.template_file.scripts.rendered
}


resource "aws_autoscaling_group" "pritunl_main_asg" {
  # We want this to explicitly depend on the launch config above
  depends_on = [aws_launch_configuration.pritunl_launch_config, var.vpc_id]
  name       = "pritunl-asg"
  # The chosen availability zones *must* match the AZs the VPC subnets are tied to.
  # availability_zones  = [var.availability_zones[0], var.availability_zones[1], var.availability_zones[2]]
  vpc_zone_identifier = [var.public_subnets[0]]
  target_group_arns   = [aws_lb_target_group.Pritunl_ALB_Forward_TG_443.arn]
  # Uses the ID from the launch config created above
  launch_configuration = aws_launch_configuration.pritunl_launch_config.name
  max_size             = "1"
  min_size             = "1"
  desired_capacity     = "1"
  health_check_type    = "EC2"
  tag {
    key                 = "Name"
    value               = "pritunl"
    propagate_at_launch = true
  }
}


resource "aws_key_pair" "pritunl_key" {
  key_name   = "pritunl_key"
  public_key = "The contenst of your public key goes here."
}
