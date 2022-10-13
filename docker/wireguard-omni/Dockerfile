FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy as builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -qq install -y wget

RUN wget https://go.dev/dl/go1.19.2.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && \
    rm go1.19.2.linux-amd64.tar.gz

WORKDIR /build

# configure build-dependencies

RUN mkdir -p /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_DIR $NVM_DIR/versions/node
ENV NODE_VERSION 16

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default && \
    nvm version > $NVM_DIR/node.version && \
    ln -sf $NODE_DIR/$(cat $NVM_DIR/node.version) $NODE_DIR/$NODE_VERSION

ENV NODE_PATH $NODE_DIR/$NODE_VERSION/lib/node_modules
ENV PATH      $NODE_DIR/$NODE_VERSION/bin:$PATH:/usr/local/go/bin:/root/go/bin/

RUN npm install --global yarn

RUN yarn --version

# Add dependencies
COPY ui/go.mod /build
COPY ui/go.sum /build
COPY ui/package.json /build
COPY ui/yarn.lock /build

# Prepare assets
RUN yarn install --pure-lockfile --production && \
    yarn cache clean

# Move admin-lte dist
RUN mkdir -p assets/dist/js assets/dist/css && \
    cp /build/node_modules/admin-lte/dist/js/adminlte.min.js \
    assets/dist/js/adminlte.min.js && \
    cp /build/node_modules/admin-lte/dist/css/adminlte.min.css \
    assets/dist/css/adminlte.min.css

# Move plugin assets
RUN mkdir -p assets/plugins && \
    cp -r /build/node_modules/admin-lte/plugins/jquery/ \
    /build/node_modules/admin-lte/plugins/fontawesome-free/ \
    /build/node_modules/admin-lte/plugins/bootstrap/ \
    /build/node_modules/admin-lte/plugins/icheck-bootstrap/ \
    /build/node_modules/admin-lte/plugins/toastr/ \
    /build/node_modules/admin-lte/plugins/jquery-validation/ \
    /build/node_modules/admin-lte/plugins/select2/ \
    /build/node_modules/jquery-tags-input/ \
    assets/plugins/

# Get go modules and build tool
RUN go mod download && \
    go install github.com/GeertJohan/go.rice/rice@latest

# Add sources
COPY ui/. /build

# Move custom assets
RUN cp -r /build/custom/ assets/

# Build
RUN rice embed-go && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -o wg-ui .

FROM ghcr.io/linuxserver/wireguard:amd64-latest

WORKDIR /app

RUN mkdir -p db

# Copy binary files
COPY --from=builder /build/wg-ui /app

RUN chmod +x wg-ui

EXPOSE 5000/tcp
