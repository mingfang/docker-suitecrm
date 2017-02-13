FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc
RUN echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

#Required
RUN apt-get install -y cron nginx php-fpm php-xml php-mbstring php-mysql php-mcrypt php-intl php-zip php-imap php-curl php-gd

RUN wget -O - https://github.com/salesagility/SuiteCRM/archive/v7.8.1.tar.gz | tar zx -C /var/www/html --strip-components=1 --exclude='SuiteCRM-7.8.1/test*' && \
    cd /var/www/html && \
    chown -R www-data:www-data /var/www/html

COPY default /etc/nginx/sites-enabled/
COPY crontab /

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
