resource "aws_lb_target_group" "name" {
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
    subnets = [aws_subnet.public.id,aws_subnet_private.id]
    depends_on = [ aws_lb_target_group.name ]
    tags = {
      name ="myalb"
    }
}