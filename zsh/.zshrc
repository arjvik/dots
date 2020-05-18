#!/bin/zsh

# Disable Ctrl-S and Ctrl-Q in terminal
stty -ixon

# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Powerlevel9k settings
POWERLEVEL9K_MODE="nerdfont-complete"
POWERLEVEL9K_OS_ICON_BACKGROUND="blue"
POWERLEVEL9K_VIRTUALENV_BACKGROUND="darkorange"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir dir_writable virtualenv vcs root_indicator background_jobs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND="yellow"
POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND="black"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_DIR_PATH_SEPARATOR="  "
POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER// }'

# Antigen plugin manager

if ! [[ -e ~/.antigen/antigen.zsh ]]; then
	echo "Installing antigen"
	mkdir ~/.antigen
	wget git.io/antigen -O ~/.antigen/antigen.zsh
fi

source ~/.antigen/antigen.zsh

antigen theme romkatv/powerlevel10k
antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen apply

# User configuration

export PATH=$PATH:/opt/Android/Sdk/platform-tools

# Coloured man pages using less as pager
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;32m") \
		LESS_TERMCAP_md=$(printf "\e[1;32m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;4;31m") \
			man "$@"
}

# cd to named directories
z() {
	echo "\e[31mPlease try to use the directory aliases instead of z\e[0m"
	cd "$(find ${2:-~} -name "$1" -type d -not -path '*/\.*' 2>/dev/null | awk "{print length(), \$0}" | sort -n | cut -d" " -f 2- | head -n1)"
}

unalias gss
gss() { if [[ -t 1 ]]; then  git status -s; else git status -s | cut -c4-; fi }

declare -A cdaliases=(
	["rr2"]="~/Programming/IronReign/ftc_app_rr2"
	["contests"]="~/Programming/java/contests/Contests"
	["irbot"]="~/Programming/java/robotics/ironreignbot"
	["dots"]="~/dots"
	["api"]="~/Programming/java/ArjMart/API"
	["profilr"]="~/Programming/java/web/profilr"
	["automl"]="~/Programming/python/machine-learning/AutoML"
	["cd-vui"]="~/Programming/python/pSolv/needletail-vui"
	["amc-club"]="~/Documents/Math/AMC-Club"
)

for key value in ${(kv)cdaliases}; do
	alias $key="cd $value"
done

mkc() { mkdir -p "$1" && cd "$1" || return 1 }
_mkc() { _files -W "$1" -/ }


export MYSQL_PS1="MySQL \d>\_"
export SUDO_ASKPASS=`echo =sudo-askpass-rofi`
export PIP_REQUIRE_VIRTUALENV=true
export PYTHONSTARTUP="$HOME/.pystartup"

alias gs="git status"
alias gdc="git diff --cached"
alias gh="git hub"
alias ls="lsd"
alias lst="lsd --tree"
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias penv="exec pipenv shell"
alias keybind="xev -event keyboard | sed -Ene 's/.*keycode\s*([0-9]*)\s*\(keysym\s*\w*,\s*(\w*)\).*/keycode \1 (\2)/' -e '/keycode/p'"
alias fehbg="feh --bg-scale --no-fehbg"
alias thermalzone="grep --color=always \".\" /sys/class/thermal/thermal_zone*/type | cut -c40,46-; echo '---'; cat ~/.config/polybar/thermal-zone"
alias mysql="mysql -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-)"
alias mysqldump="mysqldump -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-) profilr > ~/Documents/MySQLDumps/\$(date +'profilr-dump-%m-%d-%Y.sql')"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias btbattery="curl https://raw.githubusercontent.com/TheWeirdDev/Bluetooth_Headset_Battery_Level/master/bl_battery.py @Q | python - FC:58:FA:78:3A:CD"
alias sudoedit="export SUDO_EDITOR=\"\$(echo =gedit)\"; sudo -e"
alias eyeD3="echo 'Enabling eyeD3 virtualenv'; source ~/Software/eyeD3/bin/activate; unalias eyeD3; eyeD3"
alias animated_wallpaper="xwinwrap -fs -ov -ni -- mpv -wid WID -loop dots/walls/sky\$(xrandr | grep -q 'DP-2 connected' && echo '-double').mp4 & sleep 1"
alias python="python3"
alias pip="pip3"

alias -g @H="| head"
alias -g @T="| tail"
alias -g @G="| grep"
alias -g @L="| less"
alias -g @Q="2>/dev/null"
alias -g @S=">/dev/null"
