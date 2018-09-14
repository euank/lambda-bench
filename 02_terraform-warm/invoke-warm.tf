data "aws_lambda_invocation" "warm_crowbar" {
  function_name = "${aws_lambda_function.crowbar_hello_world_warm.function_name}"
  input = ""
}
data "aws_lambda_invocation" "warm_python" {
  function_name = "${aws_lambda_function.python_hello_world_warm.function_name}"
  input = ""
}
data "aws_lambda_invocation" "warm_rust_aws" {
  function_name = "${aws_lambda_function.rust-aws_hello_world_warm.function_name}"
  input = ""
}
data "aws_lambda_invocation" "warm_go" {
  function_name = "${aws_lambda_function.go_hello_world_warm.function_name}"
  input = ""
}
