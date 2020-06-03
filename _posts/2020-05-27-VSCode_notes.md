---
layout: post
title: "Visual Studio Code configuration"
description: "Visual Studio Code configuration and daily usage"
image: /assets/img/VSCode_notes.md
date-modified: 2020-06-03
categories: [ "Software development" ]
tags: [ "Visual Studio Code" ]
---

I am using Visual Studio Code for a lot of things but the most important are:

- Embedded C/C++ programming
- writing documentations and instructions in Markdown and reStructuredText
- generic editor for all kind of text files

Far from being perfect, it is my editor of choice and most of its functionality comes from extensions.

## Extensions

I am using these:

- C/C++ **ms-vscode.cpptools** C/C++ for Visual Studio Code
- Code Spell Checker **streetsidesoftware.code-spell-checker**
- EditorConfig for VS Code **editorconfig.editorconfig**
- markdownlint **davidanson.vscode-markdownlint**
- Python **ms-python.python**
- reStructuredText **lextudio.restructuredtext**
- Todo Tree **gruntfuggly.todo-tree**

I have used and maybe I will use again:

- Cisco IOS Syntax **jamiewoodio.cisco**
- Liquid Languages Support **neilding.language-liquid**
- hexdump for VSCode **slevesque.vscode-hexdump**
- Power Mode **hoovercj.vscode-power-mode**

## Programming languages

For the settings related to programming languages see [Programming Languages](https://code.visualstudio.com/docs/languages/overview)

## Configuration

```json
{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "workbench.startupEditor": "welcomePage",
    "editor.cursorBlinking": "phase",
    "editor.cursorSmoothCaretAnimation": true,
    "editor.minimap.renderCharacters": false,
    "editor.lineNumbers": "off",
    "editor.rulers": [
        { "column": 120, "color": "#29293d" }
    ],
    "editor.renameOnType": false,
    "editor.fontFamily": "'DejaVu Sans Mono', 'Droid Sans Mono', 'Fira Code', 'Cascadia Code', 'monospace', monospace",
    "editor.fontSize": 15,
    "window.zoomLevel": 0,
    "terminal.integrated.fontSize": 15,
    "explorer.enableDragAndDrop": false,
    "explorer.autoReveal": false,
    "html.autoClosingTags": false,
    "powermode.enabled": true,
    "powermode.enableShake": false,
    "cSpell.userWords": [
        "datasheet"
    ],
    "todo-tree.tree.showScanModeButton": false,
    "todo-tree.general.statusBar": "tags"
}
```

I am using `DejaVu Sans Mono` but I have tested the others and left them there for reference if I will change my mind.

`cSpell.userWord` is incomplete, should be customized by each user.
