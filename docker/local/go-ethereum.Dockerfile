FROM ghcr.io/foundry-rs/foundry

RUN apk update ; apk add --no-cache --allow-untrusted ca-certificates curl bash git jq
RUN apk add --no-cache --upgrade grep
WORKDIR /root

ARG GENESIS_FILE_PATH=start-up-files/go-ethereum/genesis.json

COPY stateful ./stateful
ADD start-up-files/go-ethereum/start-private-network.sh .
ADD start-up-files/go-ethereum/deploy-local-network.sh .
ADD $GENESIS_FILE_PATH ./genesis.json
ADD helper-scripts/geth-linux-amd64 /bin/geth

RUN chmod +x /bin/geth


EXPOSE 8545
EXPOSE 8546
ENTRYPOINT ["./start-private-network.sh"]