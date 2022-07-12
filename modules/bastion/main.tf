data "aws_vpc" "vpc_cidr_block" {
    id = var.prod_vpc_id 
}
resource "aws_security_group" "bastion_sg" {
  name                      = "${var.name_prefix}-prod-bastion-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.vpc_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    description             = "SSH for prod instances"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    description             = "SSH for ozonetel vpn"
  }
  ingress {
    cidr_blocks             = ["10.234.16.232/32"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    description             = "SSH for devOps bastion"
  }
  tags = {
    Name                    = "${var.name_prefix}-prod-bastion-sg"
  }
}


resource "aws_instance" "bastion_instance" {
  ami                            = var.ami_id
  instance_type                  = var.instance_type_4_16
  vpc_security_group_ids         = [aws_security_group.bastion_sg.id]
  key_name                       = var.key_pair_name_bastion
  subnet_id                      = var.subnets
  disable_api_termination        = true
  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  associate_public_ip_address    = true
  root_block_device {
    volume_size             = 60 
  }
  ebs_block_device {
    volume_size             = var.disk_size
    device_name             = "/dev/sdb"
    encrypted               = true 
    volume_type             = "gp3"
    delete_on_termination   = false
  }
  lifecycle {
    create_before_destroy     = true
  }
  tags = {
    Name                         = "${var.name_prefix}-prod-bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  instance                       = aws_instance.bastion_instance.id
  vpc                            = true
  tags = {
      "Name" = "${var.name_prefix}-prod-bastion-eip"
    }
}
