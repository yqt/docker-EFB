FROM alpine:edge
LABEL maintainer="Roy Xiang <developer@royxiang.me>, hackaday <hackaday@coz.moe>"

ENV LANG C.UTF-8

RUN apk add --update --no-cache ca-certificates git

RUN set -ex \
        && apk add --no-cache --virtual .run-deps \
                ffmpeg \
                libmagic \
                python3 \
                py3-certifi \
                py3-numpy \
                py3-pillow \
                py3-requests \
        && ln -sf "$(python3 -c 'import requests; print(requests.__path__[0])')/cacert.pem" \
                  "$(python3 -c 'import certifi; print(certifi.__path__[0])')/cacert.pem"

RUN set -ex \
        && rm -rf /opt/ehForwarderBot \
        && mkdir -p /opt/ehForwarderBot \
        && git clone https://github.com/blueset/ehForwarderBot.git /opt/ehForwarderBot \
        && mkdir -p /opt/ehForwarderBot/storage

RUN set -ex \
        && pip3 install -r /opt/ehForwarderBot/requirements.txt \
        && rm -rf /root/.cache

# add openssh and clean
RUN apk add --no-cache --update openssh

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
        && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
        && mkdir -p /var/run/sshd

RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

WORKDIR /opt/ehForwarderBot

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]