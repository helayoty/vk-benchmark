FROM --platform=${TARGETPLATFORM:-linux/amd64} golang:1.18 as builder

# Set the current directory inside the container
WORKDIR /app

COPY go.mod .
COPY go.sum .
COPY Makefile .

# Copy sources inside the docker
COPY pkg/ pkg/
COPY cmd/ cmd/

# install the dependencies
RUN go mod tidy

# Build the binaries from the source
RUN GOARCH=${TARGETARCH} make

###### Start a new stage from scratch #######
FROM --platform=${TARGETPLATFORM:-linux/amd64} gcr.io/distroless/static:nonroot

WORKDIR /
COPY --from=builder /app/_output/bin/vk-benchmark .

# Expose port 8080 to the outside container
EXPOSE 8082

ENTRYPOINT ["/bin/vk-benchmark"]
