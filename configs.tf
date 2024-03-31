#data "template_file" "bootstrap" {
#  template = file(format("%s/scripts/bootstrap.tpl", path.module))
#  vars={
#    GIT_REPO="https://github.com/stackitgit/CliXX_Retail_Repository.git"
#  }
#}

#Added below:
#App Server

data "template_file" "bootstrap" {
  template = file(format("%s/scripts/CLiXX_EFS_Bootsrap.tpl", path.module))
  vars={
    GIT_REPO=var.CliXX_Repo
    MOUNT_POINT = var.CliXX_MOUNT_POINT
    EFS = aws_efs_file_system.efs_mount.id
    EFS_DNS_NAME = aws_efs_file_system.efs_mount.dns_name   
    WP_CONFIG = var.CliXX_WP_CONFIG
    DB_NAME = var.DB_NAME
    DB_USER=var.DB_USER
    DB_PASSWORD=var.PASSWORD
    load_balancer_dns = aws_lb.lb.dns_name
    DB_HOST = aws_db_instance.CliXX_DB.endpoint
      
}

}

data "aws_db_snapshot" "DBSNAP" {
  db_snapshot_identifier = "arn:aws:rds:us-east-1:767398089220:snapshot:wordpressdbclixx"
  most_recent            = true
}

# For APP Server 2

data "template_file" "bootstrap2" {
  template = file(format("%s/scripts/BLOG_EFS_Bootsrap.tpl", path.module))
  vars={
    GIT_REPO=var.MY_BLOG_Repo
    MOUNT_POINT = var.MY_BLOG_MOUNT_POINT
    EFS = aws_efs_file_system.efs_mount2.id
    EFS_DNS_NAME2 = aws_efs_file_system.efs_mount2.dns_name
    WP_CONFIG = var.MY_BLOG_WP_CONFIG
    DB_NAME = var.BLOG_DB_NAME
    DB_USER = var.BLOG_DB_USER
    DB_PASSWORD = var.BLOG_DB_PASSWORD
    DB_EMAIL=var.BLOG_DB_EMAIL
    load_balancer_dns2 = aws_lb.lb2.dns_name 
    RDS_INSTANCE = aws_db_instance.MY_BLOG_DB.endpoint
     
    
  }
}

data "aws_db_snapshot" "DBSNAP2" {
  db_snapshot_identifier = "arn:aws:rds:us-east-1:767398089220:snapshot:wordpress2-snapshot"
  most_recent            = true
}


