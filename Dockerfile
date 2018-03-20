FROM alpine:3.6

MAINTAINER AndrewAI <yongchanlong@gmail.com>

RUN set -ex && { \
        echo 'http://mirrors.aliyun.com/alpine/v3.6/main'; \
        echo 'http://mirrors.aliyun.com/alpine/v3.6/community'; \
    } > /etc/apk/repositories \
    && apk update && apk add bash nfs-utils && rm -rf /var/cache/apk/*

EXPOSE 111 111/udp 2049 2049/udp \
    32765 32765/udp 32766 32766/udp 32767 32767/udp 32768 32768/udp
WORKDIR /sotrage/docker-nfs-server
RUN echo "/storage *(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)" > /storage/docker-nfs-server/exports && \
    rm /etc/exports && \
    ln -s /storage/docker-nfs-server/exports /etc/exports
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
