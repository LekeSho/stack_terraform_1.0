locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
 }

#CODE FOR APP_SERVER



### Declare Key Pair ##########################
resource "aws_key_pair" "Stack_KP" {
  key_name   = "stackkp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

  
#Creating EFS
#note made changes to line 135 - added unique
  resource "aws_efs_file_system" "efs_mount" {
    creation_token = "unique-efs-stack"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = "true"
    tags = {
    Name = "stack-efs"
    dns_name = "efs.${var.AWS_REGION}.amazonaws.com"
  }
}

output "efs_dns_name" {
value = aws_efs_file_system.efs_mount.tags["dns_name"]
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id   = aws_efs_file_system.efs_mount.id
  subnet_id       =  aws_subnet.Stack-public-subnet-1.id 
  security_groups = [aws_security_group.stack-sg-public.id]
   
}
resource "aws_efs_mount_target" "efs_mount_a" {
  file_system_id   = aws_efs_file_system.efs_mount.id
  subnet_id       =  aws_subnet.Stack-public-subnet-2.id 
  security_groups = [aws_security_group.stack-sg-public.id]
   
}



#Adding Load Balancer
resource "aws_lb" "lb" {
  depends_on = [aws_efs_mount_target.efs_mount]
  name               = "TF-LoadBalancerOne"
  internal           = false
  load_balancer_type = "application"
  subnets           = [aws_subnet.Stack-public-subnet-1.id, aws_subnet.Stack-public-subnet-2.id]
  security_groups = [aws_security_group.stack-sg-public.id]
  tags = {
    Name = "Stack_loadbalancer"
  }
  
}

output "load_balancer_dns" {
  value = aws_lb.lb.dns_name
  description = "DNS name of the load balancer"
}



#Adding Load Balancer Target Group
resource "aws_lb_target_group" "TF_STACKGROUP" {
  name     = "TF-stack-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id     = aws_vpc.Stack-VPC.id
  health_check {
    protocol               = "HTTP"
    port                   = 80
    path                   = "/"
    healthy_threshold      = 3
    unhealthy_threshold    = 2
    timeout                = 5
    interval               = 30
  }
}

#Adding Load Balancer Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_STACKGROUP.arn
  }
}

