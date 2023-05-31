# Docker

All My Docker Images are in branches, depending on the PHP.

# Guid

## Add in Host

127.0.0.1 branch.local

## SSL Certificate

mkdir ssl-certificate && cd ssl-certificate && openssl req -x509 -new -out mycert.crt -keyout mycert.key -days 365 -newkey rsa:4096 -sha256 -nodes

- Note: Commun Name is the host name (ex. branch.local)

## Confirm in docker-compose file
Project name
Available ports

## Run

cd ..
docker-compose up
