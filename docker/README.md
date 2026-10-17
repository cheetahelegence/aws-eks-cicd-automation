# Docker Instructions

This directory contains the Docker configuration for the customized nginx image used in this project.

The image is based on the official nginx Alpine image and includes a static file named hello.txt. The file can be accessed through the /hello.txt path and returns:

Hello SRE!

## Files

docker/
├── Dockerfile
├── hello.txt
└── README.md

## Build

Run from the docker directory:

docker build -t web-demo:local .

## Run

docker run -d --name web-demo-local -p 8080:80 web-demo:local

## Verify

Check the running container:

docker ps

Test the required endpoint:

curl http://localhost:8080/hello.txt

Expected output:

Hello SRE!

Browser:

http://localhost:8080/hello.txt

## Logs

docker logs web-demo-local

## Stop

docker stop web-demo-local

## Remove Container

docker rm web-demo-local

## Remove Image

docker rmi web-demo:local

## Port Mapping

Local port 8080
→ Container port 80
→ nginx

## Current Flow

Dockerfile + hello.txt
→ Docker Image
→ Container
→ localhost:8080/hello.txt
→ Hello SRE!