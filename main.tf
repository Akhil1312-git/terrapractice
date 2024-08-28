resource "aws_instance" "dev" {
    ami = var.ami
    key_name = var.key_name
  
}