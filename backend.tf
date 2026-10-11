terraform {
  backend "s3" {
    bucket = "terraform-sk-2026-1"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}
