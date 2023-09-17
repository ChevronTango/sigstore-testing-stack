mkdir fulcio-secrets -p

FULCIO_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')

echo $FULCIO_PASSWORD > fulcio-secrets/password.txt

openssl req \
-passout pass:$FULCIO_PASSWORD \
-nodes \
-newkey rsa:2048 \
-keyout fulcio-secrets/int.key \
-out fulcio-secrets/int.csr \
-config fulcio-secrets/fulcio.conf \
-extensions v3_ca

openssl x509 -signkey fulcio-secrets/int.key -in fulcio-secrets/int.csr -req -days 365 -out fulcio-secrets/int.crt -extensions v3_ca -extfile fulcio-secrets/fulcio.conf

# openssl x509 -text -noout -in fulcio-secrets/int.crt


# openssl pkcs12 -inkey fulcio-secrets/int.key -in fulcio-secrets/int.crt -export -out fulcio-secrets/int.p12 -passout pass:$FULCIO_PASSWORD

# openssl pkcs12 -in fulcio-secrets/int.p12 -noout -info -passin pass:$FULCIO_PASSWORD






# openssl req \
# -passout pass:$FULCIO_PASSWORD \
# -nodes \
# -newkey rsa:2048 \
# -keyout fulcio-secrets/ca.key \
# -out fulcio-secrets/ca.csr \
# -config fulcio-secrets/fulcio2.cnf \
# -extensions v3_ca

# openssl x509 -signkey fulcio-secrets/ca.key -in fulcio-secrets/ca.csr -req -days 365 -out fulcio-secrets/ca.crt -copy_extensions copyall


# openssl req \
# -passout pass:$FULCIO_PASSWORD \
# -nodes \
# -newkey rsa:2048 \
# -keyout fulcio-secrets/int.key \
# -out fulcio-secrets/int.csr \
# -config fulcio-secrets/fulcio3.cnf \
# -extensions v3_intermediate_ca

# openssl x509 -signkey fulcio-secrets/int.key -in fulcio-secrets/int.csr -req -days 365 -out fulcio-secrets/int.crt -copy_extensions copyall