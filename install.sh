#!/bin/bash
set -euo pipefail # strict mode

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

info () {
	printf "${RED}${BOLD}*** $1 ${NORMAL}\n"
}

info_done () {
	printf "${RED}${BOLD}*** Done! ${NORMAL}\n\n"
}

info_error () {
	printf "${BLUE}${BOLD}!!!ERROR: $1 ${NORMAL}\n"
	exit 1
}

info_important () {
	printf "${BLUE}${BOLD}!!! $1 ${NORMAL}\n"
}

reset

if (( $EUID == 0 )); then
	info_error "Do not run this script as root"
fi

info "Please enter your password so that this script can sudo:\n*** (hopefully sudo will remember your authentication and not prompt you again)"
sudo -k printf "${BLUE}${BOLD}!!! Successfully elevated priviledges.${NORMAL}\n"

cd ~

info "Updating packages"
sudo apt update
sudo apt upgrade -y
info_done

info "Installing git"
sudo apt install -y git
info_done

info "Installing stow"
sudo apt install -y stow
info_done

info "Cloning arjvik/dots"
if ! [ -d dots/.git ]; then
	rm -rf dots
	git clone https://github.com/arjvik/dots
else
	info "dots already exists"
fi
info_done

info "Stowing zsh"
cd dots
rm -rf ~/.zsh
rm -rf ~/.oh-my-zsh
stow zsh
cd ~
info_done

info "Installing zsh"
sudo apt install -y zsh
info_done

info "Installing zsh configuration (oh-my-zsh)"
rm -rf .oh-my-zsh
zsh .zshrc
info_important "Installed zsh and oh-my-zsh and powerlevel9k"
info_done

info "Installing i3"
cd /opt
if ! type i3; then
	sudo git clone https://github.com/Airblader/i3 i3-gaps
	sudo chown -R arjvik:arjvik i3-gaps
	cd i3-gaps
	info "First, installing dependencies"
	sudo apt install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
		libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
		libstartup-notification0-dev libxcb-randr0-dev \
		libev-dev libxcb-cursor-dev libxcb-xinerama0-dev \
		libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
		autoconf libxcb-xrm0 libxcb-xrm-dev automake libxcb-shape0-dev
	autoreconf --force --install
	rm -rf build/
	mkdir -p build && cd build/
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
	make
	sudo make install
else
	info "i3 found, assuming its i3-gaps"
fi
info_important "Installed i3-gaps"
info_done

info "Stowing i3"
cd ~
rm -rf ~/.config/i3
cd dots
stow i3
info_done

info "Installing polybar"
cd /opt
if ! type polybar; then
	sudo git clone --recursive https://github.com/jaagr/polybar
	sudo chown -R arjvik:arjvik polybar
	cd polybar
	info "First, installing dependencies"
	sudo apt install build-essential git cmake cmake-data \
		pkg-config libcairo2-dev libxcb1-dev libxcb-util0-dev \
		libxcb-randr0-dev libxcb-composite0-dev python-xcbgen \
		xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
		libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev \
		libpulse-dev libjsoncpp-dev libmpdclient-dev \
		libcurl4-openssl-dev libnl-genl-3-dev
	yes | ./build
else
	info "polybar found"
fi
info_important "Installed polybar"
info_done

info "Stowing polybar"
cd ~
rm -rf ~/.config/polybar
rm -rf ~/bin/launch-polybar
cd dots
stow polybar
info_done

