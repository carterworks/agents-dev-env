#!/bin/bash
set -e

IMAGE_NAME="agents-dev-env"
TAG="${1:-latest}"

echo "Building ${IMAGE_NAME}:${TAG}..."
docker build -t "${IMAGE_NAME}:${TAG}" .

echo ""
echo "Build complete! Run with:"
echo "  docker run -it --rm ${IMAGE_NAME}:${TAG}"
echo ""
echo "Or mount a workspace:"
echo "  docker run -it --rm -v \$(pwd):/workspace ${IMAGE_NAME}:${TAG}"
