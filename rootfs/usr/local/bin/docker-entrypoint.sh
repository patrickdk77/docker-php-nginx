#!/bin/bash
set -a

: "${NGINX_WORKER_CONNECTIONS:=1000}" \
  "${NGINX_WORKER_PROCESSES:=auto}" \
  "${NGINX_KEEPALIVE_TIMEOUT:=15}" \
  "${NGINX_PROXY_TIMEOUT:=330}" \
  "${NGINX_GZIP:=on}" \
  "${NGINX_GZIP_STATIC:=off}" \
  "${NGINX_GZIP_VARY:=on}" \
  "${NGINX_GZIP_PROXIED:=any}" \
  "${NGINX_GZIP_TYPES:=text/plain application/xml text/css text/js text/xml application/x-javascript text/javascript application/json application/xml+rss}" \
  "${NGINX_SENDFILE:=on}" \
  "${NGINX_CLIENT_MAX_BODY_SIZE:=1m}" \
  "${NGINX_CLIENT_BODY_BUFFER_SIZE:=256k}" \
  "${NGINX_TCP_NODELAY:=off}" \
  "${NGINX_TCP_NOPUSH:=off}" \


if [ ! -e /etc/nginx/nginx.conf ]; then
  ENABLE_IPV4=0
  ENABLE_IPV6=0

  ping -4 -c 1 -q localhost
  if [ $? -eq 0 ]; then
    ENABLE_IPV4=1
  fi

  ping -6 -c 1 -q localhost
  if [ $? -eq 0 ]; then
    ENABLE_IPV6=1
  fi

  cat /etc/hosts > /etc/hosts.orig
  if [ $ENABLE_IPV4 -eq 1 ]; then
    sed -e '/^::.*localhost/d' /etc/hosts.orig > /etc/hosts
  else
    if [ $ENABLE_IPV6 -eq 1 ]; then
      sed -e '/^127.*localhost/d' /etc/hosts.orig > /etc/hosts
    fi
  fi

  envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf
fi

exec "$@"
