// https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/flow-logs.html#flow-logs-iam

data "template_file" "assume_role_policy" {
  template = file("${path.module}/assume_role_policy.json")
}

data "template_file" "log_policy" {
  template = file("${path.module}/log_policy.json")
}

resource "aws_iam_role" "iam_log_role" {
  name               = "${var.vpc_name}_flow_log_role"
  assume_role_policy = data.template_file.assume_role_policy.rendered
  tags               = var.tags
}

resource "aws_iam_role_policy" "log_policy" {
  name   = "${var.vpc_name}_flow_log_policy"
  role   = aws_iam_role.iam_log_role.id
  policy = data.template_file.log_policy.rendered
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = var.log_group_name == "" ? local.default_log_group_name : var.log_group_name
  tags = var.tags
}

resource "aws_flow_log" "vpc_flow_log" {
  #log_group_name = "${aws_cloudwatch_log_group.flow_log_group.name}"
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  iam_role_arn    = aws_iam_role.iam_log_role.arn
  vpc_id          = var.vpc_id
  traffic_type    = var.traffic_type

}
