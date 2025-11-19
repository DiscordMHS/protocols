LOCAL_BIN := $(CURDIR)/bin

GRPC_GATEWAY_VERSION  := v2.25.1
GEN_GO_VERSION        := v1.31.0
GEN_GO_GRPC_VERSION   := v1.5.1
BUF_VERSION           := v1.51.0
EASYP_VERSION         := v0.7.17

EASYP_CONFIG := easyp.yaml

define install_tool
	GOBIN=$(LOCAL_BIN) go install $(1)@$(2)
endef

.PHONY: install
install:
	mkdir -p $(LOCAL_BIN)
	# go mod tidy
	$(call install_tool,github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway,$(GRPC_GATEWAY_VERSION))
	$(call install_tool,github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2,$(GRPC_GATEWAY_VERSION))
	$(call install_tool,google.golang.org/protobuf/cmd/protoc-gen-go,$(GEN_GO_VERSION))
	$(call install_tool,google.golang.org/grpc/cmd/protoc-gen-go-grpc,$(GEN_GO_GRPC_VERSION))
	$(call install_tool,github.com/bufbuild/buf/cmd/buf,$(BUF_VERSION))

.PHONY: update-buf
update-buf:
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/buf dep update

.PHONY: lint
lint:
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/buf lint

.PHONY: gen
gen:
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/buf generate

.PHONY: easyp-init
easyp-init:
	$(LOCAL_BIN)/easyp init

.PHONY: easyp-lint
easyp-lint:
	$(LOCAL_BIN)/easyp --config $(EASYP_CONFIG) lint

.PHONY: clean-gen
clean-gen:
	@echo "Cleaning generated files..."
	@rm -rf gen/go/auth gen/go/example gen/go/guild gen/go/memberships gen/go/proto 2>/dev/null || true
	@rm -rf gen/openapi/auth gen/openapi/example gen/openapi/guild gen/openapi/memberships gen/openapi/proto 2>/dev/null || true
	@echo "Cleaned!"

.PHONY: easyp-gen
easyp-gen: clean-gen
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/easyp --config $(EASYP_CONFIG) generate
	@if [ -d "gen/go/proto" ]; then \
		echo "Moving Go files from gen/go/proto to gen/go..."; \
		find gen/go/proto -mindepth 1 -maxdepth 1 -exec mv {} gen/go/ \; 2>/dev/null || true; \
		rm -rf gen/go/proto; \
	fi
	@if [ -d "gen/openapi/proto" ]; then \
		echo "Moving OpenAPI files from gen/openapi/proto to gen/openapi..."; \
		find gen/openapi/proto -mindepth 1 -maxdepth 1 -exec mv {} gen/openapi/ \; 2>/dev/null || true; \
		rm -rf gen/openapi/proto; \
	fi

.PHONY: easyp-mod-download
easyp-mod-download:
	$(LOCAL_BIN)/easyp --config $(EASYP_CONFIG) mod download

.PHONY: easyp-mod-update
easyp-mod-update:
	$(LOCAL_BIN)/easyp --config $(EASYP_CONFIG) mod update

.PHONY: mod-vendor
easyp-mod-vendor:
	$(LOCAL_BIN)/easyp --config $(EASYP_CONFIG) mod vendor
