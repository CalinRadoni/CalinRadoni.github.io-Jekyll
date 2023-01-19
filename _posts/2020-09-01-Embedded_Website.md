---
layout: post
title: "Embedded website workflow - Gulp"
description: "Workflow to embed the website in firmware - Gulp"
#image: /assets/img/.png
date-modified: 2020-09-13
categories: [ "Web development" ]
tags: [ "Gulp", "npm", "Firmware" ]
---

The purpose of this post is to show a method that creates minimized and compressed
HTML files, with CSS and scripts included, from separate files.

**Note:** *these days I am using [Embedded website workflow - Bash]({% post_url 2020-09-13-Embedded_Website_Bash %})*.

These are useful for sites embedded in firmware. Embedding web files in firmware generally have some benefits like:

- faster response time;
- less processing power used;
- less flash memory occupied.

In this post I will use [Gulp](https://gulpjs.com/) to create a workflow that will:

- minimize the CSS files
- minimize the Javascript files
- insert the content of Javascript and CSS files in HTML
- minimize and compress the HTML files

## Requirements

`Gulp` requires `Node.js`, `npm` and `npx`. Check their presence with:

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

## Installation

Gulp installation is very simple in Ubuntu:

```sh
sudo npm install --global gulp-cli
```

Test the installation with this script:

```sh
#!/bin/bash

cd /tmp
npx mkdirp gulptest
cd gulptest
npm init --yes
npm install --save-dev gulp
gulp --version

cat > gulpfile.js << EOF
function defaultTask(cb) {
  // place code for your default task here
  cb();
}

exports.default = defaultTask
EOF

gulp
```

You should get a response similar to:

```txt
[12:34:56] Using gulpfile /tmp/gulptest/gulpfile.js
[12:34:56] Starting 'default'...
[12:34:56] Finished 'default' after 1.37 ms
```

## Usage

As a demo I am starting from zero with this script:

```sh
#!/bin/bash

set -e

mkdir -p html/{src,static}
cd html
npm init --yes
npm install --save-dev gulp
npm install --save-dev gulp-inline
npm install --save-dev gulp-terser
npm install --save-dev gulp-clean-css
npm install --save-dev gulp-base64-favicon
npm install --save-dev gulp-htmlmin
npm install --save-dev gulp-gzip
npm install --save-dev del
```

Edit the file `package.json` to add the data related to your project (`name`, `version` and so on).

Create this `gulpfile.js` file:

```js
const gulp = require('gulp');
const inline = require('gulp-inline');
const terser = require('gulp-terser');
const cleancss = require('gulp-clean-css');
const favicon = require('gulp-base64-favicon');
const htmlmin = require('gulp-htmlmin');
const gzip = require('gulp-gzip');
const del = require('del');

const srcDir = 'src/';
const dstDir = 'static/';

function clean() {
    return del([dstDir + '*']);
}

function build_html() {
    let stream = gulp.src(srcDir + '*.html')
        .pipe(favicon())
        .pipe(inline({
            base: srcDir,
            js: terser,
            css: cleancss,
            disabledTypes: ['svg', 'img']
        }))
        .pipe(htmlmin({
            collapseWhitespace: true,
            removeComments: true,
            minifyCSS: true,
            minifyJS: true
       }))
       .pipe(gulp.dest(dstDir))
       .pipe(gzip())
       .pipe(gulp.dest(dstDir));

    return stream;
}

exports.default = build_html;
exports.clean = clean;
```

Create the `.gitignore` file:

```txt
/node_modules/
/static/
```

Create `src/index.html` file:

```html
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- shortcut::src/favicon.png -->
        <script type='text/javascript' src='/main.js'></script>
        <link rel='stylesheet' href='/main.css'>
    </head>
    <body onload="Init();">
        <!-- just a simple hello world-->
        <h1>Hello</h1>
        <h3>world</h3>
        <div id="test"></div>
    </body>
</html>
```

Create `src/favicon.png` file, I have used a 16x16 pixels image.

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
h3 {
    color: indigo;
}
```

Create `src/main.js` file:

```js
function Init() {
    let ii = document.getElementById('test');
    if (ii !== undefined) {
        ii.innerHTML = '<p align="center">Hello from JS</p>';
    }
}
```

Commands to execute from the `html` directory:

- `gulp` to generate both HTML and compressed HTML files
- `gulp clean` to delete the content of the `static` directory

## Next steps

- read about [Gulp Boilerplate](https://github.com/cferdinandi/gulp-boilerplate)
- checkout [Gulp recipes](https://github.com/gulpjs/gulp/tree/master/docs/recipes)
- use linters for HTML, CSS and JS
- use `gulp-sass` to compile SASS files
- use `gulp-imagemin` to minify PNG, JPEG, GIF and SVG images
- use `gulp-autoprefixer` to include all the vendor prefixes for the CSS
- there are a lot of gulp packages, just search [npmjs](https://www.npmjs.com/)
- ... and do not forget about Google

## Links

For a similar approach see Xose Pérez's articles:

- [Optimizing files for SPIFFS with Gulp](https://tinkerman.cat/post/optimizing-files-for-spiffs-with-gulp/)
- [Embed your website in your ESP8266 firmware image](https://tinkerman.cat/post/embed-your-website-in-your-esp8266-firmware-image/)

He uses an advanced version in [ESPurna Firmware](https://github.com/xoseperez/espurna).
