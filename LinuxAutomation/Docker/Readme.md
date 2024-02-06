Install nginx on Ubuntu to serve static web content
===================================================

docker build -t myweb .

docker run -d -p 8000:80 --name web myweb

Open a web browser on the host and browse to https://localhost:8000

Cleaning up
===========

# Stop running container

docker rm -f web

#Prune all images

docker image prune -a -f