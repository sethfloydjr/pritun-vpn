########################## Authentication variables ###########################
variable "region" {
  default = "us-east-1"
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

#Either hard code this or make this a CI/CD env var in Gitlab
variable "YOUR_DOMAIN_HOSTED_ZONE_ID" {}
