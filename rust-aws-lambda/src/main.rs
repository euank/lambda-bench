extern crate aws_lambda as lambda;

fn main() {
    lambda::start(|()| {
        println!("hello world, this is {}", lambda::env::function_name());
        Ok(())
    })
}
