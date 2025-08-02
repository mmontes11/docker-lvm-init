FROM ubuntu:24.04

RUN apt update && apt install -y lvm2

COPY lvm.conf /etc/lvm/lvm.conf
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]