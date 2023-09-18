#!/bin/bash

########## FULCIO ############
if [ ! -f /etc/fulcio/password.txt ]; then
# Generate A password to encrypt the certificate key with
FULCIO_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $FULCIO_PASSWORD > /etc/fulcio/password.txt

# generate a key and csr to use for fulcio signing
openssl req \
-passout pass:$FULCIO_PASSWORD \
-nodes \
-newkey rsa:2048 \
-keyout /etc/fulcio/ca.key \
-out /etc/fulcio/ca.csr \
-config /root/fulcio/fulcio.conf \
-extensions v3_ca

chmod 7777 /etc/fulcio/ca.key

# self sign the csr
openssl x509 -signkey /etc/fulcio/ca.key -in /etc/fulcio/ca.csr -req -days 365 -out /etc/fulcio/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf

# update the fulcio config to use our dex issuer
sed "s@http://localhost:5556@$(printf "$URL_PATTERN" "5556")@" /root/fulcio/config.json > /etc/fulcio/config.json

fi



########## DEX ###############
if [ ! -f /etc/dex/config.yaml ]; then

# Update the dex config to use our issuer
sed "s@issuer:.*@issuer: $(printf "$URL_PATTERN" "5556")@" /root/dex/config.yaml  > /etc/dex/config.yaml

fi



########## REKOR #############
if [ ! -f /etc/rekor/password.txt ]; then
# Generate A password to encrypt the certificate with
REKOR_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $REKOR_PASSWORD > /etc/rekor/password.txt

# generate a key and csr to use for fulcio signing

# echo "key"
# openssl ecparam -name prime256v1 -genkey -out /etc/rekor/ec_key.pem

# chmod 7777 /etc/rekor/ec_key.pem

# echo "csr"
# openssl req -new -sha256 -key /etc/rekor/ec_key.pem -nodes -out /etc/rekor/ec.csr
# openssl req \
# -new \
# -sha256 \
# -passout pass:$FULCIO_PASSWORD \
# -nodes \
# -key /etc/rekor/ec_key.pem \
# -out /etc/rekor/ec.csr \
# -config /root/fulcio/fulcio.conf \
# -extensions v3_ca

# chmod 7777 /etc/rekor/ec.csr

# echo "cert"
# openssl x509 -signkey /etc/rekor/ec_key.pem -in /etc/rekor/ec.csr -req -days 365 -out /etc/rekor/cert.pem -extensions v3_ca -extfile /root/fulcio/fulcio.conf

# chmod 7777 /etc/rekor/cert.pem

# generate a key and csr to use for fulcio signing
# openssl req \
# -passout pass:$REKOR_PASSWORD \
# -nodes \
# -newkey ec \
# -keyout /etc/rekor/ca.key \
# -out /etc/rekor/ca.csr \
# -config /root/fulcio/fulcio.conf \
# -extensions v3_ca
# openssl ecparam -genkey -name prime256v1 -noout -out ec256-key-pair.pem

# openssl genpkey -genparam -algorithm ec -pkeyopt ec_paramgen_curve:P-384 -out ECPARAM.pem

openssl ecparam -genkey -name prime256v1 > /etc/rekor/key.pem
openssl pkcs8 -topk8 -in /etc/rekor/key.pem -nocrypt > /etc/rekor/cert.pem

# openssl ecparam -genkey -name secp384r1 -noout | openssl req -new -x509 -sha384 -nodes -days 365 -passout pass:$REKOR_PASSWORD -out /etc/rekor/ca.key -config /root/fulcio/fulcio.conf -extensions v3_ca

chmod 7777 /etc/rekor/cert.pem

# self sign the csr
# openssl x509 -signkey /etc/rekor/ca.key -in /etc/rekor/ca.csr -req -days 365 -out /etc/rekor/ca.crt -extensions v3_ca -extfile /root/fulcio/fulcio.conf


fi


########## CTFE ##############
if [ ! -f /etc/ctfe/password.txt ]; then
# Generate A password to encrypt the keys with
CTFE_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

# Write this password out to a file so it can be read by the docker-compose script
echo $CTFE_PASSWORD > /etc/ctfe/password.txt

# Copy the fulcio root secret to the output
cp /etc/fulcio/ca.crt /etc/ctfe/root.pem

# generate an EC key for use by the CT Log
openssl ecparam -name prime256v1 -genkey -noout | \
openssl ec -out /etc/ctfe/privkey.pem -aes256 -passout pass:$CTFE_PASSWORD

chmod 7777 /etc/ctfe/privkey.pem

# Generate the public key from the private
openssl ec -passin pass:$CTFE_PASSWORD -in /etc/ctfe/privkey.pem -pubout -out /etc/ctfe/pubkey.pem

fi
