#!/usr/bin/env sh
apk --no-cache add curl
sleep 10
curl --silent --fail http://app:80 | grep 'PHP '
