output "goscripts_pvt_ip" {
  value = aws_instance.goscripts_instance[*].private_ip
}
output "numbercheck_api_pvt_ip" {
  value = aws_instance.numbercheck_api_instance[*].private_ip
}
