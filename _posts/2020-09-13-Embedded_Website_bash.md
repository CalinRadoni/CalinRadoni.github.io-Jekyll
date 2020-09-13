---
layout: post
title: "Embedded website workflow - bash"
description: "Workflow to embed the website in firmware - bash"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
categories: [ "Web development" ]
tags: [ "npm", "Firmware" ]
---

The purpose of this post is to show another method to creates minimized and compressed
HTML files, with CSS and scripts included, from separate files.

This method uses a bash script, `Node.js`, `npm`, `npx` and javascript packages from [npm Repository](https://www.npmjs.com/).
The previous method is in [Embedded website workflow - Gulp]({% post_url 2020-09-01-Embedded_Website %})

Embedded site are useful for sites embedded in firmware. Embedding web files in firmware generally have some benefits like:

- faster response time;
- less processing power used;
- less flash memory occupied.

In this post I am creating a workflow that will:

- minimize the CSS files
- minimize the Javascript files
- insert the content of Javascript and CSS files in HTML
- minimize and compress the HTML files

## Requirements

`Node.js`, `npm` and `npx`. Check their presence with:

```sh
node --version
npm --version
npx --version
```

To install them in Ubuntu 20.04 I have used:

```sh
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
```

The `npm` and `npx` were automatically installed by the previous command.

For other install methods see [Node.js downloads](https://nodejs.org/en/download/) and [Downloading and installing Node.js and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

## How it works

In the `html` directory you should have:

- `src` directory
- `.gitignore` file
- `package.json` file
- `build.sh` file

In the `html/src` directory:

- `index.html` file
- `main.js` and other `*.js` files
- `main.css` and other `*.css` files

The content of those files is presented in the [Files](#files) section.

The workflow:

- all `*.js` files are concatenated, `main.js` will be the last one, and the result will be in `tmp/script.js`
- minimize `tmp/script.js` if it runs in *production* mode
- all `*.css` files are concatenated, `main.css` will be the last one, and the result will be in `tmp/style.css`
- minimize `tmp/style.css` if it runs in *production* mode
- includes the content of `tmp/script.js` and `tmp/style.css` in `src/index.html` and generates `web/index.html`
- in *production* mode the resulting `html` file is minimized and compressed

The file `html/web/index.html.gz` can be used as website in *production* mode.

## Usage

Install / update javascript packages by running `npm install` in `html` directory.

Commands to execute from the `html` directory:

- `./build.sh -h` to see the usage options
- `./build.sh` to build in *development* mode
- `./build.sh -pk` to build in *production* mode with cleaning before building
- `./build.sh -c` to clean the temporary and output directories

## Next steps

- use more linters ?
- use `gulp-sass` to compile SASS files
- use `gulp-imagemin` to minify PNG, JPEG, GIF and SVG images
- use `gulp-autoprefixer` to include all the vendor prefixes for the CSS
- there are a lot of gulp packages, just search [npmjs](https://www.npmjs.com/)
- ... and do not forget about Google

## Files

Create the `.gitignore` file:

```conf
# these are installed / updated as needed
/node_modules/

# here are the temporary files generated during build
/tmp/

# from the web directory, only the index.html.gz is needed
/web/*
!/web/index.html.gz
```

Create a `package.json` file like this one:

```json
{
  "name": "pax-LampD1",
  "version": "1.1.0",
  "description": "Builder for the web site embedded in the firmware of the pax-LampD1 device",
  "homepage": "https://github.com/CalinRadoni/pax-LampD1",
  "private": true,
  "keywords": [],
  "author": {
    "name": "Calin Radoni",
    "url": "https://calinradoni.github.io/"
  },
  "license": "GPL-3.0-only",
  "repository": {
    "type": "git",
    "url": "https://github.com/CalinRadoni/pax-LampD1.git",
    "directory": "SW/html"
  },
  "scripts": {
    "test": "echo Use the build script build.sh or 'build' and 'build-prod' commands",
    "build": "./build.sh",
    "build-prod": "./build.sh -pk"
  },
  "jshintConfig": {
    "esversion": 6
  },
  "devDependencies": {
    "clean-css": "^4.2.3",
    "clean-css-cli": "^4.3.0",
    "html-minifier": "^4.0.0",
    "inline-source": "^7.2.0",
    "inline-source-cli": "^2.0.0",
    "jshint": "^2.12.0",
    "terser": "^5.3.1"
  },
  "dependencies": {}
}
```

Create the build script, `build.sh` :

```bash
#!/bin/bash

set -e

script_name="HTML Builder"
script_version="1.3.0"

tmpDir="tmp"
webDir="web"

show_help=0
clean_mode=0
clean_before=0
production_mode=0

echo "$script_name version $script_version"

function Usage () {
  echo "Usage $0 [OPTION]"
  echo
  echo "Without options, will build in development mode, this means no minimization"
  echo "and no compression"
  echo
  echo "-h exit after showing this help"
  echo "-c exit after cleaning the temporary and output directories"
  echo "-k clean before build"
  echo "-p build in production mode"
}

function BuildJS () {
  find src -maxdepth 1 -type f -name *.js ! -name main.js -exec cat {} + > ./${tmpDir}/script.js
  cat src/main.js >> ./${tmpDir}/script.js

  ./node_modules/.bin/jshint ./${tmpDir}/script.js
}

function MinimizeJS () {
  mv ./${tmpDir}/script.js ./${tmpDir}/script_src.js
  ./node_modules/.bin/terser ./${tmpDir}/script_src.js -o ./${tmpDir}/script.js -c -m
}

function BuildCSS () {
  find src -maxdepth 1 -type f -name *.css ! -name main.css -exec cat {} + > ./${tmpDir}/style.css
  cat src/main.css >> ./${tmpDir}/style.css
}

function MinimizeCSS () {
  mv ./${tmpDir}/style.css ./${tmpDir}/style_src.css
  ./node_modules/.bin/cleancss -o ./${tmpDir}/style.css ./${tmpDir}/style_src.css
}

function BuildHTML () {
  ./node_modules/.bin/inline-source --root ./${tmpDir} ./src/index.html ./${webDir}/index.html
}

function BuildHTML_Prod () {
  ./node_modules/.bin/inline-source --root ./${tmpDir} ./src/index.html ./${tmpDir}/index.html
  ./node_modules/.bin/html-minifier --collapse-whitespace --remove-comments \
        --remove-empty-attributes --remove-optional-tags --remove-redundant-attributes \
        --remove-script-type-attributes --remove-style-link-type-attributes --remove-tag-whitespace \
        --minify-css true --minify-js true \
        ./${tmpDir}/index.html -o ./${webDir}/index.html
  gzip -k ./${webDir}/index.html
}

while getopts ":chkp" option
do
  case $option in
    c ) clean_mode=1;;
    k ) clean_before=1;;
    h ) show_help=1;;
    p ) production_mode=1;;
    * ) Usage; exit 1;;
  esac
done

if [[ $show_help -eq 1 ]]; then
  Usage
  exit 0
fi

if [[ $clean_mode -eq 1 ]]; then
  rm -rf ./${tmpDir}
  rm -rf ./${webDir}
  exit 0
fi

if [[ $clean_before -eq 1 ]]; then
  rm -rf ./${tmpDir}
  rm -rf ./${webDir}
fi

mkdir -p {${tmpDir},${webDir}}

if [[ $production_mode -eq 1 ]]; then
  BuildJS
  MinimizeJS
  BuildCSS
  MinimizeCSS
  BuildHTML_Prod
else
  BuildJS
  BuildCSS
  BuildHTML
fi

echo "Build directory:"
ls -l ./${tmpDir}
echo "Output directory:"
ls -l ./${webDir}
```

Create `src/index.html` file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Build test</title>
    <link inline rel='stylesheet' href='style.css'>
</head>
<body>
    <h1>Hello</h1>
    <h2>world</h2>
    <div id="test"></div>

    <script inline src="script.js"></script>
</body>
</html>
```

Create `src/main.css` file:

```css
* {
    box-sizing: border-box;
    margin: 0; padding: 0;
}

html {
    font-family: Roboto, Oxygen, Ubuntu, Helvetica, Arial, sans-serif;
    font-size: 16px;
    font-weight: 400;
    line-height: 1.25;
    padding: 0;
}

body {
    margin: 0 auto;
    max-width: 1024px;
}

h1 {
    color: cornflowerblue;
}
h2 {
    color: indigo;
}
```

Create `src/main.js` file:

```js
let ii = document.getElementById('test');
if (ii != null) {
    ii.innerHTML = '<p align="center">Hello from JS</p>';
}
```

Done.
