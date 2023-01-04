# Start from latest golang base image
FROM --platform=$BUILDPLATFORM golang:1.18 as builder

ARG TARGETARCH
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS

# Set the current directory inside the container
WORKDIR /app

COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying s

# Copy sources inside the docker
COPY . .

# install the dependencies
RUN go mod download

# Build the binaries from the source
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GO111MODULE=on make build

###### Start a new stage from scratch #######
FROM --platform=$BUILDPLATFORM gcr.io/distroless/static:nonroot

COPY --from=builder /app/_output/bin/vk-benchmark /usr/bin/vk-benchmark
ENTRYPOINT [ "/usr/bin/vk-benchmark" ]
