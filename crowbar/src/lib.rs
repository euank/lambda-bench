#[macro_use(lambda)]
extern crate crowbar;
#[macro_use]
extern crate cpython;

lambda!(|event, context| {
    println!("hello world, this is {}", context.function_name());
    Ok(event)
});
