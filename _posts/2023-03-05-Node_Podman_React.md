---
layout: post
title: "Develop React applications with Node.js in a Podman container"
description: "Create a React app and use Node.js from a conatiner, without install it on your host OS."
#image: /assets/img/.png
#date-modified: 2021-03-26
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "Podman", "Node.js", "React", "Ubuntu"]
---

The code in this documentation was tested with:

- Ubuntu 22.04.2 LTS
- Podman 3.3.4
- Node.js 18-alpine container (the same as `lts-alpine` )

The `Podman` options used and a few words about `create-react-app` are at the end of this document.

## Preparation

Pull the `Node.js` container image:

```sh
podman pull docker.io/library/node:18-alpine
```

## Create a new React application

Go to *your directory with projects* and start the `Node.js` container with a shell:

```sh
cd your_project_directory
podman run --rm -it --userns=keep-id -v "${PWD}":/app:Z -w /app node:18-alpine /bin/ash
```

Inside the container run:

```sh
npx create-react-app test-app
exit
```

The new application is generated in the `test-app` directory.

## Development

Start the `Node.js` container with `npm start` command and map the port 3000 TCP from container to the host:

```sh
podman run --rm -it --userns=keep-id -p 3000:3000 -v "${PWD}":/app:Z -w /app/test-app node:18-alpine npm start
```

Now you can view the application in browser at [http://localhost:3000/](http://localhost:3000/)

To stop the `npm start` command and the container just press `Ctrl+C`.

From your host you can edit the application's files and the result will be available in the browser after saving them.

## About podman command line

- `--rm` Remove container after exit
- `-it`  Interactive, keep STDIN open even if not attached (-i) and allocate a pseudo-TTY for container (-t)
- `--userns=keep-id` Set the user namespace mode for the container, `keep-id` maps user account to same UID within container
- `-p 3000:3000` Publish on host's 3000 port the container's 3000 TCP port
- `-v "${PWD}":/app:Z` bind mount the current directory as container's `/app` directory and label the content with a private unshared label (:Z)
- `-w` Set the working directory inside the container

More information about `Podman`'s `run` command can be found at least:

- in [podman-run](https://docs.podman.io/en/latest/markdown/podman-run.1.html) documentation
- by running `podman run --help`

## About create-react-app

If you want to use TypeScript instead of JavaScript use:

```sh
npx create-react-app test-app --template typescript
```

Here is the documentation for [Create React App](https://create-react-app.dev/docs/getting-started) .
