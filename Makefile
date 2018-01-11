# Copyright 2017 Heptio Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET = eventrouter
BUILDMNT = /go/src/github.com/openshift/$(TARGET)
REGISTRY ?= gcr.io/heptio-images
VERSION ?= v0.2
IMAGE = $(REGISTRY)/$(BIN)
BUILD_IMAGE ?= gcr.io/heptio-images/golang:1.9-alpine3.6
DOCKER ?= docker
DIR := ${CURDIR}

all: container

container:
	$(DOCKER) run --rm -v $(DIR):$(BUILDMNT) -w $(BUILDMNT) $(BUILD_IMAGE) go build
	$(DOCKER) build -t $(REGISTRY)/$(TARGET):latest -t $(REGISTRY)/$(TARGET):$(VERSION) .

push:
	$(DOCKER) push $(REGISTRY)/$(TARGET):latest
	if git describe --tags --exact-match >/dev/null 2>&1; \
	then \
		$(DOCKER) push $(REGISTRY)/$(TARGET):$(VERSION) \
	fi

test:
	$(DOCKER) run --rm -v $(DIR):$(BUILDMNT) -w $(BUILDMNT) $(BUILD_IMAGE) /bin/sh -c 'go test $$(go list ./... | grep -v /vendor/)'

.PHONY: all local container push

clean:
	rm -f $(TARGET)
	$(DOCKER) rmi $(REGISTRY)/$(TARGET):latest
	$(DOCKER) rmi $(REGISTRY)/$(TARGET):$(VERSION)
