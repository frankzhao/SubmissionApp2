ROOT	:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
NAME	:= submissionapp2
TAG 	:= docker.io/chickenmaru/$(NAME)
VERSION := 0.1.0-dev

.PHONY: all build

all: build

quick: build

build:
	docker build -t $(TAG) $(ROOT)

run:
	docker run --rm -p 3000:3000 -it --name $(NAME) $(TAG)

shell:
	docker exec -it $(NAME) bash

clean:
	docker stop $(NAME)
	docker rm -v $(NAME)
	docker rmi -f $(TAG)

tag: 
	docker tag $(TAG) $(TAG):$(VERSION)
	docker tag $(TAG):$(VERSION) $(TAG):latest

push:
	docker push $(TAG):$(VERSION)
	docker push $(TAG):latest
