#!/bin/bash
echo "root:${PASSWORD}" | chpasswd
service ssh start
exec "$@"
