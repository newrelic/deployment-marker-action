FROM arm64v8/alpine:3.23

ARG NEWRELIC_CLI_VER=0.106.20
ARG NEWRELIC_CLI_URL=https://github.com/newrelic/newrelic-cli/releases/download
RUN if [ "${TARGETARCH}" = "amd64" ]; then NEWRELIC_CLI_ARCH=x64; else NEWRELIC_CLI_ARCH=arm64; fi && \
    apk --no-cache add curl tar gzip && \
    curl -C - -L -o newrelic-cli.tar.gz ${NEWRELIC_CLI_URL}/v${NEWRELIC_CLI_VER}/newrelic-cli_${NEWRELIC_CLI_VER}_Linux_${NEWRELIC_CLI_ARCH}.tar.gz && \
    mkdir -p /bin && \
    tar xv -C /bin -f newrelic-cli.tar.gz && \
    rm newrelic-cli.tar.gz && \
    apk del curl tar gzip

# Copies your code file from your action repository to the filesystem path `/` of the container
# COPY entrypoint.sh /entrypoint.sh
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
