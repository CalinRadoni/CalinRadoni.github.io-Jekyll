---
layout: post
title: "Using Jekyll and GitHub Pages"
description: "Install Jekyll, creating a Jekyll site and a GitHub Pages site"
image: /assets/img/Jekyll_and_GitHub_Pages.png
date-modified: 2020-06-03
categories: [ "Web development" ]
tags: [ "Jekyll", "GitHub Pages" ]
---

## Jekyll instalation

[Jekyll](https://jekyllrb.com/) needs [Ruby](https://www.ruby-lang.org/en/) and the [documentation from HitHub Pages](https://help.github.com/en/github/working-with-github-pages/testing-your-github-pages-site-locally-with-jekyll) also recommends [Bundler](https://bundler.io/).

To install those on Debian / Ubuntu use this script:

```sh
#!/bin/bash
set -e

sudo apt update && sudo apt install -y ruby-full build-essential zlib1g-dev

mkdir ~/gems
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH
echo >> ~/.bashrc
echo '# Ruby gems paths' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc

gem install jekyll bundler
```

## Create a Jekyll site

Execute this script in an **empty** directory:

```sh
#!/bin/bash
set -e

bundle init
bundle config set --local path 'vendor/bundle'
bundle add jekyll
bundle exec jekyll new --force --skip-bundle .
bundle install
```

Serve the site with:

```sh
bundle exec jekyll serve
```

and open a browser to [http://127.0.0.1:4000](http://127.0.0.1:4000) to see it.

## Create a GitHub Pages site

Execute this script in an **empty** directory:

```sh
#!/bin/bash
set -e

bundle init
bundle config set --local path 'vendor/bundle'
bundle add github-pages
bundle exec jekyll new --force --skip-bundle .
bundle install
```

Serve the site with:

```sh
bundle exec jekyll serve
```

and open a browser to [http://127.0.0.1:4000](http://127.0.0.1:4000) to see it.

## Notes

### GitHub Pages information

[Creating a GitHub Pages site with Jekyll](https://help.github.com/en/github/working-with-github-pages/creating-a-github-pages-site-with-jekyll) is wrong or incomplete.

Building the site like is written there, as of 2020-06-03, will not work.

### Gem path configuration

Using the command:

```sh
bundle config set --local path 'vendor/bundle'
```

will set `path` only for the current application.
The setting is stored in the `.bundle/config` file, in current directory.

To set `path` for all bundles executed as the current user use:

```sh
bundle config set path 'vendor/bundle'
```

The setting is stored in the `~/.bundle/config` file.

To see all settings use `bundle config list` command.
