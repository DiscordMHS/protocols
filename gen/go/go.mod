module github.com/DiscordMHS/protocols/gen/go

go 1.24.4

require (
	buf.build/gen/go/bufbuild/protovalidate/protocolbuffers/go v1.0.0
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.27.3
	google.golang.org/genproto/googleapis/api v0.0.0-20251014184007-4626949a642f
	google.golang.org/grpc v1.76.0
	google.golang.org/protobuf v1.36.10
)

require (
	golang.org/x/net v0.42.0 // indirect
	golang.org/x/sys v0.34.0 // indirect
	golang.org/x/text v0.29.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20251007200510-49b9836ed3ff // indirect
)

replace buf.build/gen/go/bufbuild/protovalidate/protocolbuffers/go => ./local/buf.build/gen/go/bufbuild/protovalidate/protocolbuffers/go
