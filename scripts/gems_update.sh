#!/bin/bash

# podman pull docker.io/jekyll/jekyll:stable

podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    jekyll/jekyll /bin/bash -c "bundle config set path 'vendor/bundle' && bundle update"
