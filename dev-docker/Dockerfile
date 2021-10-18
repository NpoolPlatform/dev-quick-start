FROM jrei/systemd-ubuntu:20.04

USER root
ARG ENV_ENVIRONMENT_TARGET
ARG ENV_CONSUL_HOST
ARG ENV_CONSUL_PORT
ARG PATH

COPY go1.16.5.tar.gz /go1.16.5.tar.gz
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install git make curl jq golang-go wget apt-utils vim net-tools sudo iputils-ping iproute2 openssh-server nfs-common dnsutils -y

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -i 's/$AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePam no/g' /etc/ssh/sshd_config
RUN echo root:12345679 | chpasswd

RUN tar xvf go1.16.5.tar.gz
RUN cd go-go1.16.5/src/ && ./all.bash
