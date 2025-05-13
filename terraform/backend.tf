terraform {
  backend "s3" {
    bucket         = "mohitbucket0079"
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
