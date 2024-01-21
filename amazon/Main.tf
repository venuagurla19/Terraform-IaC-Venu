resource "aws_vpc" "venu" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "dj" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080,9000,9100,9090,3000"
  vpc_id      = aws_vpc.venu.id

  ingress = [
    for port in [22, 80, 443, 8080, 9000,9100,9090,3000] : {
    description = "Allow ${port} from VPC"
    from_port   = port
    to_port     = port  # Assuming you want to open ports 22 to 3000, adjust as needed
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =[]
    prefix_list_ids = []
    security_groups = []
    self            = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "dj"
  }
}

resource "aws_instance" "web1" {
   ami                    = "ami-0d2bc8073c06a612f"
   instance_type          = "t2.large"
   key_name               = "ohio"
   vpc_security_group_ids = [aws_security_group.dj.id]
   user_data              = templatefile("./install_jenkins.sh",{})
   
   tags = {
    Name = "amazon clone"
   }
   root_block_device {
    volume_size = 30
   }
}

resource "aws_instance" "web2"  {
   ami           = "ami-0d2bc8073c06a612f"
   instance_type = "t2.medium"
   key_name      = "ohio"
   vpc_security_group_ids = [aws_security_group.dj.id]
   tags = {
     Name = "Monitoring via Grafana"
   }
   root_block_device {
    volume_size = 30
    }
}
