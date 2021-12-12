module "tagging_module" {
  source           = "../tagging"
  name             = "internal-dns-${var.name}"
  application-name = var.application-name
  product          = var.product
  contact          = var.contact
  tf-state-bucket  = var.tf-state-bucket
  offhours         = "off"
  ci-owner         = "raja"
  business-unit    = "NubesOpus"
  environment      = var.realm
  tf-state-key     = var.tf-state-key
  team             = "Platform Services"
  aws-account-type = var.aws-account-type
  repository       = "https://github.com/Nubes-Opus/bizwithai-infra/platform/modules"
}