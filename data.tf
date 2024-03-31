data "aws_ami" "stack_ami" {
  owners     = ["self"]
  name_regex = "^ami-stack-.*"
  most_recent = true
  filter {
    name   = "name"
    values = ["ami-stack-*"]
  }
}


# data "aws_subnets" "stack_sub" {
#   filter {
#     name   = "vpc-id"
#     values = [var.default_vpc_id]
#   }
# }

# data "aws_subnet" "stack_sub" {
#   for_each = toset(data.aws_subnets.stack_sub.ids)
#   id       = each.value
# }

data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
    secret_id = "db-creds"
     }


locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
 }
   