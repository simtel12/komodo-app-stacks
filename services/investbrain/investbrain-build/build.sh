#!/bin/bash
set -e

IMAGE_NAME="ghcr.io/simtel12/investbrain:latest"

echo "Building and pushing Docker image with buildx: $IMAGE_NAME"
docker buildx build --push --platform linux/amd64,linux/arm64 -t "$IMAGE_NAME" -f Dockerfile .

echo "Successfully built and pushed $IMAGE_NAME"
