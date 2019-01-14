FROM debian
MAINTAINER loblab

ARG USER=loblab
ARG UID=1000
ARG HOME=/noip-renew
#ARG TZ=Asia/Shanghai
#ARG APT_MIRROR=mirrors.163.com
ARG DEBIAN_FRONTED=noninteractive
ARG PYTHON=python3

#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN sed -i "s/deb.debian.org/$APT_MIRROR/" /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install chromedriver
RUN apt-get -y install ${PYTHON}-pip
RUN $PYTHON -m pip install selenium
RUN apt-get -y install curl wget

RUN useradd -d $HOME -u $UID $USER
USER $USER
WORKDIR $HOME
CMD ["bash"]

