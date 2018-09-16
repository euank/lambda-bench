#!/bin/bash

set -eu

LAMBDA_SIZE="${1:-128}"
SLEEP_TIME="${2:-45m}" # Time to sleep before lambda is "frozen"

dir=$(mktemp -p . -d lambda_XXXXX)
prefix="$RANDOM"

FUNCS=( "crowbar_hello_world" "python_hello_world" "rust-aws-lambda_hello_world" "go_hello_world" )

for src in "crowbar" "python" "go" "rust-aws-lambda"; do
  mkdir -p "$dir/$src"
  cp "$src/deploy.zip" "$dir/$src/deploy.zip"

  # modify each deploy zip to cache-bust just in case lambda gets really good
  # at caching zips within an account across functions
  pushd "$dir/$src"
  echo "$RANDOM" > random
  zip deploy.zip random
  rm -f random
  popd
done

# cool, now $dir is setup for terraform's expectations. Create the functions.
echo "To destroy: "
echo terraform destroy -auto-approve -var "prefix=$prefix" -state="$dir/tfstate" -var "zipdir=$dir"
terraform apply -auto-approve -state="$dir/tfstate" -var "prefix=$prefix" -var "zipdir=$dir"

start_time="$(date -Is)"

for fn in "${FUNCS[@]}"; do
  # Wait before the fn invocation in case lambda was already warm
  echo "Sleeping ${SLEEP_TIME}. Get some coffee"
  sleep "${SLEEP_TIME}"
  # Invoke once for a cold number, once for a warm one
  aws lambda invoke --function-name "${prefix}${fn}" /dev/null
  # let the first invocation finish
  sleep 20
  aws lambda invoke --function-name "${prefix}${fn}" /dev/null
done

# Collect data

out="output/$RANDOM"
mkdir -p "$out"

echo "$SLEEP_TIME" > "$out/sleep"

# The aws cli is fine for invoking lambdas, but for parsing doubly nested json
# documents (thanks xray), I'd rather use a real language.
ruby ./collect_trace.rb \
  "${prefix}" \
  "${LAMBDA_SIZE}" \
  "${FUNCS[@]}" > "$out/results.csv"

# finally, cleanup
terraform destroy -auto-approve -state="$dir/tfstate" -var "prefix=$prefix" -var "zipdir=$dir"
rm -rf "$dir"
