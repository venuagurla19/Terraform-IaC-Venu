resource "aws_instance" "web" {
   ami = "ami-0d2bc8073c06a612f"
   instance_type = "t2.large"
   tags = {
     Name = "HelloWorld"
   }
}