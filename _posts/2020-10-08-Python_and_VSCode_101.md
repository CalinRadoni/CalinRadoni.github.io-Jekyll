---
layout: post
title: "Python and VSCode 101"
description: "Fast start with Python using Visual Studio Code in Ubuntu 20.04 LTS"
#image: /assets/img/.png
#date-modified: 2020-mm-dd
excerpt_separator: <!--more-->
categories: [ "Software development" ]
tags: [ "Python", "Visual Studio Code", "Git hooks" ]
---

This is a fast start with Python using Visual Studio Code in Ubuntu 20.04 LTS.<!--more-->

## Development environment

- [Visual Studio Code](https://code.visualstudio.com/)
- [Python extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

The `python3-pip` and `python3-venv` are required. Install them with:

```sh
sudo apt install python3-pip python3-venv
```

### Project's development environment

In the project directory, create, activate and test a virtual python environment:

```sh
# create a virtual environment
python3 -m venv .venv

# activate the virtual environment
source .venv/bin/activate

# print the version and the path of the activated environment
python3 -c "import sys; print(sys.version); print(sys.path)"
```

Launch VSCode from that directory (`code .`) and prepare the python project:

- open the **Command Palette** (`Ctrl+Shift+P`)
- execute the **Python: Select Interpreter** command
- select the previously created python environment

VSCode should add:

```json
    "python.pythonPath": ".venv/bin/python"
```

to the `.vscode/settings.json` file.

### Development and production modes

By default the Python extension looks for and loads an environment variable definitions file named `.env` in the current workspace folder and applies the definitions from that file.
The file is identified by the default entry `"python.envFile": "${workspaceFolder}/.env"` in user settings.
For debugging there is an `envFile` property that also defaults to `"${workspaceFolder}/.env"`.

Some environment variables (credentials, databases, ...) are different in development and production mode.

Create the default `.vscode/launch.json` file (`Run > Open configurations` will do it) and add the `envFile` entry like this:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "envFile": "${workspaceFolder}/dev.env"
        }
    ]
}
```

Edit `.vscode/settings.json` and add the entry for `prod.env` like this:

```json
{
    "python.pythonPath": ".venv/bin/python",
    "python.envFile": "${workspaceFolder}/prod.env"
}
```

Add `/dev.env` in `.gitignore` (you may not want to publish it !) then create the `dev.env` and `prod.env` files.

### Packages

Create a new integrated terminal (``Ctrl+Shift+` ``) - this will also activate the virtual environment.
In this new terminal install the packages you need.

**Example:** For [CalinRadoni](https://github.com/CalinRadoni/CalinRadoni) repo I have used:

- [PyGitHub](https://github.com/PyGithub/PyGithub), a Python library to access the GitHub API
- [Jinja](https://palletsprojects.com/p/jinja/), *a full-featured template engine for Python*

```sh
python3 -m pip install PyGithub jinja2
```

To upgrade the packages use:

```sh
python3 -m pip install --upgrade
```

### Project's requirements

Create a new integrated terminal (``Ctrl+Shift+` ``) - this will also activate the virtual environment.

To create the list of the packages required by the project use:

```sh
pip3 freeze > requirements.txt
```

Remember that this file have to be recreated after installing, updating or removing packages.

After cloning the repository, the requirements can be installed with:

```sh
pip3 install -r requirements.txt
```

For more information read the [Using requirements files](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/#using-requirements-files) document.

### Git pre-commit hook

By design the hooks are not under version control. The method presented here creates a links a script from the
repository to a git hook.

Each time a repo is cloned the link must be created for it to be used.

**Warning:** the pre-commit script can be changed and it will be run automatically before commit.
This is a **safety and security risk**. Check the script before executing `git commit` **or do not link
it and do not launch it !**

To use a pre-commit hook under version control, create an executable script in a directory in your repository
(let's say in `utils` directory) and link it to git's `pre-commit` hook:

```sh
ln -s -f ../../utils/pre-commit .git/hooks/pre-commit
```

## More information

- [Getting Started with Python in VS Code](https://code.visualstudio.com/docs/python/python-tutorial)
- [Using Python environments in VS Code](https://code.visualstudio.com/docs/python/environments)
