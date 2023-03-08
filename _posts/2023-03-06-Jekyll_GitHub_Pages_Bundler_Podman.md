---
layout: post
title: "Use Jekyll in a Podman container"
description: "Use Jekyll and Bundler form a Podman container. Bundler can also be used easily from a Ruby container."
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Jekyll", "GitHub Pages", "Podman", "Ruby" ]
---

This is a guide to use [Jekyll](https://jekyllrb.com/) in a [Podman](https://podman.io/) container.<!--more-->
At the end is a section about an **alternative** usage of [Bundler](https://bundler.io/), using the official [Ruby](https://www.ruby-lang.org/en/) container.

Article's content:

- [Jekyll](#jekyll)
- [Usage examples](#usage-examples)
  - [Create a new Jekyll site](#create-a-new-jekyll-site)
  - [Create a new GitHub Pages site](#create-a-new-github-pages-site)
  - [Update the gems](#update-the-gems)
  - [Build a site](#build-a-site)
  - [Run Jekyll in server mode](#run-jekyll-in-server-mode)
- [Bundler in a Ruby container](#bundler-in-a-ruby-container)

The code in this documentation was tested with:

- Ubuntu 22.04.2 LTS
- Podman 3.3.4
- docker.io/jekyll/jekyll:stable (jekyll/jekyll:4.2.2)
- docker.io/library/ruby:latest (ruby:3.2.1-bullseye)

## Jekyll

There are three `Jekyll` container types. I have used `jekyll/jekyll`, the default image. (see [Jekyll Docker on GitHub](https://github.com/envygeeks/jekyll-docker/blob/master/README.md) for more information).

Pull the container:

```sh
podman pull docker.io/jekyll/jekyll:stable
```

In the current stable version (4.2.2) of `Jekyll` container `BUNDLE_APP_CONFIG` is `/usr/local/bundle`.
According to Bundler's [Docs](https://bundler.io/docs.html) the local configuration settings are loaded from `<project_root>/.bundle/config` or `$BUNDLE_APP_CONFIG/config`. I am setting `BUNDLE_APP_CONFIG` to `.bundle` when starting the container to:

- persist the local configuration with the project
- keep the compatibility with cases when `BUNDLE_APP_CONFIG` is not set

To starting a Bash shell inside the container for various commands, keeping the compatibility, use:

```sh
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 -e BUNDLE_APP_CONFIG='.bundle' jekyll/jekyll /bin/bash
```

For information about `Jekyll` commands see [Command Line Usage](https://jekyllrb.com/docs/usage/) .

## Usage examples

### Create a new Jekyll site

Create a new Jekyll site in the `new_Jekyll_site` directory:

```sh
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    jekyll/jekyll jekyll new new_Jekyll_site
```

### Create a new GitHub Pages site

```sh
new_site_name="new_GitHub_Pages_site"

# this version avoids the implicit install executed by `bundle remove`
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    jekyll/jekyll \
    sh -c "jekyll new --skip-bundle $new_site_name && cd $new_site_name && \
        bundle config set --local path 'vendor/bundle' && \
        sed -i 's/^gem \"jekyll\"/#&/' Gemfile && \
        sed -i '/^group :jekyll_plugins/a \ \ gem \"github-pages\"' Gemfile && \
        bundle add webrick --skip-install && \
        bundle install"

# this is a standard, explicit, version
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    jekyll/jekyll \
    sh -c "jekyll new --skip-bundle $new_site_name && cd $new_site_name && \
        bundle config set --local path 'vendor/bundle' && \
        bundle remove jekyll && \
        bundle add webrick --skip-install && \
        bundle add github-pages --group jekyll_plugins"
```

**Note 1:** From [Creating a GitHub Pages site with Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll), the `github-pages` gem should be added with the version from [Dependency versions](https://pages.github.com/versions/) . Use:

```sh
# use this for the first version:
sed -i '/^group :jekyll_plugins/a \ \ gem \"github-pages\", \"~> 228\"' Gemfile && \

# and this for the second version:
bundle add github-pages --group jekyll_plugins --version '~> 228'
```

**Note 2:** without `webrick`, `bundle exec jekyll serve` will fail in current `Ruby` and `Bundler` versions.

### Update the gems

Execute in the directory with the `Gemfile` file:

```sh
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    jekyll/jekyll bundle update
```

### Build a site

Execute in the directory with the `Gemfile` file:

```sh
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    jekyll/jekyll bundle exec jekyll build
```

### Run Jekyll in server mode

Execute in the directory with the `Gemfile` file:

```sh
podman run --rm -it \
    -v "${PWD}:/srv/jekyll:Z" \
    -e JEKYLL_ROOTLESS=1 \
    -e BUNDLE_APP_CONFIG='.bundle' \
    --network=host -p 127.0.0.1:4000:4000 \
    jekyll/jekyll bundle exec jekyll serve
```

then open [http://localhost:4000/](http://localhost:4000/) in your browser.

Jekyll will watch for changes and rebuild the site, reload the page in your browser to see them.

**Note:** use `jekyll serve --livereload` to automatically refresh the page after each change.

## Bundler in a Ruby container

Pull the official `Ruby` container image:

```sh
podman pull docker.io/library/ruby:latest
```

then, from the directory with the `Gemfile` file, call it like this:

```sh
podman run --rm -it --userns=keep-id \
    -v "${PWD}":/app:Z -w /app \
    ruby:latest bundle desired_bundle_command
```

Replace `desired_bundle_command` with:

- install (see [bundle install](https://bundler.io/v2.4/man/bundle-install.1.html))
- update [--strict] (see [bundle update](https://bundler.io/v2.4/man/bundle-update.1.html))
- outdated [--strict] (see [bundle outdated](https://bundler.io/v2.4/man/bundle-outdated.1.html))
- ... or any other command from [Bundler Docs](https://bundler.io/docs.html)
