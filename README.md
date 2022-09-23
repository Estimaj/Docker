# Docker

All My Docker Images are in branches, depending on the PHP.

# Guid

## Host

127.0.0.1 enovo-branch.local

## SSL Certificate

mkdir ssl-certificate
cd ssl-certificate
openssl req -x509 -new -out mycert.crt -keyout mycert.key -days 365 -newkey rsa:4096 -sha256 -nodes

- Note: Commun Name is the host name (ex. enovo-branch.local)
