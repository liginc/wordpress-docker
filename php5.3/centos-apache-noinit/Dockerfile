FROM centos:6

ENV YUM_INSTALL_PKGS "ca-certificates httpd-2.2.15 php-5.3.3 php-mbstring php-gd php-pdo php-mysql php-xml"

RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install $YUM_INSTALL_PKGS && \
    yum clean all

RUN update-ca-trust

# logs should go to stdout / stderr
RUN ln -sfT /dev/stderr "/var/log/httpd/error.log" \
	&& ln -sfT /dev/stdout "/var/log/httpd/access.log"

COPY httpd.conf /etc/httpd/conf/httpd.conf

# Simple startup script to avoid some issues observed with container restart
COPY run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

RUN curl -sSL -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

EXPOSE 80
VOLUME /var/www/html
WORKDIR /var/www/html

CMD ["/run-httpd.sh"]
