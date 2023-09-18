#!/bin/bash

########## FULCIO ############
# Generate A password to encrypt the certificate key with
FULCIO_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $FULCIO_PASSWORD > /var/run/fulcio-secrets/password.txt

# generate a key and csr to use for fulcio signing
openssl req \
-passout pass:$FULCIO_PASSWORD \
-nodes \
-newkey rsa:2048 \
-keyout /var/run/fulcio-secrets/ca.key \
-out /var/run/fulcio-secrets/ca.csr \
-config /root/fulcio/fulcio.conf \
-extensions v3_ca

# self sign the csr
openssl x509 -signkey /var/run/fulcio-secrets/ca.key -in /var/run/fulcio-secrets/ca.csr -req -days 365 -out /var/run/fulcio-secrets/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf

# update the fulcio config to use our dex issuer
sed "s@http://localhost:5556@$(printf "$URL_PATTERN" "5556")@" /root/fulcio/config.json > /var/run/fulcio-secrets/config.json

########## DEX ###############

# Update the dex config to use our issuer
sed "s@issuer:.*@issuer: $(printf "$URL_PATTERN" "5556")@" /root/dex/config.yaml  > /var/run/dex/config.yaml

########## REKOR #############


########## CTFE ##############

CTFE_PASSWORD="foobar"

cp /var/run/fulcio-secrets/ca.crt /etc/ctfe/root.pem

openssl ecparam -name prime256v1 -genkey -noout | \
openssl ec -out /etc/ctfe/privkey.pem -aes256 -passout pass:$CTFE_PASSWORD

openssl ec -passin pass:$CTFE_PASSWORD -in /etc/ctfe/privkey.pem -pubout -out /etc/ctfe/pubkey.pem

# openssl pkcs8 -topk8 -nocrypt -in ctfe-config/private.key -out ctfe-config/private
