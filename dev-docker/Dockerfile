FROM jrei/systemd-ubuntu:20.04

user root

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install -y git make curl jq golang-go
