terraform {
  backend "s3" {
    bucket  = "utb-ouchi-server-tfstate-279586433649"
    key     = "envs/pve/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "utb-aws-main"
  }
}
