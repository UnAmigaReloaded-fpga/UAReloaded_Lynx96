# Camputers Lynx MiSTer FPGA Core



## General description

This is the first attempt to have a Lynx48 running on Mister FPGA. it was
ported from zx-uno (https://github.com/Kyp069/lynx).

## What is working.

* CPU.
* lynx 48/96/96+scorpiom
* Sound.
* Screen.
* Keyboard.
* Tape loading.
* support for 96 and scorpion ROM.
* Joysticks. 
* CRTC


## Keys

* F11 - Reset
* F8  - Level9 adventures palete fix.

## Tape conversion

 At the moment, the only way to load audio is via audio in. To convert .tap
files to wav files (the same tyou need to load on a real Lynx)
* lynx2wav (Unix) (https://github.com/RW-FPGA-devel-Team/lynx2wav)
* Mike's lynx utilities (Windows) http://retrowiki.es/viewtopic.php?f=31&t=200036021
