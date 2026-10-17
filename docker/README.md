# Docker Instructions

This directory contains the Docker configuration for the customized nginx image used in this project.

The image is based on the official nginx Alpine image and includes a static file named hello.txt. The file can be accessed through the /hello.txt path and returns:

Hello from Amazon EKS!

## Files

```text
docker/
├── Dockerfile
├── hello.txt
└── README.md
```

## Build

Run from the docker directory:

```bash
docker build -t web-demo:local .
```

## Run

```bash
docker run -d --name web-demo-local -p 8080:80 web-demo:local
```

## Verify

Check the running container:

```bash
docker ps
```

Test the required endpoint:

```bash
curl http://localhost:8080/hello.txt
```

Expected output:

```text
Hello SRE!
```

Browser:

[http://localhost:8080/hello.txt](http://localhost:8080/hello.txt)

## Logs

```bash
docker logs web-demo-local
```

## Stop

```bash
docker stop web-demo-local
```

## Remove Container

```bash
docker rm web-demo-local
```

## Remove Image

```bash
docker rmi web-demo:local
```

## Port Mapping

```text
Local port 8080
→ Container port 80
→ nginx
```

## Current Flow

```text
Dockerfile + hello.txt
→ Docker Image
→ Container
→ localhost:8080/hello.txt
→ Hello from Amazon EKS!
```
