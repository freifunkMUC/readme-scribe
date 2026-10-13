# markscribe, built from source with a current Go toolchain. The source is
# the fork github.com/freifunkMUC/markscribe, which keeps the dependencies
# current; upstream's last release, v0.6.0, is from 2021.
FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27.2-alpine@sha256:f92b6ef800e499660581efdabdf25d9d817a9d124eaf900924f0504e7e27e12d AS build

ARG MARKSCRIBE_COMMIT=21d9a8a9dc4823c8d362d6ba2e8a761856c431c4
ARG TARGETOS
ARG TARGETARCH

# A cross-compiled binary lands in a subdirectory of /go/bin.
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
      go install -trimpath -ldflags="-s -w" github.com/freifunkMUC/markscribe@${MARKSCRIBE_COMMIT} && \
    find /go/bin -name markscribe -exec cp {} /markscribe \;

# Root, as GitHub requires of a container action: it writes into the
# workspace of the job, which belongs to the runner's user.
FROM gcr.io/distroless/static-debian13:latest@sha256:58133991db06659feaabe0f4e97a35cebf15ef4ea08f8a4c6d2ee5f75e4aa6a0

COPY --from=build /markscribe /markscribe
ENTRYPOINT ["/markscribe"]
