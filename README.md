# Lambda bench

This repository contains code, scripts, and results for benchmarking the execution of lambda functions.

## Dependencies

This repository depends on you having a reasonable terraform, ruby, and docker
environment available on your system.
The ruby environment should include an installation of the v2 aws-sdk gem.

## Running benchmarks

To run the benchmarks, first you must build the lambda deployment zips.

This can be done by typing `make` and waiting  a while.

It should complete with no errors.

After that completes, you should run `terraform init`, followed by `./run.sh`.

All together:

```sh
$ make # should take a while to pull docker images and build
$ terraform init
$ AWS_PROFILE=my-aws-profile ./run.sh
# Wait *3 hours*
# Do not run `./run.sh` in parallel on one account; use multiple AWS accounts
# if you want to make things go quicker

# data should exist in `./output` now
```

## Plotting results

The results I got have been committed to this repo, along with some python code
to plot them. This code is in `./util/process_results/process_results.py`, and
running it should be fairly trivial.
