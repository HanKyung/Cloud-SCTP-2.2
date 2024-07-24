
######################################
# 2407024 assignment
######################################

# create new VPC
resource "aws_vpc" "stphn-vpc-24072024" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "stphn-vpc-24072024"
  }
  
}

# create new subnets
resource "aws_subnet" "stphn24072024-tf-public-subnet-us-east-1a" {
  vpc_id     = aws_vpc.stphn-vpc-24072024.id
  cidr_block = var.public_subnet_cidrs[0]

  tags = {
    Name = "stphn24072024-tf-public-subnet-us-east-1a"
  }
}

resource "aws_subnet" "stphn24072024-tf-public-subnet-us-east-1b" {
  vpc_id     = aws_vpc.stphn-vpc-24072024.id
  cidr_block = var.public_subnet_cidrs[1]

  tags = {
    Name = "stphn24072024-tf-public-subnet-us-east-1b"
  }
}

# private subnet1
resource "aws_subnet" "stphn24072024-tf-private-subnet-us-east-1a" {
  vpc_id     = aws_vpc.stphn-vpc-24072024.id
  cidr_block = var.private_subnet_cidrs[0]

  tags = {
    Name = "stphn24072024-tf-private-subnet-us-east-1a"
  }
}

#private subnet2

resource "aws_subnet" "stphn24072024-tf-private-subnet-us-east-1b" {
  vpc_id     = aws_vpc.stphn-vpc-24072024.id
  cidr_block = var.private_subnet_cidrs[1]

  tags = {
    Name = "stphn24072024-tf-private-subnet-us-east-1b"
  }
}

#igw
resource "aws_internet_gateway" "stphn-gw" {
  vpc_id = aws_vpc.stphn-vpc-24072024.id

  tags = {
    Name = "stphn24072024-tf-igw"
  }
}

# S3 bucket
resource "aws_s3_bucket" "stphn-tf-24072024-S3" {
  bucket = "stphn-tf-24072024"

  tags = {
    Name        = "stphn-tf-24072024"
    Environment = "Dev"
  }
}

# routing tables
resource "aws_route_table" "stphn-tf-public-rtb" {
  vpc_id = aws_vpc.stphn-vpc-24072024.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stphn-gw.id
  }

  route {
    cidr_block = aws_vpc.stphn-vpc-24072024.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "stphn-tf-public"
  }
}

resource "aws_route_table" "stphn-tf-private-rtb-az1" {
  vpc_id = aws_vpc.stphn-vpc-24072024.id


  route {
    cidr_block = aws_vpc.stphn-vpc-24072024.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "stphn-tf-private-1"
  }
}

resource "aws_route_table" "stphn-tf-private-rtb-az2" {
  vpc_id = aws_vpc.stphn-vpc-24072024.id

  
  route {
    cidr_block = aws_vpc.stphn-vpc-24072024.cidr_block
    gateway_id = "local"
  }

 

  tags = {
    Name = "stphn-tf-private-2"
  }

}

#association routing table

resource "aws_route_table_association" "private-1-route" {
  subnet_id      = aws_subnet.stphn24072024-tf-private-subnet-us-east-1a.id
  route_table_id = aws_route_table.stphn-tf-private-rtb-az1.id
}

resource "aws_route_table_association" "private-2-route" {
  subnet_id      = aws_subnet.stphn24072024-tf-private-subnet-us-east-1b.id
  route_table_id = aws_route_table.stphn-tf-private-rtb-az2.id
}

resource "aws_route_table_association" "public-igw" {
  gateway_id     = aws_internet_gateway.stphn-gw.id
  route_table_id = aws_route_table.stphn-tf-public-rtb.id
}

resource "aws_route_table_association" "public-rtb-1" {
  subnet_id      = aws_subnet.stphn24072024-tf-public-subnet-us-east-1a.id
  route_table_id = aws_route_table.stphn-tf-public-rtb.id
}

# configure sg
resource "aws_security_group" "stphn-sg" {
  name   = "stphn-tf-allow-ssh-http-https"
  vpc_id = aws_vpc.stphn-vpc-24072024.id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_vpc_endpoint" "stphn-tf-s3" {
  vpc_id       = aws_vpc.stphn-vpc-24072024.id
  service_name = "com.amazonaws.us-east-1.s3"
}



data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


resource "aws_instance" "stphn-tf-ec2" {
  ami = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.stphn24072024-tf-public-subnet-us-east-1a.id
  associate_public_ip_address = true
  key_name = "stphn-ec2-20072024"
  vpc_security_group_ids = [aws_security_group.stphn-sg.id]
  availability_zone = "us-east-1a"

  tags = {
    Name = "stphn-tf-ec2"
  }
}

# resource "aws_instance" "sample_ec2_variables" {
#   ami           = data.aws_ami.sample_ec2_variables
#   instance_type = "t2.micro"
#   subnet_id = aws_vpc.stphn-vpc-24072024.selected_subnet.id
#   associate_public_ip_address = true
#   key_name = "stphn-ec2-20072024"
#   vpc_security_group_ids = aws_security_group.stphn-sg.id
  

#   tags = {
#     Name = "stphn-tf-ec2"
#   }
# }
