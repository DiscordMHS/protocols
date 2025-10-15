# 🧩 Protocols

Репозиторий **контрактов gRPC и REST API** для микросервисов проекта **DiscordMHS**.
Код генерируется с помощью [Buf](https://buf.build/) и стандартных плагинов для Go и gRPC Gateway.

---

## 📁 Структура проекта

```
.
├── Makefile                 # Основные команды (установка, генерация, линт)
├── buf.yaml                 # Конфигурация Buf (lint, deps, breaking)
├── buf.gen.yaml             # Конфигурация генерации (плагины)
├── proto/                   # Исходные proto-файлы
│   └── example/v1/example.proto
├── gen/                     # Сгенерированные артефакты
│   ├── go/                  # Go и gRPC Gateway код
│   └── openapi/             # OpenAPI (swagger.json)
└── bin/                     # Локально установленные бинарники
```

---

## 🚀 Быстрый старт

### 1. Установка инструментов

```bash
make install
```

Установит локально (в `bin/`):

* `buf`
* `protoc-gen-go`
* `protoc-gen-go-grpc`
* `protoc-gen-grpc-gateway`
* `protoc-gen-openapiv2`

> 💡 Все бинарники ставятся локально, не засоряя системный `$GOBIN`.

---

### 2. Проверка lint

```bash
make lint
```

Проверяет контракты на соответствие стандартам Buf.

---

### 3. Обновление зависимостей Buf

```bash
make update-buf
```

---

### 4. Генерация кода

```bash
make gen
```

Результаты:

```
gen/
├── go/example/v1/
│   ├── example.pb.go
│   ├── example.pb.gw.go
│   └── example_grpc.pb.go
└── openapi/example/v1/
    └── example.swagger.json
```

---

## 🧱 Buf конфигурация

### `buf.yaml`

* **lint:** `STANDARD`
* **breaking check:** `FILE`
* **deps:**

  * `buf.build/bufbuild/protovalidate`
  * `buf.build/googleapis/googleapis`
  * `buf.build/grpc-ecosystem/grpc-gateway`

### `buf.gen.yaml`

| Плагин                    | Назначение            | Папка         |
| ------------------------- | --------------------- | ------------- |
| `protoc-gen-go`           | Основные структуры Go | `gen/go`      |
| `protoc-gen-go-grpc`      | gRPC сервисы          | `gen/go`      |
| `protoc-gen-grpc-gateway` | HTTP endpoints (REST) | `gen/go`      |
| `protoc-gen-openapiv2`    | OpenAPI (Swagger)     | `gen/openapi` |

---

## 📘 Пример контракта

```proto
syntax = "proto3";

package example.v1;

option go_package = "github.com/DiscordMHS/protocols/gen/go/example/v1;example";

import "buf/validate/validate.proto";
import "google/api/annotations.proto";
import "protoc-gen-openapiv2/options/annotations.proto";

option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_swagger) = {
  info : { title : "Example Service API" version : "0.0.1" }
};

service ExampleService {
  rpc Hello(HelloRequest) returns (HelloResponse) {
    option (google.api.http) = {
      post : "/api/v1/hello/{id}"
      body : "*"
    };
    option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_operation) = {
      tags : "Example";
    };
  }
}

message HelloRequest {
  string id = 1 [
    (buf.validate.field).required = true,
    (buf.validate.field).string.uuid = true
  ];
}

message HelloResponse {
  string msg = 1;
}
```

---

## 🌐 Генерируемые артефакты

| Тип                    | Расположение             | Назначение                  |
| ---------------------- | ------------------------ | --------------------------- |
| `*.pb.go`              | `gen/go/example/v1`      | Go типы сообщений           |
| `*_grpc.pb.go`         | `gen/go/example/v1`      | gRPC сервис                 |
| `*.pb.gw.go`           | `gen/go/example/v1`      | HTTP-обёртка (grpc-gateway) |
| `example.swagger.json` | `gen/openapi/example/v1` | OpenAPI спецификация        |

---

## 🧩 Команды

| Команда           | Описание                         |
| ----------------- | -------------------------------- |
| `make install`    | Установить все инструменты       |
| `make lint`       | Проверить контракты Buf lint     |
| `make update-buf` | Обновить зависимости             |
| `make gen`        | Сгенерировать код (Go + OpenAPI) |
