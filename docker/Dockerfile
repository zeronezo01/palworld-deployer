FROM ubuntu:20.04
MAINTAINER zeronezo01 zeronezo01@163.com

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Asia/Shanghai"

# init os environment
RUN apt update && apt install -y software-properties-common cron locales \
    && sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && locale-gen \ 
    && add-apt-repository multiverse && dpkg --add-architecture i386 && apt update \
    && echo steamcmd steam/question select "I AGREE" | debconf-set-selections \
    && apt install -y steamcmd

# create steam user
RUN useradd -m -s /bin/bash steam

ENV HOME=/home/steam

USER steam

# install palworld server & related packages
RUN  mkdir -p $HOME/.steam/sdk64 \
    && /usr/games/steamcmd +login anonymous +app_update 1007 +quit \
    && cp $HOME/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so $HOME/.steam/sdk64 \
    && rm -rf $HOME/Steam
RUN /usr/games/steamcmd +login anonymous +app_update 2394010 validate +quit 
RUN mkdir -p $HOME/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer

WORKDIR $HOME/Steam/steamapps/common/PalServer

USER root

VOLUME /backup
EXPOSE 8211/udp

# backup save data & settings every hour
COPY palworld-backup /etc/cron.hourly
RUN chmod +x /etc/cron.hourly/palworld-backup

CMD cron && su steam -c ./PalServer.sh
