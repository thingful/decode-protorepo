

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

.PHONY: bootstrap
bootstrap: ## install everything needed to work with these
	@echo "--> Bootstrapping"
	go get -u github.com/twitchtv/retool
	retool add github.com/golang/protobuf/protoc-gen-go master
	retool add github.com/twitchtv/twirp/protoc-gen-twirp master
