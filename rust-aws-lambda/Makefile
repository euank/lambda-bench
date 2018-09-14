.PHONY: all
all:
	# in docker to link against the right glibc
	docker run -v "$(CURDIR):/app" \
		--user=$(id -u) \
		-w "/app" \
		"lambci/lambda:build-go1.x" \
		sh -c 'curl https://sh.rustup.rs -sSf | sh -s -- -y && PATH="$$PATH:$$HOME/.cargo/bin" cargo build --release'
	cd target/release && zip ../../deploy.zip rust-aws-lambda
