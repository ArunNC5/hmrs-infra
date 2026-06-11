resource "aws_vpc" "hmrs_np_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "hmrs_np_vpc"
  }
}



resource "aws_subnet" "hmrs_np_pub_subnet1a" {
  vpc_id            = aws_vpc.hmrs_np_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "hmrs_np_pub_subnet1a"
  }
}

resource "aws_subnet" "hmrs_np_pub_subnet1b" {
  vpc_id            = aws_vpc.hmrs_np_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "hmrs_np_pub_subnet1b"
  }
}



resource "aws_subnet" "hmrs_np_pvt_subnet1a" {
  vpc_id            = aws_vpc.hmrs_np_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "hmrs_np_pvt_subnet1a"
  }
}

resource "aws_subnet" "hmrs_np_pvt_subnet1b" {
  vpc_id            = aws_vpc.hmrs_np_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "hmrs_np_pvt_subnet1b"
  }
}

resource "aws_internet_gateway" "hmrs_np_igw" {
  vpc_id = aws_vpc.hmrs_np_vpc.id

  tags = {
    Name = "hmrs_np_igw"
  }
}

resource "aws_route_table" "hmrs_np_pub_rt" {
  vpc_id = aws_vpc.hmrs_np_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hmrs_np_igw.id
  }



  tags = {
    Name = "hmrs_np_pub_rt"
  }
}




resource "aws_route_table" "hmrs_np_pvt_rt" {
  vpc_id = aws_vpc.hmrs_np_vpc.id

  route = []



  tags = {
    Name = "hmrs_np_pvt_rt"
  }
}


resource "aws_route_table_association" "hmrs_np_pub_rt_association1a" {
  subnet_id      = aws_subnet.hmrs_np_pub_subnet1a.id
  route_table_id = aws_route_table.hmrs_np_pub_rt.id
}


resource "aws_route_table_association" "hmrs_np_pub_rt_association1b" {
  subnet_id      = aws_subnet.hmrs_np_pub_subnet1b.id
  route_table_id = aws_route_table.hmrs_np_pub_rt.id
}


resource "aws_route_table_association" "hmrs_np_pvt_rt_association1a" {
  subnet_id      = aws_subnet.hmrs_np_pvt_subnet1a.id
  route_table_id = aws_route_table.hmrs_np_pvt_rt.id
}

resource "aws_route_table_association" "hmrs_np_pvt_rt_association1b" {
  subnet_id      = aws_subnet.hmrs_np_pvt_subnet1b.id
  route_table_id = aws_route_table.hmrs_np_pvt_rt.id
}

    