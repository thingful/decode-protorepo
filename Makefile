

.PHONY: build
build:
	@echo "--> Building protobuf"
	./build.sh buildAll

.PHONY: clean
clean:
	@echo "--> Cleaning protobuf"
	./build.sh clean
