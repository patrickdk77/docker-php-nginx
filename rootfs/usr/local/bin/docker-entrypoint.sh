#!/bin/bash

: "${NGINX_WORKER_CONNECTIONS:=200}" \
  "${NGINX_WORKER_PROCESSES:=1}" \
  "${NGINX_KEEPALIVE_TIMEOUT:=15}" \
  "${NGINX_PROXY_TIMEOUT:=330}" \

if [ ! -e /etc/nginx/nginx.conf ]; then
  envsubst < /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
fi

exec "$@"
