data "aws_caller_identity" "current" {}

 data "aws_ami" "amazon_linux_2" {
   most_recent = true
   owners      = ["amazon"]

   filter {
     name   = "owner-alias"
     values = ["amazon"]
   }


   filter {
     name   = "name"
     values = ["amzn2-ami-hvm*"]
   }
 }

data "terraform_remote_state" "vpc" {
  backend = "s3" 
  config = {
     bucket = "udacity-tf-chandu"
     key    = "terraform/terraform.tfstate"
     region = "us-east-2"
   }


}

