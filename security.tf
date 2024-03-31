 #### SECURITY GROUP####

resource "aws_security_group" "stack-sg-public" {
  vpc_id =  aws_vpc.Stack-VPC.id
  name        = "Stack-Public-WebDMZ"
  description = "Stack IT Security Group For CliXX System"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks      = ["0.0.0.0/0"]
  
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
 
} 
resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks      = ["0.0.0.0/0"]
  
} 

resource "aws_security_group_rule" "nfs" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks      = ["0.0.0.0/0"]
 
}

resource "aws_security_group_rule" "mysql" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["0.0.0.0/0"]
  
}

resource "aws_security_group_rule" "Oracle-RDS" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1521
  to_port           = 1521
  cidr_blocks       = ["0.0.0.0/0"]
  
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.stack-sg-public.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
 
}


#### Private Security Group ######
resource "aws_security_group" "stack-sg-private" { 
  vpc_id = aws_vpc.Stack-VPC.id
  name  = "db-sg"

  ingress {
    from_port  = 1521
    to_port  = 1521
    protocol = "tcp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"] 
    security_groups = [aws_security_group.stack-sg-public.id]
    # Allow traffic from private subnets
  }

ingress {
    from_port = 3306
    to_port  = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"]
    # Allow traffic from private subnets
    security_groups = [aws_security_group.stack-sg-public.id]

}
  ingress {
    from_port   = 80
    to_port     = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"] 
    # Allow traffic from private subnets
   security_groups = [aws_security_group.stack-sg-public.id]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"]
    security_groups = [aws_security_group.stack-sg-public.id]

}

ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"]
    security_groups = [aws_security_group.stack-sg-public.id] 


  }

ingress {
    from_port = -1 # ICMP type (any)
    to_port = -1 # ICMP code (any)
    protocol = "icmp"
    cidr_blocks = ["10.0.3.0/24","10.0.5.0/24"]
    security_groups = [aws_security_group.stack-sg-public.id]
# Allow traffic from private subnets 
 }

 egress {
    from_port = 0
    to_port  = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

 }

tags = {
 Name  = "rds-sg"
  }
}




