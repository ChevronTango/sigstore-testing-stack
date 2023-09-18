#!/bin/bash

########## FULCIO ############
if [ ! -f /ect/fulcio/password.txt ]; then
# Generate A password to encrypt the certificate key with
FULCIO_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $FULCIO_PASSWORD > /ect/fulcio/password.txt

# generate a key and csr to use for fulcio signing
openssl req \
-passout pass:$FULCIO_PASSWORD \
-nodes \
-newkey rsa:2048 \
-keyout /ect/fulcio/ca.key \
-out /ect/fulcio/ca.csr \
-config /root/fulcio/fulcio.conf \
-extensions v3_ca

chmod 7777 /ect/fulcio/ca.key

# self sign the csr
openssl x509 -signkey /ect/fulcio/ca.key -in /ect/fulcio/ca.csr -req -days 365 -out /ect/fulcio/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf

# update the fulcio config to use our dex issuer
sed "s@http://localhost:5556@$(printf "$URL_PATTERN" "5556")@" /root/fulcio/config.json > /ect/fulcio/config.json

fi



########## DEX ###############
if [ ! -f /ect/dex/config.yaml ]; then

# Update the dex config to use our issuer
sed "s@issuer:.*@issuer: $(printf "$URL_PATTERN" "5556")@" /root/dex/config.yaml  > /ect/dex/config.yaml

fi



########## REKOR #############
if [ ! -f /etc/rekor/password.txt ]; then
# Generate A password to encrypt the certificate with
REKOR_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $REKOR_PASSWORD > /etc/rekor/password.txt

# generate a key and csr to use for fulcio signing
openssl req \
-passout pass:$REKOR_PASSWORD \
-nodes \
-newkey rsa:2048 \
-keyout /etc/rekor/ca.key \
-out /etc/rekor/ca.csr \
-config /root/fulcio/fulcio.conf \
-extensions v3_ca

chmod 7777 /etc/rekor/ca.key

# self sign the csr
openssl x509 -signkey /etc/rekor/ca.key -in /etc/rekor/ca.csr -req -days 365 -out /etc/rekor/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf

fi


########## CTFE ##############
if [ ! -f /etc/ctfe/password.txt ]; then
# Generate A password to encrypt the keys with
CTFE_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $CTFE_PASSWORD > /etc/ctfe/password.txt

# Copy the fulcio root secret to the output
cp /ect/fulcio/ca.crt /etc/ctfe/root.pem

# generate an EC key for use by the CT Log
openssl ecparam -name prime256v1 -genkey -noout | \
openssl ec -out /etc/ctfe/privkey.pem -aes256 -passout pass:$CTFE_PASSWORD

chmod 7777 /etc/ctfe/privkey.pem

# Generate the public key from the private
openssl ec -passin pass:$CTFE_PASSWORD -in /etc/ctfe/privkey.pem -pubout -out /etc/ctfe/pubkey.pem

fi
