# ビルドステージ
FROM golang:1.22.3-alpine3.18 AS builder

WORKDIR /app

# 依存関係をコピーしてダウンロード
COPY go.mod go.sum ./
RUN go mod download

# ソースコードをコピー
COPY . .

# ツールのインストール
RUN go install go.uber.org/mock/mockgen@v0.3.0
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@v1.23.0

# アプリケーションのビルド
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main ./app/cmd/main.go

# 実行ステージ
FROM alpine:3.18

WORKDIR /app

# ビルドステージから実行可能ファイルをコピー
COPY --from=builder /app/main .

# 必要な証明書をコピー
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080

CMD ["./main"]
