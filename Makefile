LOCAL_BIN := $(CURDIR)/bin

GRPC_GATEWAY_VERSION  := v2.25.1
GEN_GO_VERSION        := v1.31.0
GEN_GO_GRPC_VERSION   := v1.5.1
BUF_VERSION           := v1.51.0

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
	$(LOCAL_BIN)/buf dep update

.PHONY: lint
lint:
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/buf lint

.PHONY: gen
gen:
	PATH="$(PATH):$(LOCAL_BIN)" $(LOCAL_BIN)/buf generate
