#!/bin/zsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH



# Powerlevel9k settings
POWERLEVEL9K_MODE="nerdfont-complete"
POWERLEVEL9K_OS_ICON_BACKGROUND="blue"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir dir_writable vcs root_indicator background_jobs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND="yellow"
POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND="black"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_DIR_PATH_SEPARATOR="  "

# Antigen plugin manager

if ! [[ -e ~/.antigen/antigen.zsh ]]; then
	echo "Installing antigen"
	mkdir ~/.antigen
	curl -L git.io/antigen > ~/.antigen/antigen.zsh
fi

source ~/.antigen/antigen.zsh

antigen use oh-my-zsh
antigen theme romkatv/powerlevel10k
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
    cd "$(find ${2:-~} -name "$1" -type d -not -path '*/\.*' 2>/dev/null | awk "{print length(), \$0}" | sort -n | cut -d" " -f 2- | head -n1)"
}

declare -A zcd=(
	["rr2"]="ftc_app_rr2" ["contests"]="Contests"
	["irbot"]="ironreignbot" ["dots"]="dots"
	["api"]="API" ["profilr"]="profilr"
)

for key value in ${(kv)zcd}; do
	alias $key="z $value"
done

mkc() { mkdir -p "$1" && cd "$1" || return 1 }
_mkc() { _files -W "$1" -/ }


export MYSQL_PS1="MySQL \d>\_"
export SUDO_ASKPASS=`echo =sudo-askpass-rofi`

alias gs="git status"
alias keybind="xev -event keyboard  | egrep -o 'keycode.*\)'"
alias mysql="mysql -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p$(cat `locate jdbc.properties -n1` | tail -n1 | cut -c12-)"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias sudoedit="export SUDO_EDITOR=\"\$(echo =gedit)\"; sudo -e"
