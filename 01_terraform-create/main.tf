variable "prefix" {
  type = "string"
  description = "lambda function name prefix"
}

variable "zipdir" {
  type = "string"
  description = "directory with each deploy zip in it"
}

variable "lambda_size" {
  type = "string"
  default = "128"
  description = "How much memory each lambda will have"
}

provider "aws" {
  region = "us-west-2" # consistent region for benchmarks
}

resource "aws_iam_policy" "iam_lambda_policy" {
  name = "${var.prefix}iam_lambda_policy_bench"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "xray:*",
        "cloudwatch:*",
        "lambda:*",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "1"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.iam_lambda_policy.arn}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.prefix}iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "crowbar_hello_world_cold" {
  filename         = "${var.zipdir}/crowbar/deploy-cold.zip"
  function_name    = "${var.prefix}crowbar_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "liblambda.handler"
  source_code_hash = "${base64sha256(file("./crowbar/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "crowbar_hello_world_warm" {
  filename         = "${var.zipdir}/crowbar/deploy-warm.zip"
  function_name    = "${var.prefix}crowbar_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "liblambda.handler"
  source_code_hash = "${base64sha256(file("./crowbar/deploy.zip"))}"
  runtime          = "python3.6"
}

resource "aws_lambda_function" "python_hello_world_cold" {
  filename         = "${var.zipdir}/python/deploy-cold.zip"
  function_name    = "${var.prefix}python_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "hello.handler"
  source_code_hash = "${base64sha256(file("./python/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "python_hello_world_warm" {
  filename         = "${var.zipdir}/python/deploy-warm.zip"
  function_name    = "${var.prefix}python_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "hello.handler"
  source_code_hash = "${base64sha256(file("./python/deploy.zip"))}"
  runtime          = "python3.6"
}

resource "aws_lambda_function" "rust-aws_hello_world_cold" {
  filename         = "${var.zipdir}/rust-aws-lambda/deploy-cold.zip"
  function_name    = "${var.prefix}rust-aws-lambda_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "rust-aws-lambda"
  source_code_hash = "${base64sha256(file("./rust-aws-lambda/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "rust-aws_hello_world_warm" {
  filename         = "${var.zipdir}/rust-aws-lambda/deploy-warm.zip"
  function_name    = "${var.prefix}rust-aws-lambda_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "rust-aws-lambda"
  source_code_hash = "${base64sha256(file("./rust-aws-lambda/deploy.zip"))}"
  runtime          = "go1.x"
}

resource "aws_lambda_function" "go_hello_world_cold" {
  filename         = "${var.zipdir}/go/deploy-cold.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "${var.prefix}go_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  handler          = "hello"
  source_code_hash = "${base64sha256(file("./go/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "go_hello_world_warm" {
  filename         = "${var.zipdir}/go/deploy-warm.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "${var.prefix}go_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  handler          = "hello"
  source_code_hash = "${base64sha256(file("./go/deploy.zip"))}"
  runtime          = "go1.x"
}
