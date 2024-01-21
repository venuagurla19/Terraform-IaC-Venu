resource "aws_instance" "web" {
   ami = "ami-0d2bc8073c06a612f"
   instance_type = "t2.large"
   vpc_security_group_ids = [aws_security_group.dj.id]
   tags = {
     Name = "HelloWorld"
   }
}