# Use a recent ubuntu and install golang for building.
# This is just so we can use the same ubuntu:rolling for final image, and just transpose runtime dependencies. Hopefully.
FROM ubuntu:rolling as builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install git golang build-essential libgpgme-dev libassuan-dev libbtrfs-dev libdevmapper-dev pkg-config


## Build Skopeo from Source.
ARG SKOPEO_VERSION="v1.5.2"

RUN git clone --single-branch --branch="${SKOPEO_VERSION}" https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo
# Build via makefile. Dynamic executable produced, thus dependent on system libraries.
RUN cd $GOPATH/src/github.com/containers/skopeo && DISABLE_DOCS=1 make bin/skopeo
RUN cp $GOPATH/src/github.com/containers/skopeo/bin/skopeo /bin/skopeo
RUN skopeo --version

## Build Skopeo directly, copied from makefile, for those brave enough to try to make this static one day.
#WORKDIR /go/src/github.com/containers/skopeo
#RUN CGO_CFLAGS="" CGO_LDFLAGS="-L/usr/lib/x86_64-linux-gnu -lgpgme -lassuan -lgpg-error" GO111MODULE=on go build -mod=vendor "-buildmode=pie" -ldflags '-X main.gitCommit=8a88191c844a35cd54048c34bee3a6656ed5df5f ' -gcflags "" -tags "   " -o /usr/bin/skopeo ./cmd/skopeo

# Now, build Dregsy from source.
ARG DREGSY_VERSION="0.4.1"
RUN git clone --single-branch --branch="${DREGSY_VERSION}" https://github.com/xelalexv/dregsy.git $GOPATH/src/github.com/xelalexv/dregsy
RUN cd $GOPATH/src/github.com/xelalexv/dregsy &&  CGO_ENABLED=0 go build -v -tags netgo -installsuffix netgo -ldflags "-w -X main.DregsyVersion=someversion" -o /usr/bin/dregsy ./cmd/dregsy/
RUN dregsy || true # no such thing as "--version", nice. thanks.


FROM ubuntu:rolling
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y  install libgpgme11 libassuan0 libdevmapper1.02.1 # those gotta match the build-deps above
COPY --from=builder /usr/bin/skopeo /usr/bin/skopeo
COPY --from=builder /usr/bin/dregsy /usr/bin/dregsy
# Sanity check
RUN ldd /usr/bin/skopeo
#RUN ldd /usr/bin/dregsy # built static, thanks
RUN /usr/bin/skopeo --version
RUN dregsy || true # no such thing as "--version", nice. thanks.





