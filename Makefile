# Check for required command tools to build or stop immediately
EXECUTABLES = git go
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

PLATFORMS=darwin linux windows
ARCHITECTURES=amd64

.DEFAULT_GOAL := dev

.PHONY: dev
dev: ## dev build
dev: clean install generate build fmt  test mod-tidy

.PHONY: ci
ci: ## CI build
ci: dev diff

.PHONY: clean
clean: ## remove files created during build
	$(call print-target)
	rm -rf dist
	rm -f coverage.*

.PHONY: install
install: ## go install tools
	$(call print-target)
	cd tools && go install $(shell cd tools && go list -f '{{ join .Imports " " }}' -tags=tools)

.PHONY: generate
generate: ## go generate
	$(call print-target)
	go generate ./...

.PHONY: build
GIT_COMMIT := $(shell git rev-list -1 HEAD)
VERSION := $(shell cat ./version)
BUILD_DATE := $(shell date -uR)
BUILD_DATE := "github.com/nblagoev/gotmpl/cmd"
build: ## go build
	$(call print-target)
	$(foreach GOOS, $(PLATFORMS),\
		$(foreach GOARCH, $(ARCHITECTURES),\
			$(shell export GOOS=$(GOOS); export GOARCH=$(GOARCH); go build -ldflags "-X '$(PKG).revision=$(GIT_COMMIT)' -X '$(PKG).version=$(VERSION)' -X '$(PKG).buildDate=$(BUILD_DATE)'" -o ./dist/$(GOOS)-$(GOARCH)/gotmpl)))

.PHONY: fmt
fmt: ## go fmt
	$(call print-target)
	go fmt ./...

.PHONY: lint
lint: ## golangci-lint
	$(call print-target)
	golangci-lint run -v

.PHONY: test
test: ## go test with race detector and code covarage
	$(call print-target)
	go test -race -covermode=atomic -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

.PHONY: mod-tidy
mod-tidy: ## go mod tidy
	$(call print-target)
	go mod tidy
	cd tools && go mod tidy

.PHONY: diff
diff: ## git diff
	$(call print-target)
	git diff --exit-code
	RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

.PHONY: run
run: ## go run
	@go run -race ./cmd/gotmpl

.PHONY: go-clean
go-clean: ## go clean build, test and modules caches
	$(call print-target)
	go clean -r -i -cache -testcache -modcache

.PHONY: docker
docker: ## run in golang container, example: make docker run="make ci"
	docker run --rm \
		-v $(CURDIR):/repo $(args) \
		-w /repo \
		golang:1.16 $(run)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef
