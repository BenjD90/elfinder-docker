FROM alpine:3.10.3

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd nginx supervisor curl

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ARG USER_ID=1000
ARG GROUP_ID=1000

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R 1000:1000 /run && \
  chown -R 1000:1000 /var/lib/nginx && \
  chown -R 1000:1000 /var/tmp/nginx && \
  chown -R 1000:1000 /var/log/nginx

# Setup document root
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN wget https://github.com/Studio-42/elFinder/archive/2.1.50.zip && \
    unzip *.zip && \
    rm *.zip

RUN mv elFinder-* elFinder && \
    rm elFinder/php/connector.minimal.php-dist && \
    rm -rf elFinder/files && \
    ln -s /data ./elFinder/files && \
    mv elFinder/* . && \
    rm -rf elFinder && \
    ln -s /config/index.html index.html && \
    ln -s /config/connector.php php/connector.minimal.php 

RUN mkdir /data && \
    chown -R 1000:1000 /var/log/nginx
VOLUME /data

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=1000 config/connector.php /config/connector.php
COPY --chown=1000 config/index.html /var/www/html/index.html

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

