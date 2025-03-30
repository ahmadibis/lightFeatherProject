terraform {
  backend "s3" {
    bucket            = "lightfeather-terraform-state-1"
    key               = "terraform/state"
    region            = "us-east-1"
    profile           = "lightfeather-challenge"
    encrypt           = true
    dynamodb_endpoint = "lightfeather-terraform-state-lock"
  }
}