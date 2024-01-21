resource "aws_vpc" "advik-id" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block for the VPC

  tags = {
    Name = "MyVPC"
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
} 

resource "aws_instance" "web1" {
  ami                    = "ami-00ba9d581b8f824f9"
  instance_type          = "t2.large"
  key_name               = "ohio"
  vpc_security_group_ids = [aws_security_group.Jenkins-sgs.id]
  subnet_id = aws_subnet.vair-sub.id
  user_data              = templatefile("./install_jenkins.sh", {})

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

  tags = {
    Name = "Monitoring-via-Grafana"
  }

  root_block_device {
    volume_size = 30
  }
}
