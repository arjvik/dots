#/bin/sh

export PATH="$HOME/bin:/usr/local/bin:$PATH"

if [[ $TTY == "/dev/tty1" ]]; then startx; fi
