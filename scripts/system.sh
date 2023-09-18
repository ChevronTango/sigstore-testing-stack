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

chmod 7777 /var/run/fulcio-secrets/ca.key

# self sign the csr
openssl x509 -signkey /var/run/fulcio-secrets/ca.key -in /var/run/fulcio-secrets/ca.csr -req -days 365 -out /var/run/fulcio-secrets/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf

# update the fulcio config to use our dex issuer
sed "s@http://localhost:5556@$(printf "$URL_PATTERN" "5556")@" /root/fulcio/config.json > /var/run/fulcio-secrets/config.json




########## DEX ###############

# Update the dex config to use our issuer
sed "s@issuer:.*@issuer: $(printf "$URL_PATTERN" "5556")@" /root/dex/config.yaml  > /var/run/dex/config.yaml




########## REKOR #############
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



########## CTFE ##############
# Generate A password to encrypt the keys with
CTFE_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $CTFE_PASSWORD > /etc/ctfe/password.txt

# Copy the fulcio root secret to the output
cp /var/run/fulcio-secrets/ca.crt /etc/ctfe/root.pem

# generate an EC key for use by the CT Log
openssl ecparam -name prime256v1 -genkey -noout | \
openssl ec -out /etc/ctfe/privkey.pem -aes256 -passout pass:$CTFE_PASSWORD

chmod 7777 /etc/ctfe/privkey.pem

# Generate the public key from the private
openssl ec -passin pass:$CTFE_PASSWORD -in /etc/ctfe/privkey.pem -pubout -out /etc/ctfe/pubkey.pem
