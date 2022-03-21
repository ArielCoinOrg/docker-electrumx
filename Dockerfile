ARG VERSION=master

FROM python:3.7-alpine3.11
LABEL maintainer="Luke Childs <lukechilds123@gmail.com>"

ARG VERSION

COPY ./bin /usr/local/bin

RUN apk update && apk upgrade


RUN chmod a+x /usr/local/bin/* && \
    apk add --no-cache git build-base openssl gcc && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main leveldb-dev && \
    pip install aiohttp pylru plyvel websockets python-rocksdb uvloop kawpow && \
    git clone -b $VERSION https://github.com/ArielCoinOrg/electrumx-arielcoin.git electrumx && \
    cd electrumx && \
    python setup.py install && \
    apk del git build-base && \
    rm -rf /tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV ALLOW_ROOT 1
ENV EVENT_LOOP_POLICY uvloop
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50011,ssl://:50012,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key
ENV HOST ""
WORKDIR /data

EXPOSE 50011 50012 50004 8000

CMD ["init"]
