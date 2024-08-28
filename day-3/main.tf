resource "aws_vpc" "cust" {
  cidr_block = "10.0.0.0/18"
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.cust.id
    availability_zone = "ap-south-1a"
    cidr_block = "10.0.0.0/24"
    tags = {
      name = "pubsub"
    }
  
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.cust.id
    availability_zone = "ap-south-1b"
    cidr_block = "10.0.1.0/24"
    tags = {
      name = "pvtsub"
    }
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.cust.id
    tags = {
      name ="cust_ig"
    }
  
}
  
resource "aws_route_table" "cust" {
    vpc_id = aws_vpc.cust.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
  
}

resource "aws_route_table_association" "ras" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.cust.id
  
}

resource "aws_security_group" "sg" {
  description = "allow ssh traffic"
  vpc_id = aws_vpc.cust.id
tags = {
  name = "cust_sg"
}
  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}


resource "aws_instance" "dev" {
    ami = "ami-02b49a24cfb95941c"
    instance_type = "t2.micro"
    key_name = "zxcvbnm"
    subnet_id = aws_subnet.public.id
    security_groups = [aws_security_group.sg.id]
  
}

resource "aws_eip" "elp" {
  network_border_group = "ap-south-1"
  instance = aws_instance.dev.id
  domain = "vpc"
}

resource "aws_nat_gateway" "ng" {
  connectivity_type = "public"
  subnet_id = aws_subnet.public.id
  allocation_id = aws_eip.elp.id
}





resource "aws_lb_target_group" "tg" {
    name = "targetgroup"
    protocol = "HTTP"
  port = 80
  target_type = "instance"
  vpc_id = "aws_vpc"
  tags = {
    name ="mytg"
  }
  
  
}

resource "aws_lb" "name" {
    name = "loadbalancer"
    internal = "false"
    load_balancer_type = "application"
    
    security_groups = [aws_security_group.sg.id]
    subnets = [aws_subnet.public.id, aws_subnet.private.id]
    depends_on = [aws_lb_target_group.tg]
    tags = {
      name ="myalb"
    }
}