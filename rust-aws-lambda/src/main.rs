extern crate aws_lambda as lambda;

fn main() {
    lambda::start(|()| {
        let ctx = lambda::Context::current();
        println!("hello world, this is {}", ctx.invoked_function_arn());
        Ok(())
    })
}
