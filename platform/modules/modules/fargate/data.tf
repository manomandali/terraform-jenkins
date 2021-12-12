data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = "bizwithai-admin-terraform"
    key                  = var.network_remote_state_key
    workspace_key_prefix = "platform-roots"
    region               = "ap-south-1"
    profile              = "bizwithai-admin"
  }
}