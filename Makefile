.PHONY:
all:
	$(MAKE) -C crowbar
	$(MAKE) -C python
	$(MAKE) -C rust-aws-lambda
	$(MAKE) -C go
