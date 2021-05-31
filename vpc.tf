resource "aws_vpc" "mediawiki-vpc" {

  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "mediawiki-vpc"
  }
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
}

resource "aws_subnet" "mediawiki-public" {
  vpc_id                  = "${aws_vpc.mediawiki-vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mediawiki-public-subnet"
  }
}

resource "aws_internet_gateway" "mediawiki-igw" {

  vpc_id = "${aws_vpc.mediawiki-vpc.id}"
  tags = {
    Name = "mediawiki-igw"
  }
}

resource "aws_route_table" "mediawiki-public-crt" {
  vpc_id = "${aws_vpc.mediawiki-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mediawiki-igw.id
  }
  # gateway_id = "${aws_internet_gateway.mediawiki-igw.id}"
  tags = {
    Name = "mediawiki-public-crt"
  }
}

resource "aws_route_table_association" "mediawiki-public-crta-subnet-1" {
  subnet_id      = "${aws_subnet.mediawiki-public.id}"
  route_table_id = "${aws_route_table.mediawiki-public-crt.id}"
}

resource "aws_security_group" "mediawiki-sg" {
  name = "mediawiki-sg"
  vpc_id = "${aws_vpc.mediawiki-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "mediawiki_sg_id" {
  value = aws_security_group.mediawiki-sg.id
}

















