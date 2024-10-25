#!/bin/bash
#####################
# author: Ethan
# email: lipaysamart@gmail.com
# Description: Generate self-signed certificate.
# example：bash selfhost-ca-certificate.sh docker.local
#####################

set -e

DOMAIN="$1"
WORK_DIR="$(mktemp -d)"

if [ -z "$DOMAIN" ]; then
  echo "Domain name needed."
  exit 1
fi

echo "Temporary working dir is $WORK_DIR "
echo "Gernerating cert for $DOMAIN ..."

#
# Fix the following error:
# --------------------------
# Cannot write random bytes:
# 139695180550592:error:24070079:random number generator:RAND_write_file:Cannot open file:../crypto/rand/randfile.c:213:Filename=/home/eliu/.rnd
#
[ -f $HOME/.rnd ] || dd if=/dev/urandom of=$HOME/.rnd bs=256 count=1

openssl genrsa -out $WORK_DIR/ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$DOMAIN" \
  -key $WORK_DIR/ca.key \
  -out $WORK_DIR/ca.crt

openssl genrsa -out $WORK_DIR/server.key 4096

openssl req -sha512 -new \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$DOMAIN" \
  -key $WORK_DIR/server.key \
  -out $WORK_DIR/server.csr

cat > $WORK_DIR/v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$DOMAIN
DNS.2=*.$DOMAIN
EOF

openssl x509 -req -sha512 -days 3650 \
  -extfile $WORK_DIR/v3.ext \
  -CA $WORK_DIR/ca.crt -CAkey $WORK_DIR/ca.key -CAcreateserial \
  -in $WORK_DIR/server.csr \
  -out $WORK_DIR/server.crt

openssl x509 -inform PEM -in $WORK_DIR/server.crt -out $WORK_DIR/$DOMAIN.cert

mkdir -p ./$DOMAIN
cp $WORK_DIR/server.key $WORK_DIR/server.crt ./$DOMAIN

