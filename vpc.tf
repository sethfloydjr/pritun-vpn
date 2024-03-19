#See here for info on this module:  https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
module "VPC_PRITUNL" { #CHANGE THIS
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"  #CHECK ON THIS AT THE LINK ABOVE
  name    = "pritunl" #CHANGE THIS
  cidr    = "100.100.0.0/16"
  #Pay attention to which AZs you are specifying here based on region
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["100.100.1.0/24", "100.100.2.0/24", "100.100.3.0/24"]
  public_subnets  = ["100.100.11.0/24", "100.100.12.0/24", "100.100.13.0/24"]
  #database_subnets    = ["100.100.21.0/24", "100.100.22.0/24", "100.100.23.0/24"]
  #elasticache_subnets = ["100.100.31.0/24", "100.100.32.0/24", "100.100.33.0/24"]
  #redshift_subnets    = ["100.100.41.0/24", "100.100.42.0/24", "100.100.43.0/24"]
  create_database_subnet_group = true
  enable_nat_gateway           = true
  #enable_vpn_gateway = true
  #enable_s3_endpoint       = true
  #enable_dynamodb_endpoint = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_dhcp_options  = true
  tags = {
    Project = "Pritunl"
  }
}
