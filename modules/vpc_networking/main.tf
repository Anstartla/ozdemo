data "aws_vpc" "prod_cidr_block" {
  id = var.prod_vpc_id
}
data "aws_vpc" "devOps_cidr_block" {
  id = var.devOps_vpc_id
}
data "aws_internet_gateway" "prod_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.prod_vpc_id]
  }
}

resource "aws_eip" "prod_nat_eip" {
  vpc      = true
  tags = {
      "Name" = "${var.prefix_name}-prod-nat-eip"
    }
}
resource "aws_subnet" "prod_public_subnet" {
  availability_zone         = var.avail_zones[0]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 12)
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-public"
  }
}
resource "aws_subnet" "prod_private_subnet" {
  availability_zone         = var.avail_zones[1]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 13)
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-private"
  }
}
resource "aws_subnet" "prod_private2_subnet" {
  availability_zone         = var.avail_zones[2]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 11)
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-private1"
  }
}

resource "aws_nat_gateway" "prod_nat_gateway" {
    allocation_id = aws_eip.prod_nat_eip.id
    subnet_id = aws_subnet.prod_public_subnet.id
    tags = {
      "Name" = "${var.prefix_name}-prod-nat-gw"
    }
}
resource "aws_subnet" "prod_NLB_public_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 14+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-mdl-NLB-public${count.index}"
  }
}
resource "aws_subnet" "prod_RDS_private_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 17+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-rds-private${count.index}"
  }
}
resource "aws_subnet" "prod_portals_private_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 20+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-portals-private${count.index}"
  }
}
resource "aws_subnet" "prod_kookoo_private_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 23+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-kookoo-private${count.index}"
  }
}
resource "aws_subnet" "prod_portals_ALB_public_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 26+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-portals-ALB-public${count.index}"
  }
}
resource "aws_subnet" "prod_kookoo_ALB_private_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 29+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-kookoo-ALB-private${count.index}"
  }
}
resource "aws_subnet" "prod_mdl_private_subnet" {
  count                     = length(var.avail_zones)
  availability_zone         = var.avail_zones[count.index]
  cidr_block                = cidrsubnet(data.aws_vpc.prod_cidr_block.cidr_block, 8, 32+"${count.index}")
  vpc_id                    = var.prod_vpc_id

  tags = {
    "Name" = "${var.prefix_name}-prod-mdl-private${count.index}"
  }
}

resource "aws_route_table" "prod_public_rtb" {
  vpc_id                    = var.prod_vpc_id
  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id              = data.aws_internet_gateway.prod_igw.internet_gateway_id
  }
  tags = {
    "Name" = "${var.prefix_name}-prod-public-rtb"
  }
}

resource "aws_route_table" "prod_private_rtb" {
  vpc_id                    = var.prod_vpc_id
  route {
    cidr_block              = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.prod_nat_gateway.id
  }
  tags = {
    "Name" = "${var.prefix_name}-prod-private-rtb"
  }
}


resource "aws_route_table_association" "prod_public" {
  subnet_id                 = aws_subnet.prod_public_subnet.id
  route_table_id            = aws_route_table.prod_public_rtb.id
}
resource "aws_route_table_association" "prod_private" {
  subnet_id                 = aws_subnet.prod_private_subnet.id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_private2" {
  subnet_id                 = aws_subnet.prod_private2_subnet.id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_NLB_public" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_NLB_public_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_public_rtb.id
}
resource "aws_route_table_association" "prod_portals_ALB_public" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_portals_ALB_public_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_public_rtb.id
}
resource "aws_route_table_association" "prod_RDS_private" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_RDS_private_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_portals_private" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_portals_private_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_kookoo_private" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_kookoo_private_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_kookoo_ALB_private" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_kookoo_ALB_private_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}
resource "aws_route_table_association" "prod_mdl_private" {
  count                     = length(var.avail_zones)
  subnet_id                 = aws_subnet.prod_mdl_private_subnet[count.index].id 
  route_table_id            = aws_route_table.prod_private_rtb.id
}




resource "aws_security_group" "portals_sg" {
  name                      = "${var.prefix_name}-prod-portals-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.devOps_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 8080
    to_port                 = 8080
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  tags = {
    Name                    = "${var.prefix_name}-prod-portals-sg"
  } 
}

resource "aws_security_group" "mdl_sg" {
  name                      = "${var.prefix_name}-prod-mdl-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
  }
  ingress {
    from_port               = 8080
    to_port                 = 8080
    protocol                = "TCP"
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block, "10.1.2.0/24"]
  }
  ingress {
    from_port               = 9090
    to_port                 = 9090
    protocol                = "TCP"
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
  }
  ingress {
    from_port               = 8081
    to_port                 = 8081
    protocol                = "TCP"
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block, "10.1.2.0/24"]
  } 
  ingress {
    cidr_blocks             = [data.aws_vpc.devOps_cidr_block.cidr_block]
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 9797
    to_port                 = 9797
    protocol                = "TCP"
  }
  tags = {
    Name                    = "${var.prefix_name}-prod-mdl-sg"
  } 
}
resource "aws_security_group" "kookoo_sg" {
  name                      = "${var.prefix_name}-prod-kookoo-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.devOps_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 11300
    to_port                 = 11300
    protocol                = "tcp"
  }
  tags = {
    Name                    = "${var.prefix_name}-prod-kookoo-sg"
  } 
}
resource "aws_security_group" "apiserver_sg" {
  name                      = "${var.prefix_name}-prod-apiserver-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
    description             = "from ozonetel VPN"
  }
  ingress {
    cidr_blocks             = ["115.98.71.77/32"]
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
    description             = "Jagadish Public IP"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 5666
    to_port                 = 5666
    protocol                = "tcp"
    description             = "for monitoring"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.devOps_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "TCP"
  }
  tags = {
    Name                    = "${var.prefix_name}-prod-apiserver-sg"
  } 
}
resource "aws_security_group" "goscripts_sg" {
  name                      = "${var.prefix_name}-prod-goscripts-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 80
    to_port                 = 80
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 9000
    to_port                 = 9000
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 9100
    to_port                 = 9100
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 9001
    to_port                 = 9001
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 9002
    to_port                 = 9002
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    from_port               = 8008
    to_port                 = 8008
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = [data.aws_vpc.devOps_cidr_block.cidr_block]
    from_port               = 22
    to_port                 = 22
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 22
    to_port                 = 22
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 443
    to_port                 = 443
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 80
    to_port                 = 80
    protocol                = "TCP"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 5666
    to_port                 = 5666
    protocol                = "TCP"
  }
  tags = {
    Name                    = "${var.prefix_name}-prod-goscripts-sg"
  } 
}

resource "aws_security_group" "rds_sg" {
  name                      = "${var.prefix_name}-prod-rds-sg"
  vpc_id                    = var.prod_vpc_id
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    cidr_blocks             = [data.aws_vpc.prod_cidr_block.cidr_block]
    description             = "access to ozonetel preprod VPC"
  }
  ingress {
    cidr_blocks             = ["10.234.16.232/32"]
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    description             = "access to ozonetel devOps(bastion)"
  }
  ingress {
    cidr_blocks             = ["10.1.2.0/24"]
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    description             = "access to ozonetel VPN" 
  }  
  tags = {
    Name                    = "${var.prefix_name}-prod-rds-sg"
  } 
}
