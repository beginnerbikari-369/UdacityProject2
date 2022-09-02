terraform {
   backend "s3" {
     bucket = "udacity-tf-chandu-west1"
     key    = "terraform/terraform.tfstate"
     region = "us-east-2"
   }
 }

 provider "aws" {
   region = "us-west-1"
   #profile = "default"
   
   default_tags {
     tags = local.tags
   }
 }