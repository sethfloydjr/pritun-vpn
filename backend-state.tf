/*
terraform {
  backend "s3" {
    bucket = "YOUR_BUCKET"
    key    = "pritunl.tfstate"
    region = "us-east-1"
  }
}
*/

terraform {
  backend "local" {
    path = "/Users/seth/pritunl-test.tfstate"
  }
}
