#!/bin/bash

# podman pull docker.io/jekyll/jekyll:stable

podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    --network=host -p 127.0.0.1:4000:4000 \
    jekyll/jekyll /bin/bash -c "bundle config set path 'vendor/bundle' && bundle exec jekyll serve"
