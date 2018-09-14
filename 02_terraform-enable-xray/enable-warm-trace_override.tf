resource "aws_lambda_function" "crowbar_hello_world_warm" {
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "python_hello_world_warm" {
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "rust-aws_hello_world_warm" {
  tracing_config   = { mode = "Active" }
}

resource "aws_lambda_function" "go_hello_world_warm" {
  tracing_config   = { mode = "Active" }
}
