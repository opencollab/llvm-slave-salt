#!/bin/bash
mkdir /srv/obs/certs
openssl genrsa -out /srv/obs/certs/server.key 1024
openssl req -new -key /srv/obs/certs/server.key \
	         -out /srv/obs/certs/server.csr
openssl x509 -req -days 365 -in /srv/obs/certs/server.csr \
	     -signkey /srv/obs/certs/server.key \
	     -out /srv/obs/certs/server.crt

cat /srv/obs/certs/server.key /srv/obs/certs/server.crt \
	      > /srv/obs/certs/server.pem
cp /srv/obs/certs/server.pem /etc/ssl/certs/
c_rehash /etc/ssl/certs/
