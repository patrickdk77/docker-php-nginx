ARG BUILD_FROM=alpine:3.11
ARG BUILD_FROM_PREFIX
FROM ${BUILD_FROM_PREFIX}${BUILD_FROM}
LABEL Maintainer="Patrick Domack" \
      ForkedFrom="Tim de Pater <code@trafex.nl>" \
      Description="Lightweight container with Nginx & PHP-FPM based on Alpine Linux."

ARG ARCH
ARG QEMU_ARCH
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION
COPY .gitignore qemu-${QEMU_ARCH}-static* /usr/bin/

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-sqlite3 php7-pdo_mysql php7-pdo_sqlite php7-opcache nginx supervisor curl

COPY etc /etc/

RUN rm /etc/nginx/conf.d/default.conf \
 && mkdir -p /var/www/html \
 && chown -R www-data.www-data /var/www/html \
 && mkdir -p /var/tmp/nginx \
 && chown -R www-data.www-data /var/tmp/nginx

# Make the document root a volume
VOLUME /var/www/html

# Add application
WORKDIR /var/www/html
COPY --chown=www-data src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
