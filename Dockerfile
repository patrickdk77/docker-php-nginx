ARG BUILD_FROM=alpine:3.12
#ARG BUILD_FROM=alpine:3.9
ARG BUILD_FROM_PREFIX
#FROM ${BUILD_FROM_PREFIX}${BUILD_FROM}
FROM ${BUILD_FROM}

#ARG BUILD_ARCH
#ARG QEMU_ARCH
#COPY .gitignore qemu-${QEMU_ARCH}-static* /usr/bin/
COPY .gitignore /usr/bin/

# Install packages
ARG BUILD_FROM
ARG BUILD_PHP=php7
RUN grep www-data /etc/group || addgroup -g 82 -S www-data \
 && adduser -u 82 -D -S -G www-data www-data \
 && apk --no-cache add ${BUILD_PHP} ${BUILD_PHP}-fpm ${BUILD_PHP}-opcache ${BUILD_PHP}-mysqli ${BUILD_PHP}-json ${BUILD_PHP}-openssl ${BUILD_PHP}-curl \
    ${BUILD_PHP}-zlib ${BUILD_PHP}-xml ${BUILD_PHP}-phar ${BUILD_PHP}-intl ${BUILD_PHP}-dom ${BUILD_PHP}-xmlreader ${BUILD_PHP}-ctype ${BUILD_PHP}-session \
    ${BUILD_PHP}-ftp ${BUILD_PHP}-mcrypt ${BUILD_PHP}-xmlrpc ${BUILD_PHP}-exif ${BUILD_PHP}-tidy ${BUILD_PHP}-mbstring ${BUILD_PHP}-sqlite3 \
    ${BUILD_PHP}-iconv ${BUILD_PHP}-pdo_mysql ${BUILD_PHP}-pdo_sqlite ${BUILD_PHP}-xmlwriter ${BUILD_PHP}-simplexml ${BUILD_PHP}-gmp ${BUILD_PHP}-apcu \
    ${BUILD_PHP}-bcmath ${BUILD_PHP}-pecl-lzf ${BUILD_PHP}-gettext ${BUILD_PHP}-gd ${BUILD_PHP}-zip zip unzip sed \
    nginx supervisor ca-certificates curl gettext bash tzdata ssmtp mailx \
# && if [ $(echo ${BUILD_FROM} | cut -d . -f2) -gt 9 ]; then \
#      apk --no-cache add ${BUILD_PHP}-brotli \
# &&   printf '\nbrotli.output_compression=1\nbrotli.output_compression_level=5\n' >> /etc/${BUILD_PHP}/conf.d/brotli.ini; \
#    fi \
# && if [ $(echo ${BUILD_FROM} | cut -d . -f2) -gt 12 ]; then \
#      apk --no-cache add nginx-mod-http-brotli; \
#    fi \
 && rm -rf /var/cache/apk/* \
 && sed -i -e 's/expose_php = On/expose_php = Off/g' -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/${BUILD_PHP}/php.ini \
 && printf '[Date]\n\
date.timezone="UTC"\n\
' > /etc/${BUILD_PHP}/conf.d/custom.ini \
 && printf '\n\
[global]\n\
error_log = /dev/stderr\n\
\n\
[www]\n\
listen = localhost:9000\n\
user = www-data\n\
group = www-data\n\
pm.status_path = /fpm-status\n\
pm = ondemand\n\
pm.max_children = 20\n\
pm.process_idle_timeout = 10s;\n\
pm.max_requests = 100\n\
clear_env = no\n\
catch_workers_output = yes\n\
ping.path = /fpm-ping\n\
\n\
php_flag[display_errors] = off\n\
php_admin_value[memory_limit] = 256M\n\
php_value[session.sid_length] = 64\n\
php_value[session.sid_bits_per_character] = 5\n\
php_value[session.cookie_httponly] = on\n\
php_value[session.gc_maxlifetime] = 14400\n\
php_value[expose_php] = off\n\
\n\
php_admin_value[upload_max_filesize] = 64M\n\
php_admin_value[post_max_size] = 96M\n\
php_admin_value[output_buffering] = 0\n\
php_admin_value[openssl.cafile] = /etc/ssl/certs/ca-certificates.crt\n\
php_admin_value[openssl.capath] = /etc/ssl/certs\n\
php_admin_value[max_input_nesting_level] = 256\n\
php_admin_value[max_input_vars] = 10000\n\
' > /etc/${BUILD_PHP}/php-fpm.d/www.ini \
 && sed -i 's|^root|#root|' /etc/ssmtp/ssmtp.conf \
 && ln -s /usr/sbin/ssmtp /usr/lib/sendmail \
 && echo ""

COPY rootfs/ /

RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf \
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
