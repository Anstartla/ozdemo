resource "aws_instance" "goscripts_instance" {
  count                          = var.goscripts_instances
  ami                            = var.ami_id
  instance_type                  = var.instance_type
  vpc_security_group_ids         = [var.security_group_id_goscripts_sg]
  subnet_id                      = var.subnets[count.index]
  availability_zone              = var.avail_zones[count.index + 1]
  key_name                       = var.key_pair_name
  disable_api_termination        = true

  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  associate_public_ip_address    = false
  # root_block_device {
  #     volume_size             = var.disk_size
  # }
  lifecycle {
    create_before_destroy     = true
  }

  tags = {
    Name                         = "${var.name_prefix}-prod-goscripts${count.index}"
  }
}
resource "aws_instance" "numbercheck_api_instance" {
  count                          = var.numbercheck_api_instances
  ami                            = var.ami_id
  instance_type                  = var.instance_type
  vpc_security_group_ids         = [var.security_group_id_goscripts_sg]
  subnet_id                      = var.subnets[count.index]
  availability_zone              = var.avail_zones[count.index + 1]
  key_name                       = var.key_pair_name
  disable_api_termination        = true
  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  associate_public_ip_address    = false
  # root_block_device {
  #     volume_size             = var.disk_size
  # }
  lifecycle {
    create_before_destroy     = true
  }

  tags = {
    Name                         = "${var.name_prefix}-prod-numbercheck-api${count.index}"
  }
}
resource "aws_instance" "quartz_api_instance" {
  count                          = var.quartz_instances
  ami                            = var.ami_id_quartzapi
  instance_type                  = var.instance_type
  vpc_security_group_ids         = [var.security_group_id_goscripts_sg]
  subnet_id                      = var.subnets[count.index]
  availability_zone              = var.avail_zones[count.index + 1]
  key_name                       = var.key_pair_name
  disable_api_termination        = true
  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  associate_public_ip_address    = false
  # root_block_device {
  #     volume_size             = var.disk_size
  # }
  lifecycle {
    create_before_destroy     = true
  }

  tags = {
    Name                         = "${var.name_prefix}-prod-quartz${count.index}"
  }
}
