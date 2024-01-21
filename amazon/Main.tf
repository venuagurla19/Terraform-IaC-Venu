resource = resource "aws_vpc" "my_vpc" {
cidr_block = "CIDR Block"
}
resource "resource "aws_security_group" "allow_tls" {
name        = "allow_tls"
description = "Open 22,443,80,8080,9000,9100,9090,3000"
vpc_id      = aws_vpc.my_vpc.id

ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 3000
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
    Name = "allow_tls"
}
}" "name" {

}