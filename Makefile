-include env_make

NEXUS_VERSION ?= 3.19.1
NEXUS_BUILD ?= 01


REPO = bowens/nexus-oss-apk-composer
NAME = nexus-apk-composer-$(NEXUS_VERSION)

ifeq ($(TAG),)
  TAG ?= $(NEXUS_VERSION)
endif

.PHONY: build push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg NEXUS_VERSION=$(NEXUS_VERSION) \
		--build-arg NEXUS_BUILD=$(NEXUS_BUILD) \
		./


push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -e DEBUG=1 $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
