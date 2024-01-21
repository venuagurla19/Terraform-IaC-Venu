resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "Jenkins-sg" {
  name        = "allow_tls"
  description = "Open 22,443,80,8080,9000,9100,9090,3000"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 3000  # Assuming you want to open ports 22 to 3000, adjust as needed
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "web" {
   ami             = "ami-0d2bc8073c06a612f"
   instance_type   = "t2.large"
   key_name        = "ohio"
   vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
   user_data              = templatefile("./install_jenkins.sh",{})
   
   tags = {
    Name = "amazon clone"
   }
   root_block-device {
    volume_size = 30
   }
}

resource "aws_instance" "web2"  {
   ami = "ami-0d2bc8073c06a612f"
   instance_type = "t2.medium"
   key_name      = "ohio"
    vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
   tags {
     Name = "monitoring via Grafana"
   }
   root_block-device {
    volume_size = 30
    }
}
