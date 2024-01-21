resource "aws_vpc" "venu" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "av" {
}
resource "aws_instance" "web" {
   ami = "ami-0d2bc8073c06a612f"
   instance_type = "t2.large"
   vpc_security_group_ids = [aws_security_group..id]
   tags = {
     Name = "HelloWorld"
   }
}