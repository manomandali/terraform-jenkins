# AWS VPC Flow Log module for Terraform

This is a reusable Terraform module for setting up [VPC flow logs](https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/flow-logs.html) in Amazon Web Services.

## Usage

```hcl
module "flow_logs" {
  source   = "../modules/vpc-flow-log/"
  vpc_id   = "${module.vpc.vpc_id}"
  vpc_name = "${module.vpc.vpc_name}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| log_group_name | The name of the CloudWatch log group. | string | `` | no |
| traffic_type | The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL. | string | `ALL` | no |
| vpc_id | VPC ID to attach to | string | - | yes |
| vpc_name | VPC name to attach to | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| log_group_name | name of the log group |
