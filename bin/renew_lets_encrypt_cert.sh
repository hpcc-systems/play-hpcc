#!/usr/bin/env bash

# Abort on any error
set -e

#----------

PRIV_KEY=key.pem
PUB_KEY=public.key.pub
CERT=certificate.pem

#----------

cd /home/hpcc/certificate

sudo cp /etc/letsencrypt/live/hpcc-code-day.eastus.cloudapp.azure.com/privkey.pem ${PRIV_KEY}
sudo chown hpcc:hpcc ${PRIV_KEY}
sudo chmod 600 ${PRIV_KEY}

sudo cp /etc/letsencrypt/live/hpcc-code-day.eastus.cloudapp.azure.com/cert.pem ${CERT}
sudo chown hpcc:hpcc ${CERT}
sudo chmod 644 ${CERT}

sudo -u hpcc openssl rsa -in key.pem -pubout > ${PUB_KEY}
sudo chmod 644 ${PUB_KEY}