# Adding Auto Scaling GROUP
resource "aws_launch_configuration" "TF-Stack-Template" {
  name_prefix          = "my-launch-template"
  depends_on    = [aws_efs_mount_target.efs_mount,
    aws_efs_mount_target.efs_mount_a,
    aws_db_instance.CliXX_DB]
  image_id      = local.db_creds.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.Stack_KP.key_name
  user_data = base64encode(data.template_file.bootstrap.rendered)
  security_groups = [aws_security_group.stack-sg-public.id]
  
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdc"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sde"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "TF-ASG" {
  depends_on           = [aws_efs_mount_target.efs_mount]
  name                 = "TF-Stack-ASG"
  launch_configuration = aws_launch_configuration.TF-Stack-Template.id
  min_size             = 2
  max_size             = 3
  desired_capacity     = 3
  vpc_zone_identifier  = [aws_subnet.Stack-public-subnet-1.id, aws_subnet.Stack-public-subnet-2.id]
  target_group_arns    = [aws_lb_target_group.TF_STACKGROUP.arn]
  tag {
    key                 = "Name"
    value               = "app-instance1"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
}

#RESTORING DB SNAPSHOT
resource "aws_db_instance" "CliXX_DB" {
  identifier             = "wordpress"
  instance_class         = "db.t3.micro"
  db_name                = ""
  snapshot_identifier    = data.aws_db_snapshot.DBSNAP.id
  skip_final_snapshot    = true
  #vpc_security_group_ids = ["${aws_security_group.stack-sg.id}"]
  vpc_security_group_ids = ["${aws_security_group.stack-sg-private.id}"]
  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name 

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}


#############Deploying App Server2######################## 

  
#Creating EFS
  resource "aws_efs_file_system" "efs_mount2" {
    creation_token = "efs-stack2"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = "true"
    tags = {
    Name = "stack-efs2"
    dns_name = "efs.${var.AWS_REGION}.amazonaws.com"
  }
}

output "efs_dns_name2" {
value = aws_efs_file_system.efs_mount2.tags["dns_name"]
}

resource "aws_efs_mount_target" "efs_mount2" {
  file_system_id   = aws_efs_file_system.efs_mount2.id
  subnet_id       =  aws_subnet.Stack-public-subnet-1.id
  security_groups = [aws_security_group.stack-sg-public.id]
  
  
}

resource "aws_efs_mount_target" "efs_mount2_a" {
  file_system_id   = aws_efs_file_system.efs_mount2.id
  subnet_id       =  aws_subnet.Stack-public-subnet-2.id
  security_groups = [aws_security_group.stack-sg-public.id]

}


#Adding Load Balancer
resource "aws_lb" "lb2" {
  depends_on = [aws_efs_mount_target.efs_mount2]
  name               = "TF-LoadBalancertwo"
  internal           = false
  load_balancer_type = "application"
  subnets           = [aws_subnet.Stack-public-subnet-1.id, aws_subnet.Stack-public-subnet-2.id]
  security_groups = [aws_security_group.stack-sg-public.id]
  tags = {
    Name = "Stack_loadbalancer2"
  }
  
}

output "load_balancer_dns2" {
  value = aws_lb.lb2.dns_name
  description = "DNS name of the load balancer"
}



#Adding Load Balancer Target Group
resource "aws_lb_target_group" "TF_STACKGROUP2" {
  name     = "TF-stack-target-group2-blog"
  port     = 80
  protocol = "HTTP"
  vpc_id     = aws_vpc.Stack-VPC.id
  health_check {
    protocol               = "HTTP"
    port                   = 80
    path                   = "/"
    healthy_threshold      = 3
    unhealthy_threshold    = 2
    timeout                = 5
    interval               = 30
  }
}

#Adding Load Balancer Listener
resource "aws_lb_listener" "listener2" {
  load_balancer_arn = aws_lb.lb2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_STACKGROUP2.arn
  }
}

# Adding Auto Scaling GROUP
resource "aws_launch_configuration" "TF-Stack-Template2" {
  name_prefix          = "my-launch-template2"
  depends_on    = [
    aws_efs_mount_target.efs_mount2,
    aws_efs_mount_target.efs_mount2_a,
    aws_db_instance.MY_BLOG_DB
  ]
  image_id      = local.db_creds.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.Stack_KP.key_name
  user_data = base64encode(data.template_file.bootstrap2.rendered)
  security_groups = [aws_security_group.stack-sg-public.id]
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdc"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sde"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "TF-ASG2" {
  name                 = "TF-Stack-ASG2"
  launch_configuration = aws_launch_configuration.TF-Stack-Template2.id
  min_size             = 2
  max_size             = 3
  desired_capacity     = 3
  vpc_zone_identifier  = [aws_subnet.Stack-public-subnet-1.id, aws_subnet.Stack-public-subnet-2.id]
  target_group_arns    = [aws_lb_target_group.TF_STACKGROUP2.arn]
  tag {
    key                 = "Name"
    value               = "app-instance2"
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }

}

#RESTORING DB SNAPSHOT
resource "aws_db_instance" "MY_BLOG_DB" {
  identifier             = "wordpress2"
  instance_class         = "db.t3.micro"
  db_name                = ""
  snapshot_identifier    = data.aws_db_snapshot.DBSNAP2.id
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${aws_security_group.stack-sg-private.id}"]
  db_subnet_group_name  = aws_db_subnet_group.db-subnet-group.name 

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}

output "aws_db_instance2" {
  value = aws_db_instance.MY_BLOG_DB
  description = "DNS name of wordpress2"
  sensitive = true
}



