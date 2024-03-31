
terraform{
         backend "s3"{
                bucket = "stackekesbucket1"
                key = "terraform.tfstate"
                region="us-east-1"
                dynamodb_table="statelock-tf"
                }
}