.PHONY: all
all:
	docker run -it --rm -e "USER_UID=$(shell id -u)" \
		-e "USER_GID=$(shell id -g)" -v "$(CURDIR):/home/rust/project" \
		-e "PKG_CONFIG_PATH=/var/lang/lib/pkgconfig" \
		-w "/home/rust/project" \
		naftulikay/crowbar@sha256:1b9f5052fe15199a60264ae08adf13a93c884a44f12db731dd8d91a6355b556e \
		$(MAKE) in_docker

.PHONY: in_docker
in_docker:
	# This is the difference between it linking successfully and not. I blame lambda's python configuration for being bad.
	sudo sed -i "s|'Py_ENABLE_SHARED'\: 0|'Py_ENABLE_SHARED'\: 1|g" /var/lang/lib/python3.6/_sysconfigdata_m_linux_x86_64-linux-gnu.py
	cargo build --release
	cd target/release && zip ../../deploy.zip liblambda.so
