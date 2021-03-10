ARG BUILD_FROM=alpine:3.12
#ARG BUILD_FROM=alpine:3.9
ARG BUILD_FROM_PREFIX
FROM ${BUILD_FROM_PREFIX}${BUILD_FROM}

ARG BUILD_ARCH
ARG QEMU_ARCH
COPY .gitignore qemu-${QEMU_ARCH}-static* /usr/bin/

# Install packages
RUN addgroup -g 82 -S www-data \
 && adduser -u 82 -D -S -G www-data www-data \
 && apk --no-cache add php7 php7-fpm php7-opcache php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-ftp php7-mcrypt php7-pecl-mcrypt php7-xmlrpc php7-exif php7-tidy php7-mbstring php7-sqlite3 \
    php7-iconv php7-pdo_mysql php7-pdo_sqlite php7-xmlwriter php7-simplexml php7-gmp php7-ctype php7-apcu \
    php7-bcmath php7-pecl-lzf php7-gettext php-gd gmp-dev freetype-dev libjpeg-turbo-dev zip unzip sed \
    nginx supervisor ca-certificates libmcrypt-dev zlib-dev gmp-dev libpng-dev curl gettext bash tzdata \
 && rm -rf /var/cache/apk/* \
 && sed -i -e 's/expose_php = On/expose_php = Off/g' -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini \
 && echo ""

COPY rootfs/ /

RUN rm /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf \
 && mkdir -p /var/www/html \
 && chown -R www-data.www-data /var/www/html \
 && mkdir -p /var/tmp/nginx \
 && chown -R www-data.www-data /var/tmp/nginx \
 && chmod a+x /usr/local/bin/*

# Add application
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://localhost:80/fpm-ping

ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

LABEL maintainer="Patrick Domack (patrickdk@patrickdk.com)" \
  ForkedFrom="Tim de Pater <code@trafex.nl>" \
  Description="Lightweight container with Nginx & PHP-FPM based on Alpine Linux." \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="docker-php-nginx" \
  org.label-schema.description="Nginx PHP alpine base image" \
  org.label-schema.url="https://github.com/patrickdk77/docker-php-nginx/" \
  org.label-schema.usage="https://github.com/patrickdk77/docker-php-nginx/tree/master/README.md" \
  org.label-schema.vcs-url="https://github.com/patrickdk77/docker-php-nginx" \
  org.label-schema.vcs-ref="${BUILD_REF}" \
  org.label-schema.version="${BUILD_VERSION}"
