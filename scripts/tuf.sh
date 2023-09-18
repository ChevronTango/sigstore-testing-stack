#!/bin/bash
if [ ! -f /etc/tuf/repository/targets.json ]; then
cd /etc/tuf

tuf init

cp /etc/ctfe/pubkey.pem ./staged/targets/ctfe.pub
cp /etc/fulcio/ca.crt ./staged/targets/fulcio.crt.pem
cp /etc/fulcio/ca.crt ./staged/targets/fulcio_v1.crt.pem
cp /etc/fulcio/ca.crt ./staged/targets/fulcio_intermediate_v1.crt.pem
cp /etc/rekor/ca.crt ./staged/targets/rekor.pub

tuf gen-key root
tuf gen-key targets
tuf gen-key snapshot
tuf gen-key timestamp

tuf sign root.json

CTFE_DOMAIN=$(printf $URL_PATTERN 6962)
REKOR_DOMAIN=$(printf $URL_PATTERN 3000)
FULCIO_DOMAIN=$(printf $URL_PATTERN 5555)

tuf add --custom="$(jq -n --arg domain $CTFE_DOMAIN '{sigstrore:{status:"Active",uri:$domain,usage:"CTFE"}}')" ctfe.pub
tuf add --custom="$(jq -n --arg domain $REKOR_DOMAIN '{sigstrore:{status:"Active",uri:$domain,usage:"Rekor"}}')" rekor.pub
tuf add --custom="$(jq -n --arg domain $FULCIO_DOMAIN '{sigstrore:{status:"Active",uri:$domain,usage:"Fulcio"}}')" fulcio.crt.pem
tuf add --custom="$(jq -n --arg domain $FULCIO_DOMAIN '{sigstrore:{status:"Active",uri:$domain,usage:"Fulcio"}}')" fulcio_v1.crt.pem
tuf add --custom="$(jq -n --arg domain $FULCIO_DOMAIN '{sigstrore:{status:"Active",uri:$domain,usage:"Fulcio"}}')" fulcio_intermediate_v1.crt.pem

tuf snapshot
tuf timestamp
tuf commit

fi
