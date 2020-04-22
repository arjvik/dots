#!/bin/bash
set -eo pipefail # strict mode

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
	sleep 1
}

info_error () {
	printf "${BLUE}${BOLD}!!!ERROR: $1 ${NORMAL}\n"
	exit 1
}

info_important () {
	printf "${BLUE}${BOLD}!!! $1 ${NORMAL}\n"
}

info_ascii () {
printf "${GREEN}${BOLD}
             _       _ _         __ _       _        
            (_)     (_) |       / /| |     | |       
   __ _ _ __ ___   ___| | __   / /_| | ___ | |_ ___  
  / _' | '__| \ \ / / | |/ /  / / _' |/ _ \| __/ __| 
 | (_| | |  | |\ V /| |   <  / / (_| | (_) | |_\__ \ 
  \__,_|_|  | | \_/ |_|_|\_\/_/ \__,_|\___/ \__|___/ 
           _/ |
          |__/
${NORMAL}"
sleep 1
}

reset
info_ascii

if (( $EUID == 0 )); then
	info_error "Do not run this script as root"
fi

info "Please enter your password so that this script can sudo:\n*** (hopefully sudo will remember your authentication and not prompt you again)"
sudo -k printf "${BLUE}${BOLD}!!! Successfully elevated priviledges.${NORMAL}\n"

cd ~

info "Updating packages"
sudo apt update
[[ -z "${SKIP_LONG_INSTALLS}" ]] && sudo apt upgrade -y || info_important "Skipping apt upgrade"
info_done

info "Installing git"
sudo apt install -y git
info_done

info "Installing stow"
sudo apt install -y stow
info_done

info "Cloning arjvik/dots"
if ! [[ -d ~/dots/.git ]]; then
	rm -rf dots
	git clone https://github.com/arjvik/dots
else
	info "dots already exists, performing git pull"
	cd dots
	git pull
	cd ../
fi
info_done

info "Installing zsh"
sudo apt install -y zsh
info_done

info "Configuring zsh (antigen, powerlevel10k, etc)"
rm -rf ~/.zsh*
rm -rf ~/.antigen
rm -rf ~/.bash_history
cd ~/dots
stow zsh
zsh ~/.zshrc
chsh -s $(grep /zsh$ /etc/shells | tail -1)
info_important "Installed zsh and extras (antigen, powerlevel10k, etc)"
info_done

info "Installing gnome-calculator (apt, not snap)"
sudo snap remove gnome-calculator
sudo apt install -y gnome-calculator
info_done

info "Installing i3"
cd /opt
if ! type i3; then
	sudo git clone https://github.com/Airblader/i3 i3-gaps
	sudo chown -R $USER:$USER i3-gaps
	cd i3-gaps
	info "First, installing dependencies"
	sudo apt install -y jq build-essential libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
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

info "Removing unneeded xsessions"
[ -e /usr/share/xsessions/i3-with-shmlog.desktop ] &&
	sudo mv /usr/share/xsessions/i3-with-shmlog.desktop{,.disabled}
[ -e /usr/share/wayland-sessions/ubuntu-wayland.desktop ] &&
	sudo mv /usr/share/wayland-sessions/ubuntu-wayland.desktop{,.disabled}
info_done

info "Installing i3lock-color"
cd /opt
# Ensure that we have the forked version of i3lock (i3lock-color)
if ! type i3lock || ! i3lock -v |& grep --color=none "Cassandra Fox"; then
	sudo apt remove -y i3lock
	sudo apt install -y libjpeg-turbo8-dev libpam0g-dev libxcb-composite0-dev
	sudo git clone https://github.com/Raymo111/i3lock-color
	sudo chown -R $USER:$USER i3lock-color
	cd i3lock-color
	git tag -f "git-`git rev-parse --short HEAD`"
	autoreconf --force --install
	rm -rf build/
	mkdir -p build && cd build/
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
	make
	sudo make install
else
	info "i3lock-color found"
fi
info_important "Installed i3lock-color"
info_done

info "Installing and configuring lightdm"
sudo apt install -y slick-greeter lightdm-settings
# Save slick-greeter config
sudo tee /etc/lightdm/slick-greeter.conf >/dev/null <<EOF
[Greeter]
theme-name=Adapta-Nokto
icon-theme-name=Paper
background-color=#000000
background=$HOME/dots/walls/adapta-tealized.jpg
show-a11y=true
show-keyboard=false
draw-grid=true
EOF
info_done

info "Stowing i3"
rm -rf ~/.config/i3
rm -rf ~/bin/gnome-settings-daemon
rm -rf ~/bin/i3lock-fancy-multimonitor
cd ~/dots
stow i3
info_done

info "Installing feh"
sudo apt install -y feh
info_done

info "Installing compton"
sudo apt install -y compton
info_done

info "Stowing compton"
cd ~/dots
stow compton
info_done

info "Installing polybar"
cd /opt
if ! type polybar; then
	sudo git clone --recursive https://github.com/polybar/polybar
	sudo chown -R $USER:$USER polybar
	cd polybar
	info "First, installing dependencies"
	sudo apt install -y build-essential git cmake cmake-data \
		pkg-config libcairo2-dev libxcb1-dev libxcb-util0-dev \
		libxcb-randr0-dev libxcb-composite0-dev \
		xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
		libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev \
		libpulse-dev libjsoncpp-dev libmpdclient-dev \
		libcurl4-openssl-dev libnl-genl-3-dev
	sudo apt install -y python3-xcbgen || sudo apt install -y python-xcbgen
	./build.sh --all-features -g -A
else
	info "polybar found"
fi
info_important "Installed polybar"
info_done

info "Stowing polybar"
rm -rf ~/.config/polybar
rm -rf ~/bin/launch-polybar
cd ~/dots
stow polybar
info_done

if [[ -z "${SKIP_LONG_INSTALLS}" ]]; then
	CODENAME="$(lsb_release -c | cut -f2)"
	case "$CODENAME" in
		bionic)
			info "Installing Adapta GTK Theme"
			if ! [[ -e /etc/apt/sources.list.d/tista-ubuntu-adapta-$CODENAME.list ]]; then
				sudo add-apt-repository -yu ppa:tista/adapta
				sudo apt update
			else
				info "PPA Already added"
			fi
			sudo apt install -y adapta-gtk-theme adapta-backgrounds
			info_done

			info "Installing Paper Icon Theme"
			if ! [[ -e /etc/apt/sources.list.d/snwh-ubuntu-ppa-$CODENAME.list ]]; then
				sudo add-apt-repository -yu ppa:snwh/ppa
				sudo apt update
			else
				info "PPA Already added"
			fi
			sudo apt install -y paper-icon-theme
			info_done
			;;
		disco)
			if ! [[ -e /etc/apt/sources.list.d/tista-ubuntu-adapta-$CODENAME.list ]]; then
				info_important "Please install Adapta GTK Theme manually."
				info_important "You will likely have to use the Bionic repos for it to work."
				info_important ""
				info_important "This doesn't have to be done now, you can do it later."
				info_important "Press enter to continue"
				read -n 1 -s
			else
				info "Adapta GTK Theme (Bionic 18.04 repos) installed"
			fi

			info "Installing Paper Icon Theme"
			if ! [[ -e /etc/apt/sources.list.d/snwh-ubuntu-ppa-$CODENAME.list ]]; then
				sudo add-apt-repository -yu ppa:snwh/ppa
				sudo apt update
			else
				info "PPA Already added"
			fi
			sudo apt install -y paper-icon-theme
			info_done
			;;
		focal)
			info "Installing Adapta GTK Theme"
			sudo apt install -y adapta-gtk-theme
			info_done
			;;
			
			info "Installing Paper Icon Theme"
			if ! [[ -e /etc/apt/sources.list.d/tista-ubuntu-adapta-$CODENAME.list ]]; then
				info_important "Please install Paper Icon Theme manually."
				info_important "You will likely have to use the Disco repos for it to work."
				info_important ""
				info_important "This doesn't have to be done now, you can do it later."
				info_important "Press enter to continue"
				read -n 1 -s
			else
				info "Adapta GTK Theme (Bionic 18.04 repos) installed"
			fi
			info_done
			;;
		*)
			info "Installing Adapta GTK Theme"
			if ! [[ -e /etc/apt/sources.list.d/tista-ubuntu-adapta-$CODENAME.list ]]; then
				info_important "Please install Adapta GTK Theme manually."
				info_important "You will likely have to use the Bionic repos for it to work."
				info_important ""
				info_important "This doesn't have to be done now, you can do it later."
				info_important "Press enter to continue"
				read -n 1 -s
			else
				info "Adapta GTK Theme (Bionic 18.04 repos) installed"
			fi
			info_done

			info "Installing Paper Icon Theme"
			if ! [[ -e /etc/apt/sources.list.d/tista-ubuntu-adapta-$CODENAME.list ]]; then
				info_important "Please install Paper Icon Theme manually."
				info_important "You will likely have to use the Bionic repos for it to work."
				info_important ""
				info_important "This doesn't have to be done now, you can do it later."
				info_important "Press enter to continue"
				read -n 1 -s
			else
				info "Adapta GTK Theme (Bionic 18.04 repos) installed"
			fi
			info_done
			;;
	esac

	info "Installing Nerd Fonts (Source Code Pro and Ubuntu Mono)"
	cd /tmp
	git clone --depth=1 https://github.com/ryanoasis/nerd-fonts
	nerd-fonts/install.sh SourceCodePro UbuntuMono
	cd ~
	info_done

	info "Selecting GTK, Icon Theme, and Font"
	gsettings set org.gnome.desktop.interface gtk-theme "Adapta-Nokto"
	gsettings set org.gnome.desktop.interface icon-theme "Paper"
	gsettings set org.gnome.desktop.interface monospace-font-name "SauceCodePro Nerd Font 12"
	info_done

	info "Installing gnome-tweaks"
	sudo apt install -y gnome-tweaks
	info_done

