variable "access_key" {}
variable "secret_key" {}
variable "region" {}

variable "vpc_id" {}
variable "public_subnets" {
    type = list
}
variable "availability_zones" {
    type = list
}

variable "pritunl_bucket_prefix" {}

variable "mongodb_version" {}

variable "ACM_CERT" {}

variable "HOSTED_ZONE_ID" {}
