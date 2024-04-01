provider "aws" {
  region = "us-east-1"


  assume_role {
    role_arn    = "arn:aws:iam::767398089220:role/Engineer"
  }
}