else
	info_important "Skipping installation of Adapta GTK Theme, Paper Icon Theme, and Nerd Fonts"
fi

info "Installing dunst"
sudo apt install -y dunst
info_done

info "Configuring dunst"
[ -e /usr/share/dbus-1/services/org.freedesktop.Notifications.service ] \
	&& sudo mv /usr/share/dbus-1/services/org.freedesktop.Notifications.service{,.disabled}
cd ~/dots
stow dunst
info_done

info "Installing xwinwrap"
cd /opt
if ! type xwinwrap; then
	sudo apt install -y xorg-dev build-essential libx11-dev x11proto-xext-dev libxrender-dev libxext-dev
	sudo git clone https://github.com/ujjwal96/xwinwrap
	sudo chown -R $USER:$USER xwinwrap
	cd xwinwrap
	make
	sudo make install
else
	info "xwinwrap found"
fi
info_important "Installed xwinwrap"
info_done

info "Installing qutebrowser"
sudo apt install -y qutebrowser libjs-pdf
info_done

info "Stowing qutebrowser"
rm -rf ~/.config/qutebrowser
cd ~/.local/share
rm -f applications/qutebrowser.desktop applications/qutebrowser-incognito.desktop
cd ~/dots
stow qutebrowser
xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
info_done

info "Installing rofi"
sudo apt install -y rofi
rm -rf ~/.local/share/rofi/
cd ~/dots
stow rofi

