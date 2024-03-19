module "pritunl-vpn" {
  source                = "./pritunl-vpn"
  region                = var.region
  access_key            = var.AWS_ACCESS_KEY_ID
  secret_key            = var.AWS_SECRET_ACCESS_KEY
  vpc_id                = module.VPC_PRITUNL.vpc_id
  public_subnets        = module.VPC_PRITUNL.public_subnets
  availability_zones    = module.VPC_PRITUNL.azs
  pritunl_bucket_prefix = "pritunl"
  mongodb_version       = "4.2"
  ACM_CERT              = var.YOUR_ACM_CERT_ARN_GOES_HERE #Or you can import it, pull in through remote state, Or create it in this stack using the ACM.tf file
  HOSTED_ZONE_ID        = var.YOUR_DOMAIN_HOSTED_ZONE_ID
}
