locals {
  vpn_server_key = "vpn-server"
}


#  create  security group

resource "aws_security_group" "vpn_server_sg" {
  name        = "${local.vpn_server_key}_sg"
  description = "Allow ssh (22) from any where"
  vpc_id      = aws_vpc.tunnel_vpc.id

  tags = {
    project_name = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_vpn_server" {
  security_group_id = aws_security_group.vpn_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_1194_ipv4_vpn_server" {
  security_group_id = aws_security_group.vpn_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1194
  to_port           = 1194
  ip_protocol       = "udp"
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_vpn_server" {
  security_group_id = aws_security_group.vpn_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "vpn_server" {
  ami           = local.ubuntu_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.vpn_server_keys.key_name
  subnet_id     = aws_subnet.public.id


  vpc_security_group_ids = [
    aws_security_group.vpn_server_sg.id
  ]

  tags = {
    Name         = "${local.vpn_server_key}"
    project_name = local.project_name
  }

}

resource "aws_eip" "vpn_server_eip" {
  domain = "vpc"
  tags = {
    Name         = "${local.vpn_server_key}-eip"
    project_name = local.project_name
  }
}
resource "aws_eip_association" "vpn_server_eip_association" {
  instance_id   = aws_instance.vpn_server.id
  allocation_id = aws_eip.vpn_server_eip.id
}

