resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/18"
    
  
}
resource "aws_subnet" "name" {
    cidr_block = "10.0.0.0/24"
    vpc_id = aws_vpc.name.id
    availability_zone = "us-east-1a"
    tags = {
      name = "pubsub1"
    }
  
}
resource "aws_subnet" "cust" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.name.id
  availability_zone = "us-east-1b"
  tags = {
    name ="pubsu2"
  }
}

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.name.id
    tags = {
      name ="internetgateway"
    }
  
}

resource "aws_route_table" "name" {
    tags = {
      name ="route1"
    }
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }
}

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.cust.id
    route_table_id = aws_route_table.name.id
  
}

resource "aws_route_table_association" "nam" {
    subnet_id = aws_subnet.name.id
    route_table_id = aws_route_table.name.id
  
}
  


resource "aws_security_group" "name" {
    description = "allow ssh traffic"
    name = "secugrp"
    vpc_id = aws_vpc.name.id

    ingress {
        protocol="tcp"
        from_port=22
        to_port=22
       cidr_blocks = [ "0.0.0.0/0" ]
        
        }
      
}

resource "aws_instance" "name" {
    instance_type = "t2.micro"
    key_name = "akhil"
  ami ="ami-066784287e358dad1"   
  security_groups = [aws_security_group.name.id]
  subnet_id = aws_subnet.cust.id
  tags = {
    name ="public"
  }
  
}

resource "aws_lb_target_group" "name" {
    target_type = "instance"
    name = "target"
    protocol = "HTTP"
    port = 80
    vpc_id = aws_vpc.name.id
  
}

resource "aws_lb" "name" {
    load_balancer_type = "application"
    name = "alb"
    internal = "false"
    security_groups = [aws_security_group.name.id]
    subnets = [aws_subnet.cust.id,aws_subnet.name.id]
  
}