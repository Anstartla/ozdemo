variable "prefix_name" {
  description = "name for the resources to be created"
}
variable "prod_vpc_id" {
}
variable "devOps_vpc_id" {
}
variable "tgw_id" {
}
variable "avail_zones" {
  description = "Availability Zones Used"
  type = list
}
variable "bastion_sg_id"{}