## WEIRD WORKAROUND:
git checkout -- rofi/.local/share/rofi/themes/material.rasi
info_done

info "Installing Xorg tools"
sudo apt install -y xclip xsel xdotool
info_done

info "Installing Mopidy and ncmpcpp"
sudo apt install -y ncmpcpp
cd ~
rm -rf .ncmpcpp
cd ~/dots
stow mopidy
sudo apt install -y gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly mpc playerctl
info_done

info "Installing cava"
cd /opt
if ! type cava; then
	sudo apt install -y libfftw3-dev libasound2-dev libncursesw5-dev libpulse-dev libtool automake libiniparser-dev
	sudo git clone https://github.com/karlstav/cava
	sudo chown -R $USER:$USER cava
	cd cava
	export CPPFLAGS=-I/usr/include/iniparser
	./autogen.sh
	./configure
	make
	sudo make install
	unset CPPFLAGS
else
	info "cava found"
fi
info_important "Installed cava"
info_done

info "Stowing cava"
rm -f ~/bin/launch-cava
rm -rf ~/.config/cava
rm -f ~/.local/share/applications/cava.desktop
cd ~/dots
stow cava
info_done

info "Installing Java 8 and 11 JDK"
[[ -z "${SKIP_LONG_INSTALLS}" ]] \
	&& sudo apt install -y openjdk-11-jdk openjdk-11-source openjdk-8-jdk openjdk-8-source \
	|| info_important "Skipping installing java" 
info_done

info "Installing and configuring python"
if ! type pip3; then
	info "Installing pip3 (python package manager)"
	sudo apt install -y python3-pip
else
	info "pip3 found"
fi
if ! type virtualenv; then
	info "Installing virtualenv (python sandbox manager)"
	sudo apt install -y virtualenv
else
	info "virtualenv found"
fi
unset PIP_REQUIRE_VIRTUALENV
pip3 install ptpython
cd ~
rm -f .pystartup
cd ~/dots
stow python
info_done

info_important "Installation complete! Thank you for using arjvik's dots!"
info_important "Arjun's usual installation checklist after this:"
info_important "[ ] Select LightDM as the default login manager (sudo dpkg-reconfigure lightdm)"
info_important "[ ] Install Adapta and Paper if not already installed"
info_important "[ ] Set up Canonical Livepatch"
info_important "[ ] Fetch tab config"
info_important "[ ] Configure Gnome Terminal"
info_important "[ ] Configure Mopidy (login, add keys, etc)"
info_important "[ ] Install Software including:"
info_important "    - Eclipse"
info_important "    - Discord"
info_important "    - Typora"
info_important "    - Xournal"
info_important "    - Zoom"
info_important "    - Skype"
info_important "    - cmatrix, neofetch"
info_important "    - gotop (binary)"
info_ascii
