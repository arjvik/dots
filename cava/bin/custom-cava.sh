#!/bin/bash

cava -p <(echo '
[general]
framerate = 60
bars = 16

[output]
method = raw
raw_target = /dev/stdout
data_format = binary
bit_format = 8bit
') | python3 -c '
clear = False
with open("/dev/stdin", "rb") as f:
	while bytes := f.read(16):
		print(chr(27) + "[2J" + " ".join(["▁▂▃▄▅▆▇█"[i//32]*2 for i in bytes]))
'
