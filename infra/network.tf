resource "aws_vpc" "tunnel_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name         = "tunnel_vpc"
    project_name = local.project_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tunnel_vpc.id

  tags = {
    project_name = local.project_name
    Name         = "tunnel-igw"
  }
}

# vpn server/nat gateway subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.tunnel_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az

  tags = {
    Name         = "public_subnet"
    project_name = local.project_name
  }
}

# database server subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.tunnel_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az

  tags = {
    Name         = "private_subnet"
    project_name = local.project_name
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tunnel_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name         = "public-route-table"
    project_name = local.project_name
  }
}

resource "aws_route_table_association" "public_assoc" {
 
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tunnel_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name         = "private-route-table"
    project_name = local.project_name
  }
}

resource "aws_route_table_association" "private_assoc" {
  
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}




resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name         = "nat-eip"
    project_name = local.project_name
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
}
