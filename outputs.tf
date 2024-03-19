#################
# VPC
#################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.VPC_PRITUNL.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.VPC_PRITUNL.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.VPC_PRITUNL.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.VPC_PRITUNL.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.VPC_PRITUNL.database_subnets
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.VPC_PRITUNL.elasticache_subnets
}

output "redshift_subnets" {
  description = "List of IDs of redshift subnets"
  value       = module.VPC_PRITUNL.redshift_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.VPC_PRITUNL.nat_public_ips
}

output "availability_zones" {
  description = "List of availability_zones available for the VPC"
  value       = module.VPC_PRITUNL.azs
}


output "pritunl_eip_public_ip" {
  value = module.pritunl-vpn.pritunl_eip_public_ip
}
