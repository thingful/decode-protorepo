

.PHONY: build
build: ## build protobuf without pushing
	@echo "--> Building protobuf"
	./build.sh buildAll

.PHONY: push
push: ## build protobuf and push to associated repos
	@echo "--> Building and pushing protobuf"
	./build.sh buildAll true

.PHONY: clean
clean: ## clean build directory
	@echo "--> Cleaning protobuf"
	./build.sh clean
