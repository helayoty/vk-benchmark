# Copyright 2021 The Kubernetes Authors.
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


# Explicitly opt into go modules, even though we're inside a GOPATH directory
export GO111MODULE=on

# Image URL to use all building/pushing image targets
DOCKER_REG ?= ${or ${DOCKER_REGISTRY},"guofei.azurecr.io"}
IMG ?= ${DOCKER_REG}/vk-benchmark-amd64 
TAG ?= 0.0.1

# TEST_FLAGS used as flags of go test.
TEST_FLAGS ?= -v

export KUBEBUILDER_ASSETS=/tmp/kubebuilder/bin/

.PHONY: all
all: build

build:
	go build -o bin/vk-benchmark cmd/benchmark/	


OUTPUT_TYPE ?= type=registry
BUILDX_BUILDER_NAME ?= img-builder
QEMU_VERSION ?= 5.2.0-2

.PHONY: docker-buildx-builder
docker-buildx-builder:
	@if ! docker buildx ls | grep $(BUILDX_BUILDER_NAME); then \
		docker run --rm --privileged multiarch/qemu-user-static:$(QEMU_VERSION) --reset -p yes; \
		docker buildx create --name $(BUILDX_BUILDER_NAME) --use; \
		docker buildx inspect $(BUILDX_BUILDER_NAME) --bootstrap; \
	fi

.PHONY: build-image
build-image: docker-buildx-builder
	docker buildx build \
		--file Dockerfile \
		--output=$(OUTPUT_TYPE) \
		--platform="linux/amd64" \
		--pull \
		--tag ${DOCKER_REG}/vk-benchmark:${TAG} .
