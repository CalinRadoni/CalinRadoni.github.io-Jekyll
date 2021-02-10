---
layout: post
title: "Convert orkaudio .mcf files to .wav or .mp3"
description: "Convert .mcf files produced by orkaudio to .wav or .mp3"
#image: /assets/img/.png
#date-modified: 2021-mm-dd
excerpt_separator: <!--more-->
categories: [ "System Administration" ]
tags: [ "orkaudio", "mcf", "Python", "ffmpeg" ]
---

Converting `.mcf` files to `.wav` or `.mp3` is not a common task. For me was an ugly task that had to be to done *fast*, without any support or documentation.<!--more-->

*Because I had to find a method to convert like 100 files ~fast~ I have build a little convoluted quick and dirty hack. The program and the algorithm could be improved but I wont waste more time, I hope that I do not need it any more. I am not a python programmer, the script does not reflect my programming style.*

## The trip

I have found a reference about the format of the `.mcf` file in the `AudioCapture.h` file from the [Oreka](https://github.com/voiceip/oreka) GitHub repository:

```h
class DLL_IMPORT_EXPORT_ORKBASE AudioChunkDetails
{
public:
    AudioChunkDetails();
    void Clear();

    int m_marker;
    AudioEncodingEnum m_encoding;
    unsigned int m_numBytes;
    unsigned int m_timestamp;        // usually relative timestamp measured in samples
    unsigned int m_arrivalTimestamp; // usually unix timestamp of arrival
    unsigned int m_sequenceNumber;
    unsigned int m_sampleRate;
    char m_rtpPayloadType;           // -1 if none
    unsigned char m_channel;         // 0 if mono, 1 or 2 if stereo, 100 if we have separated multiple channels
};
```

Using Visual Studio Code and the `ms-vscode.hexeditor` extension I have analyzed some of the files and observed that all had 2 channels encoded in `alaw` format with a 8000 Hz sample rate.

Based on these I have built a python script for `python 2.7` but probably will run with `python 3` also.

## How it works

First, the python script creates a `convertor.sh` file.

For every `.mcf` file in a specified directory:

- extracts the two streams from the *filename*`.mcf` file in two files, *filename*`1.alaw` and *filename*`2.alaw`
- write commands in `convertor.sh` to convert `.alaw` files to temporary `.wav` files
- write a command in `convertor.sh` to convert the two temporary `.wav` files to a **stereo** `.mp3` file

After the python script finishes, launch the `convertor.sh` file.

## Conversion commands

A raw `alaw` encoded file can be converted to `.wav` like this (8000 being the sample rate):

```sh
ffmpeg -f alaw -ar 8000 -i alaw_file_name output.wav
```

The `.wav` files can be converted to a stereo `.mp3` file like this:

```sh
ffmpeg -i ch1.wav -i ch2.wav -filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo[a]" -map "[a]" output.mp3
```

## The script

Here is the ugly python script:

```py
import os
from struct import *

scriptfile = open("convertor.sh", "wt")
str = "#!/bin/bash\n\n"
scriptfile.write(str)

def process_file(inputFileName):
    fileComp = os.path.splitext(inputFileName)
    fileName = fileComp[0]
    fileExt = fileComp[1]
    if fileExt != '.mcf':
        return

    filei = open(fileName + ".mcf", "rb")
    file1 = open(fileName + "1.alaw", "wb")
    file2 = open(fileName + "2.alaw", "wb")

    print("Processing " + inputFileName)
    while True :           
        header = filei.read(32)
        if not header :
            break
        if len(header) != 32 :
            print("\tERROR header length: " + str(len(header)))
            break

        hMarker, hEncoding, hNumBytes, \
            hTimestamp, hArrivalTimestamp, \
            hSequenceNumber, hSampleRate, hRtpPayloadType, hChannel, hDumb \
            = unpack('<IIIIIIIBBH', header)
        
        if hMarker != 0x2A2A2A2A :
            print("\tERROR hMarker: " + hex(hMarker))
            print(hex(filei.tell()))
            break

        if hNumBytes == 0 :
            print("\tERROR hNumBytes: " + str(hNumBytes))
            break

        data = filei.read(hNumBytes)
        if len(data) != hNumBytes :
            print("\tERROR data length: " + str(hNumBytes))
            break

        if (hChannel == 1) :
            file1.write(data)
        if (hChannel == 2) :
            file2.write(data)

    file2.close()
    file1.close()
    filei.close()

    str = "ffmpeg -f alaw -ar 8000 -i " + fileName + "1.alaw " + fileName + "1.wav\n"
    scriptfile.write(str)
    str = "ffmpeg -f alaw -ar 8000 -i " + fileName + "2.alaw " + fileName + "2.wav\n"
    scriptfile.write(str)
    str = "ffmpeg -i " + fileName + "1.wav -i " + fileName + "2.wav -filter_complex \"[0:a][1:a]join=inputs=2:channel_layout=stereo[a]\" -map \"[a]\" " + os.path.basename(fileName) + ".mp3\n"
    scriptfile.write(str)

srcDir = "10"
print("Searching for files in " + srcDir + " directory")
for root, subdirs, files in os.walk(srcDir):
    for filename in files:
        file_path = os.path.join(root, filename)
        process_file(file_path)

scriptfile.close()
print("Now run convertor.sh")
```

Easy peasy, right ? :)
