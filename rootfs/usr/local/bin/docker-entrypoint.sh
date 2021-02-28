#!/bin/bash
set -a

: "${NGINX_WORKER_CONNECTIONS:=200}" \
  "${NGINX_WORKER_PROCESSES:=1}" \
  "${NGINX_KEEPALIVE_TIMEOUT:=15}" \
  "${NGINX_PROXY_TIMEOUT:=330}" \
  "${NGINX_GZIP:=on}" \
  "${NGINX_GZIP_STATIC:=off}" \
  "${NGINX_GZIP_VARY:=on}" \
  "${NGINX_GZIP_PROXIED:=any}" \
  "${NGINX_GZIP_TYPES:=text/plain application/xml text/css text/js text/xml application/x-javascript text/javascript application/json application/xml+rss}" \
  "${NGINX_SENDFILE:=on}" \
  "${NGINX_CLIENT_MAX_BODY_SIZE:=1m}" \
  "${NGINX_TCP_NODELAY:=off}" \
  "${NGINX_TCP_NOPUSH:=off}" \
  "${NGINX_EXPIRES_CSS:=1h}" \
  "${NGINX_EXPIRES_JS:=1h}" \
  "${NGINX_EXPIRES_IMAGES:=1d}" \
  "${NGINX_LOG_NOTFOUND:=on}" \
  "${NGINX_LOG_NOTFOUND_CSS:=$NGINX_LOG_NOTFOUND}" \
  "${NGINX_LOG_NOTFOUND_JS:=$NGINX_LOG_NOTFOUND}" \
  "${NGINX_LOG_NOTFOUND_IMAGES:=$NGINX_LOG_NOTFOUND}" \
  "${NGINX_LOG_NOTFOUND_DOT:=$NGINX_LOG_NOTFOUND}" \
  "${NGINX_LOG_ACCESS:=on}" \
  "${NGINX_LOG_ACCESS_CSS:=$NGINX_LOG_ACCESS}" \
  "${NGINX_LOG_ACCESS_JS:=$NGINX_LOG_ACCESS}" \
  "${NGINX_LOG_ACCESS_IMAGES:=$NGINX_LOG_ACCESS}" \
  "${NGINX_LOG_ACCESS_DOT:=$NGINX_LOG_ACCESS}" \



if [ ! -e /etc/nginx/nginx.conf ]; then
  envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
fi

exec "$@"
