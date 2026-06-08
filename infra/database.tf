locals {
  database_server_key = "database_server"
}

#  create  security group
resource "aws_security_group" "database_server_sg" {
  name        = "${local.database_server_key}_sg"
  description = "Allow 22 from any where and 3306 from vpn server"
  vpc_id      = aws_vpc.tunnel_vpc.id

  tags = {
    project_name = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_database_server" {
  security_group_id = aws_security_group.database_server_sg.id
  referenced_security_group_id = aws_security_group.vpn_server_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_3306_ipv4_database_server" {
  security_group_id = aws_security_group.database_server_sg.id
  referenced_security_group_id = aws_security_group.vpn_server_sg.id
  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_ipv4_database_server" {
  security_group_id = aws_security_group.database_server_sg.id
  referenced_security_group_id = aws_security_group.vpn_server_sg.id
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_database_server" {
  security_group_id = aws_security_group.database_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# create ec2 instance
resource "aws_instance" "database_server" {
  ami           = local.ubuntu_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.database_server_keys.key_name
  # change these to private later
  subnet_id     = aws_subnet.private.id
  # associate_public_ip_address = true


  vpc_security_group_ids = [
    aws_security_group.database_server_sg.id
  ]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name         = "${local.database_server_key}"
    project_name = local.project_name
  }

}


