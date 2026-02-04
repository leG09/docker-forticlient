#!/usr/bin/env bash

DIRNAME=$(realpath "$0" | rev | cut -d'/' -f2- | rev)
readonly DIRNAME

if ! command -v yq &> /dev/null
then
    echo "Please install 'yq' in your operation system"
    exit 1
fi

prefix_image_forti="poyaz/forticlient"
prefix_image_ssh="poyaz/forticlient-ssh"
platforms="${PLATFORMS:-linux/amd64,linux/arm64}"

if ! docker buildx version >/dev/null 2>&1; then
    echo "docker buildx is required for multi-arch builds. Please enable buildx."
    exit 1
fi

forti_version=$(yq -r '.version.forticlient' .config.yaml)
ssh_version=$(yq -r '.version.ssh' .config.yaml)

cd "${DIRNAME}/docker/images/forticlient" || exit 1
docker buildx build \
  --platform "${platforms}" \
  -t "${prefix_image_forti}:${forti_version}" \
  -t "${prefix_image_forti}:latest" \
  --push \
  .

cd "${DIRNAME}/docker/images/ssh" || exit 1
docker buildx build \
  --platform "${platforms}" \
  -t "${prefix_image_ssh}:${ssh_version}" \
  -t "${prefix_image_ssh}:latest" \
  --push \
  .
