variable "prefix" {
  type = "string"
  description = "lambda function name prefix"
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
  name = "iam_lambda_policy"
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
  name = "iam_for_lambda"

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
  filename         = "./crowbar/deploy.zip"
  function_name    = "${var.prefix}crowbar_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "liblambda.handler"
  source_code_hash = "${base64sha256(file("./crowbar/target/deploy/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "crowbar_hello_world_warm" {
  filename         = "./crowbar/deploy.zip"
  function_name    = "${var.prefix}crowbar_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "liblambda.handler"
  source_code_hash = "${base64sha256(file("./crowbar/target/deploy/deploy.zip"))}"
  runtime          = "python3.6"
}

resource "aws_lambda_function" "python_hello_world_cold" {
  filename         = "./python/deploy.zip"
  function_name    = "${var.prefix}python_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "hello.handler"
  source_code_hash = "${base64sha256(file("./python/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "python_hello_world_warm" {
  filename         = "./python/deploy.zip"
  function_name    = "${var.prefix}python_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "hello.handler"
  source_code_hash = "${base64sha256(file("./python/deploy.zip"))}"
  runtime          = "python3.6"
}

resource "aws_lambda_function" "rust-aws_hello_world_cold" {
  filename         = "./rust-aws-lambda/deploy.zip"
  function_name    = "rust-aws-${var.prefix}lambda_cold"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "rust-aws-lambda"
  source_code_hash = "${base64sha256(file("./rust-aws-lambda/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "rust-aws_hello_world_warm" {
  filename         = "./rust-aws-lambda/deploy.zip"
  function_name    = "${var.prefix}rust-aws-lambda_warm"
  memory_size      = "${var.lambda_size}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "rust-aws-lambda"
  source_code_hash = "${base64sha256(file("./rust-aws-lambda/deploy.zip"))}"
  runtime          = "go1.x"
}

resource "aws_lambda_function" "go_hello_world_cold" {
  filename         = "./go/deploy.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "${var.prefix}go_hello_world_cold"
  memory_size      = "${var.lambda_size}"
  handler          = "hello"
  source_code_hash = "${base64sha256(file("./go/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "go_hello_world_warm" {
  filename         = "./go/deploy.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "${var.prefix}go_hello_world_warm"
  memory_size      = "${var.lambda_size}"
  handler          = "hello"
  source_code_hash = "${base64sha256(file("./go/deploy.zip"))}"
  runtime          = "go1.x"
}
