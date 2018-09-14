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

resource "aws_lambda_function" "crowbar_hello_world" {
  filename         = "./crowbar/deploy.zip"
  function_name    = "crowbar_hello_world"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "liblambda.handler"
  source_code_hash = "${base64sha256(file("./crowbar/target/deploy/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "python_hello_world" {
  filename         = "./python/deploy.zip"
  function_name    = "python_hello_world"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "hello.handler"
  source_code_hash = "${base64sha256(file("./python/deploy.zip"))}"
  runtime          = "python3.6"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "rust-aws_hello_world" {
  filename         = "./rust-aws-lambda/deploy.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "rust-aws-lambda"
  handler          = "rust-aws-lambda"
  source_code_hash = "${base64sha256(file("./rust-aws-lambda/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "go_hello_world" {
  filename         = "./go/deploy.zip"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  function_name    = "go_hello_world"
  handler          = "hello"
  source_code_hash = "${base64sha256(file("./go/deploy.zip"))}"
  runtime          = "go1.x"
  tracing_config   = { mode = "Active" }
}

data "aws_lambda_invocation" "cold_crowbar" {
  function_name = "${aws_lambda_function.crowbar_hello_world.function_name}"
  input = ""
}

data "aws_lambda_invocation" "cold_python" {
  function_name = "${aws_lambda_function.python_hello_world.function_name}"
  input = ""
}

data "aws_lambda_invocation" "cold_rust_aws" {
  function_name = "${aws_lambda_function.rust-aws_hello_world.function_name}"
  input = ""
}

data "aws_lambda_invocation" "cold_go" {
  function_name = "${aws_lambda_function.go_hello_world.function_name}"
  input = ""
}
