#!/bin/bash

#
# Copyright (C) 2026 tebbi
# SPDX-License-Identifier: GPL-3.0-or-later
#

set -e

images=()
repobase="${REPOBASE:-ghcr.io/tebbiworld}"
reponame="minecraft"

# itzg/minecraft-server: the de-facto standard Minecraft server image (Java
# 25 variant), pinned. Exposed to the unit as ${MINECRAFT_SERVER_IMAGE} through
# the org.nethserver.images label. The image downloads the requested server
# flavour/version (Vanilla, Paper, Fabric, ...) into /data at start and is
# configured entirely through environment variables.
minecraft_image="docker.io/itzg/minecraft-server:2026.9.1-java25"

runtime_images=(
    "${minecraft_image}"
)

container=$(buildah from scratch)

if ! buildah containers --format "{{.ContainerName}}" | grep -q nodebuilder-minecraft; then
    echo "Pulling NodeJS runtime..."
    buildah from --name nodebuilder-minecraft -v "${PWD}:/usr/src:Z" docker.io/library/node:24.16.0-slim
fi

echo "Build static UI files with node..."
buildah run \
    --workingdir=/usr/src/ui \
    --env="NODE_OPTIONS=--openssl-legacy-provider" \
    nodebuilder-minecraft \
    sh -c "yarn install && yarn build"

buildah add "${container}" imageroot /imageroot
buildah add "${container}" ui/dist /ui
# node:fwadm: the game port(s) are opened on the node firewall as a public
# service named after the instance. No Traefik route (raw TCP/UDP game
# protocol), no core port allocation: the ports are chosen in the settings.
buildah config --entrypoint=/ \
    --label="org.nethserver.authorizations=node:fwadm" \
    --label="org.nethserver.rootfull=0" \
    --label="org.nethserver.images=${runtime_images[*]}" \
    "${container}"
buildah commit "${container}" "${repobase}/${reponame}"

images+=("${repobase}/${reponame}")

if [[ -n "${CI}" ]]; then
    printf "images=%s\n" "${images[*],,}" >> "${GITHUB_OUTPUT}"
else
    printf "Publish the images with:\n\n"
    for image in "${images[@],,}"; do printf "  buildah push %s docker://%s:%s\n" "${image}" "${image}" "${IMAGETAG:-latest}" ; done
    printf "\n"
fi
