resource "null_resource" "aws_account_type_is_not_acceptable_value" {
  triggers = contains(var.aws-account-type-enum, var.aws-account-type) ? tomap({ "test" = "failed" }) : tomap({ "output" = file("ERROR: You did not provide an acceptable value for the tag aws-account-type. The value must be one of these ['prod','nonprod'].") })
  lifecycle {
    ignore_changes = [triggers]
  }
}

resource "null_resource" "ci_owner_is_not_acceptable_value" {
  triggers = contains(var.ci-owner-enum, var.ci-owner) ? tomap({ "test" = "failed" }) : tomap({ "output" = file("ERROR: You did not provide an acceptable value for the tag ci-owner. The value must be one of these [raja,manohar].") })
  lifecycle {
    ignore_changes = [triggers]
  }
}

resource "null_resource" "business_unit_is_not_acceptable_value" {
  triggers = contains(var.business-unit-enum, var.business-unit) ? tomap({ "test" = "failed" }) : tomap({ "output" = file("ERROR: You did not provide an acceptable value for the tag business-unit. The value must be one of these [NubesOpus,Clients].") })
  lifecycle {
    ignore_changes = [triggers]
  }
}

resource "null_resource" "enable_backup_is_not_acceptable_value" {
  triggers = contains(var.enable-backup-enum, var.enable-backup) ? tomap({ "test" = "failed" }) : tomap({ "output" = file("ERROR: You did not provide an acceptable value for the tag enable-backup. The value must be one of these [4am-6am-utc,7am-9am-utc].") })
  lifecycle {
    ignore_changes = [triggers]
  }

}
