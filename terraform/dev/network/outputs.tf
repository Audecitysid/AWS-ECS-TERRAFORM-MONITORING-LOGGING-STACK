output "vpc" {
  value = module.network.vpc
}

output "subnets_private" {
  value = module.network.subnets_private
}

output "subnets_public" {
  value = module.network.subnets_public
}

output "sg_app" {
  value = module.network.sg_app
}

output "sg_management" {
  value = module.network.sg_management
}

output "sg_es" {
 value = module.network.sg_es
}



output "public_subnet_ids" {
  value = module.network.public_subnet_ids
  
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
  
}
