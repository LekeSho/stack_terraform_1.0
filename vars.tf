variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}


variable "environment" {
  default = "dev"
}

variable "system" {
  default = "Retail Reporting"
}

variable "subsystem" {
  default = "CliXX"
}

variable "availability_zone" {
  default = "us-east-1c"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_key.pub"
}

variable "OwnerEmail" {
  default = "adeshodeinde@gmail.com"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-stack-1.0"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}


variable "stack_controls" {
  type = map(string)
  default = {
    ec2_create = "Y"
    rds_create = "Y"
  }
}

variable "EC2_Components" {
  type = map(string)
  default = {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "true"
    instance_type         = "t2.micro"
  }
}

variable "backup" {
  default = "yes"
}



variable "ami" {}

variable  "CliXX_Repo" {}

variable "CliXX_MOUNT_POINT" {}

variable "CliXX_WP_CONFIG" {}


variable "MY_BLOG_Repo" {}

variable "MY_BLOG_MOUNT_POINT" {}

 variable "MY_BLOG_WP_CONFIG" {}
   

 
 variable  "BLOG_DB_NAME" {}
 variable "BLOG_DB_USER" {}
 variable "BLOG_DB_PASSWORD" {}
 variable "BLOG_DB_EMAIL" {}

 variable "DB_NAME" {}
 variable "DB_USER" {}
 variable "PASSWORD"{}


 
 


############################################VPC################################################
















