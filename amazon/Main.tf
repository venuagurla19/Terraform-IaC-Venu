resource "aws_s3_bucket" "venu-bucket" {
  bucket = "my-unique-buvket"
  acl = "private"

  versioning {
    enabled = true
  }
  


logging {
  target_bucket = "aws_s3_bucket.bucket"
  target_prefix = "logs/"
  }
}
resource "aws_subnet" "public" {
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.advik-id.id
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "private" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.advik-id.id
  availability_zone = "us-east-2a"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.advik-id.id
}

resource "aws_eip" "public" {
  
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public.id
  subnet_id     = aws_subnet.public.id  
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.advik-id.id
  
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.advik-id.id
  
}

resource "aws_route" "private-internet_out" {
  route_table_id = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
  
}

resource "aws_route" "public-internet_access" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
  
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_vpc" "advik-id" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block for the VPC

  tags = {
    Name = "amazon-vpc"
  }
}

resource "aws_security_group" "Jenkins-sgs" {
  name        = "Jenkins-Security-Grp"
  description = "Open ports 22, 80, 443, 8080, 9000, 9100, 9090, 3000"
  vpc_id      = aws_vpc.advik-id.id

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 9100, 9090, 3000] : {
      description      = "Allow ${port} from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sgs"
  }
}

resource "aws_subnet" "vair-sub" {
  vpc_id            = aws_vpc.advik-id.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  
  tags = {
    Name = "create-subnet-Id"
  }
}

resource "aws_instance" "venu" {
  ami                    = "ami-00ba9d581b8f824f9"
  instance_type          = "t2.micro"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.Jenkins-sgs.id]
  subnet_id = aws_subnet.vair-sub.id
  associate_public_ip_address = true
} 

resource "aws_instance" "web1" {
  ami                    = "ami-00ba9d581b8f824f9"
  instance_type          = "t2.large"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.Jenkins-sgs.id]
  subnet_id = aws_subnet.vair-sub.id
  user_data              = templatefile("./install_jenkins.sh", {})
  associate_public_ip_address = true
  tags = {
    Name = "amazon-clone"
  }

  root_block_device {
    volume_size = 30
  }
}

resource "aws_instance" "web2" {
  ami                    = "ami-00ba9d581b8f824f9"
  instance_type          = "t2.medium"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.Jenkins-sgs.id]
  subnet_id = aws_subnet.vair-sub.id
  associate_public_ip_address = true

  tags = {
    Name = "Monitoring-via-Grafana"
  }

  root_block_device {
    volume_size = 30
  }
}
