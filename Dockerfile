FROM docker.io/paritytech/ci-linux:production as builder
LABEL description="Build stage"

WORKDIR /trappist
COPY . /trappist

RUN cargo build --release

# ===== SECOND STAGE ======

FROM docker.io/library/ubuntu:20.04
LABEL description="Trappist node"

COPY --from=builder /trappist/target/release/trappist /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /trappist trappist && \
    mkdir -p /trappist/.local/share && \
    mkdir /data && \
    chown -R trappist:trappist /data && \
    ln -s /data /trappist/.local/share/trappist && \
    rm -rf /usr/bin /usr/sbin

USER trappist
EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/trappist"]
