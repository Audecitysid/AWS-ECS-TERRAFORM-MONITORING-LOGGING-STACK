output "vpc" {
  value = aws_vpc.main
}

output "subnets_private" {
  value = aws_subnet.private
}

output "subnets_public" {
  value = aws_subnet.public
}

output "sg_app" {
  value = aws_security_group.app
}

output "sg_management" {
  value = aws_security_group.management
}

output "sg_es" {
  value = aws_security_group.es
}



output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "List of IDs for public subnets"
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  description = "List of IDs for private subnets"
}
