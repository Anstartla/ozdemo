
output "mdl_sg_id" {
  value = aws_security_group.mdl_sg.id
}
output "portals_sg_id" {
  value = aws_security_group.portals_sg.id 
}
output "kookoo_sg_id" {
  value = aws_security_group.kookoo_sg.id 
}
output "rds_sg_id" {
  value = aws_security_group.rds_sg.id 
}
output "apiserver_sg_id" {
  value = aws_security_group.apiserver_sg.id
}
output "goscripts_sg_id" {
  value = aws_security_group.goscripts_sg.id 
}
output "public_subnet_id" {
  value = aws_subnet.prod_public_subnet.id
}
output "private_subnet_id" {
  value = aws_subnet.prod_private_subnet.id
}
output "private2_subnet_id" {
  value = aws_subnet.prod_private2_subnet.id
}
output "prod_RDS_private_subnet_ids" {
  value = aws_subnet.prod_RDS_private_subnet.*.id 
}
output "prod_portals_private_subnet_ids" {
  value = aws_subnet.prod_portals_private_subnet.*.id
}
output "prod_mdl_private_subnet_ids" {
  value = aws_subnet.prod_mdl_private_subnet.*.id
}
output "prod_kookoo_private_subnet_ids" {
  value = aws_subnet.prod_kookoo_private_subnet.*.id
}
output "prod_kookoo_ALB_private_subnet_ids" {
  value = aws_subnet.prod_kookoo_ALB_private_subnet.*.id
}
output "prod_portals_ALB_public_subnet_ids" {
  value = aws_subnet.prod_portals_ALB_public_subnet.*.id
}
