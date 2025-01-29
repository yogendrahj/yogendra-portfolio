terraform {
  backend "s3" {
    bucket         = "yogendra-portfolio-tf-state-backend"
    key            = "terraform/tfstate"
    region         = "eu-west-2"
    dynamodb_table = "tf-state-lock"
  }
}
