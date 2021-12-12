locals {
  tagging-module-version    = "1.0.0"
  infrastructure-management = "terraform"

  valueMapStarter = {
    Name                      = var.name
    application-name          = var.application-name
    product                   = var.product
    team                      = var.team
    contact                   = var.contact
    environment               = var.environment
    repository                = var.repository
    offhours                  = var.offhours
    tf-state-bucket           = var.tf-state-bucket
    tf-state-key              = var.tf-state-key
    tf-workspace              = terraform.workspace
    infrastructure-management = local.infrastructure-management
    tagging-module-version    = local.tagging-module-version
  }



  //Enforced tags
  //You can't interpolate and return a null, but because Name is always required and merge() removes duplicates we use name as our default value
  //Interpolation can't happen as maps so we had to do it at the string level
  valueMapE   = tomap({ contains(var.environment-enum, var.environment) ? "environment" : "Name" = contains(var.environment-enum, var.environment) ? var.environment : var.name })
  valueMapAAT = tomap({ contains(var.aws-account-type-enum, var.aws-account-type) ? "aws-account-type" : "Name" = contains(var.aws-account-type-enum, var.aws-account-type) ? var.aws-account-type : var.name })
  valueMapCO  = tomap({ contains(var.ci-owner-enum, var.ci-owner) ? "ci-owner" : "Name" = contains(var.ci-owner-enum, var.ci-owner) ? var.ci-owner : var.name })
  valueMapBU  = tomap({ contains(var.business-unit-enum, var.business-unit) ? "business-unit" : "Name" = contains(var.business-unit-enum, var.business-unit) ? var.business-unit : var.name })
  valueMapEB  = tomap({ contains(var.enable-backup-enum, var.enable-backup) ? "enable-backup" : "Name" = contains(var.enable-backup-enum, var.enable-backup) ? var.enable-backup : var.name })
  valueMapM   = tomap({ contains(var.monitor-enum, var.monitor) ? "monitor" : "Name" = contains(var.monitor-enum, var.monitor) ? var.monitor : var.name })

  //optional tags
  //You can't interpolate and return a null, but because Name is always required and merge() removes duplicates we use name as our default value
  //Interpolation can't happen as maps so we had to do it at the string level
  valueMapCC = tomap({ var.cost-center == "" ? "Name" : "cost-center" = var.cost-center == "" ? var.name : var.cost-center })
  valueMapIT = tomap({ var.issue-tracking == "" ? "Name" : "issue-tracking" = var.issue-tracking == "" ? var.name : var.issue-tracking })

  #Main tag format necessary for most pieces if infra
  valueMap = merge(local.valueMapE, local.valueMapAAT, local.valueMapCO, local.valueMapBU, local.valueMapEB, local.valueMapM, local.valueMapStarter, local.valueMapCC, local.valueMapIT)

  #The format of tags necessary for AutoScaling Groups is different so we use this map instead.
  valueMapASG = [
    {
      key                 = "Name"
      value               = var.name
      propagate_at_launch = "true"
    },
    {
      key                 = "application-name"
      value               = var.application-name
      propagate_at_launch = "true"
    },
    {
      key                 = "product"
      value               = var.product
      propagate_at_launch = "true"
    },
    {
      key                 = "environment"
      value               = var.environment
      propagate_at_launch = "true"
    },
    {
      key                 = "repository"
      value               = var.repository
      propagate_at_launch = "true"
    },
    {
      key                 = "team"
      value               = var.team
      propagate_at_launch = "true"
    },
    {
      key                 = "contact"
      value               = var.contact
      propagate_at_launch = "true"
    },
    {
      key                 = contains(var.ci-owner-enum, var.ci-owner) ? "ci-owner" : "Name"
      value               = contains(var.ci-owner-enum, var.ci-owner) ? var.ci-owner : var.name
      propagate_at_launch = "true"
    },
    {
      key                 = contains(var.business-unit-enum, var.business-unit) ? "business-unit" : "Name"
      value               = contains(var.business-unit-enum, var.business-unit) ? var.business-unit : var.name
      propagate_at_launch = "true"
    },
    {
      key                 = contains(var.enable-backup-enum, var.enable-backup) ? "enable-backup" : "Name"
      value               = contains(var.enable-backup-enum, var.enable-backup) ? var.enable-backup : var.name
      propagate_at_launch = "true"
    },
    {
      key                 = contains(var.aws-account-type-enum, var.aws-account-type) ? "aws-account-type" : "Name"
      value               = contains(var.aws-account-type-enum, var.aws-account-type) ? var.aws-account-type : var.name
      propagate_at_launch = "true"
    },
    {
      key                 = "offhours"
      value               = var.offhours
      propagate_at_launch = "true"
    },
    {
      key                 = "tf-state-bucket"
      value               = var.tf-state-bucket
      propagate_at_launch = "true"
    },
    {
      key                 = "tf-state-key"
      value               = var.tf-state-key
      propagate_at_launch = "true"
    },
    {
      key                 = "tf-workspace"
      value               = terraform.workspace
      propagate_at_launch = "true"
    },
    {
      key                 = var.cost-center == "" ? "Name" : "cost-center"
      value               = var.cost-center == "" ? var.name : var.cost-center
      propagate_at_launch = "true"
    },
    {
      key                 = var.issue-tracking == "" ? "Name" : "issue-tracking"
      value               = var.issue-tracking == "" ? var.name : var.issue-tracking
      propagate_at_launch = "true"
    },
    {
      key                 = "infrastructure-management"
      value               = local.infrastructure-management
      propagate_at_launch = "true"
    },
    {
      key                 = "tagging-module-version"
      value               = local.tagging-module-version
      propagate_at_launch = "true"
    },
  ]

}
