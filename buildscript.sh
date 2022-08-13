#!/bin/bash
docker buildx build -t docker.io/dennis1804d/notes:latest -f ./Dockerfile --push --platform=linux/arm64,linux/amd64 .