#!/bin/zsh

# Disable Ctrl-S and Ctrl-Q in terminal
stty -ixon

# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Powerlevel10k settings
p10k-set() { for ((i=1; i < $#; i++)); { typeset -g POWERLEVEL9K_${@[$i]:u}=$@[-1] } }
p10k-prompt() { if [[ $1 == "right" ]]; then typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${=2}); else typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(${=2}); fi }

p10k-set mode nerdfont-complete
p10k-prompt left "os_icon context dir vcs virtualenv singularity background_jobs status newline prompt_char"
p10k-prompt right ""
p10k-set icon_before_content true
p10k-set icon_padding moderate
p10k-set prompt_add_newline true
p10k-set multiline_{first,newline,last}_prompt_{prefix,suffix} ''
p10k-set multiline_first_prompt_gap_char ' '
p10k-set multiline_first_prompt_gap_background ''
p10k-set background 238
p10k-set foreground 255
p10k-set {left,right}_{left,right}_whitespace ''
p10k-set {left,right}_{sub,}segment_separator "%k%F{$POWERLEVEL9K_BACKGROUND}%k "
p10k-set {left,right}_prompt_last_segment_end_symbol ''
p10k-set {left,right}_prompt_first_segment_start_symbol ''
p10k-set prompt_char_background ''
p10k-set prompt_char_ok_{viins,vicmd,vivis,viowr}_foreground 76
p10k-set prompt_char_error_{viins,vicmd,vivis,viowr}_foreground 196
p10k-set prompt_char_{ok,error}_viins_content_expansion '❯'
p10k-set prompt_char_{ok,error}_vicmd_content_expansion '❮'
p10k-set prompt_char_{ok,error}_vivis_content_expansion '❮'
p10k-set prompt_char_{ok,error}_viowr_content_expansion 'Ⅴ'
p10k-set prompt_char_overwrite_state true
p10k-set prompt_char_left_prompt_{last_segment_end,first_segment_start}_symbol ''
p10k-set prompt_char_left_{left,right}_whitespace ''
p10k-set os_icon_foreground 202
p10k-set context_foreground 220
p10k-set always_show_context false
p10k-set always_show_user false
p10k-set dir_foreground 31
p10k-set shorten_strategy truncate_to_unique
p10k-set shorten_delimiter ''
p10k-set dir_shortened_foreground 103
p10k-set dir_anchor_foreground 39
p10k-set dir_anchor_bold true
p10k-set shorten_folder_marker '(.git|pyvenv.cfg)'
p10k-set dir_max_length 0
p10k-set dir_show_writable true
p10k-set vcs_branch_icon ' '
p10k-set vcs_{staged,unstaged,untracked,conflicted,commits_ahead,commits_behind}_max_num -1
p10k-set vcs_{clean,untracked}_foreground 76
p10k-set vcs_modified_foreground 178
p10k-set virtualenv_foreground 37
p10k-set virtualenv_show_python_version false
p10k-set virtualenv_{left,right}_delimiter ''
p10k-set virtualenv_visual_identifier_expansion ''
p10k-set background_jobs_verbose{,_always} true
p10k-set background_jobs_foreground 48
p10k-set background_jobs_visual_identifier_expansion ''
p10k-set status_extended_states true
p10k-set status_{ok,ok_pipe,error,error_signal} true
p10k-set status_ok_foreground 70
p10k-set status_{ok_pipe,error,error_signal,error_pipe}_foreground 160
p10k-set status_ok_visual_identifier_expansion ' '
p10k-set status_{ok_pipe,error,error_signal,error_pipe}_visual_identifier_expansion '↵ '
# Custom Singularity segment
prompt_singularity() { p10k segment -c "$SINGULARITY_CONTAINER" -i '' -t "${${SINGULARITY_CONTAINER##*LabImage?}%%.img}" }
p10k-set singularity_foreground 1

# Antigen plugin manager

if ! [[ -f ~/.antigen/antigen.zsh ]]; then
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

unalias gss
gss() { if [[ -t 1 ]]; then  git status -s; else git status -s | cut -c4-; fi }

highlight() { grep -Ei --color=always "$(printf -- '%s|' "$@")^" }

addswap() {
	if ! [[ $1 == /swapfile* && $2 =~ [0-9]+[KMG]? ]]; then
		echo "Usage example: addswap /swapfile2 5G"
		return 1
	else
		sudo fallocate -l $2 $1 &&
			sudo chmod 600 $1 &&
			sudo mkswap $1 &&
			sudo swapon $1 &&
			sudo swapon ||
			echo "Something went wrong"
	fi
}

swssh() {
	if [[ ! -v 1 ]]; then
		echo "Usage: swssh <vnc port> [-L] [<ssh args>]"
		return 1
	fi
	local port=$1
	shift
	local -A portpartitions=(
		[20000]="Nucleus%03d"
		[23000]="NucleusA%03d"
		[26000]="NucleusB%03d"
		[30000]="NucleusC%03d"
		[33000]="NucleusD%03d"
		[36000]="NucleusE%03d"
	)
	for min_port in "${(@Ok)portpartitions}"; do
		if [[ $port -gt $min_port ]]; then
			local hostname=$(printf $portpartitions[$min_port] $(( ($port-$min_port)/10 )) )
			break
		fi
	done
	if ! [[ -v hostname ]]; then
		echo "No valid hostname found for port #$port"
		return 1
	fi
	if [[ $1 == "+L" ]]; then
		echo "+L"
		local extra_args='-L 8888:localhost:8888'
		shift
	else
		local extra_args=
	fi
	ssh -J s199758@nucleus.biohpc.swmed.edu s199758@$hostname $extra_args "$@"
}

declare -A cdaliases=(
	["rr2"]="~/Programming/IronReign/ftc_app_rr2"
	["contests"]="~/Programming/java/contests/Contests"
	["irbot"]="~/Programming/java/robotics/ironreignbot"
	["dots"]="~/dots"
	["api"]="~/Programming/java/ArjMart/API"
	["profilr"]="~/Programming/java/web/profilr"
	["password-portal"]="~/Programming/java/web/password-portal"
	["automl"]="~/Programming/python/machine-learning/AutoML"
	["cd-vui"]="~/Programming/python/pSolv/needletail-vui"
	["cd-ng"]="~/Programming/data-science/UTSW/nuclear-grading"
	["amc-club"]="~/Documents/Math/AMC-Club"
)

for key value in "${(@kv)cdaliases}"; do
	alias $key="cd $value"
done

mkc() { mkdir -p "$1" && cd "$1" || return 1 }
_mkc() { _files -W "$1" -/ }


export MYSQL_PS1="MySQL \d>\_"
export PIP_REQUIRE_VIRTUALENV=true
export PYTHONSTARTUP="$HOME/.pystartup"

command -v sudo-askpass-rofi >/dev/null && export SUDO_ASKPASS=`echo =sudo-askpass-rofi`

alias gs="git status"
alias gdc="git diff --cached"
alias gh="git hub"
alias ls="lsd"
alias lst="lsd --tree"
alias python="python3"
alias pip="pip3"
alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias diff="diff --color=auto" 
alias penv="exec pipenv shell"
alias ng="cd-ng && penv"
alias ngpy="cd-ng && exec pipenv shell python3"
alias keybind="xev -event keyboard | sed -Ene 's/.*keycode\s*([0-9]*)\s*\(keysym\s*\w*,\s*(\w*)\).*/keycode \1 (\2)/' -e '/keycode/p'"
alias fehbg="feh --bg-scale --no-fehbg"
alias thermalzone="grep --color=always \".\" /sys/class/thermal/thermal_zone*/type | cut -c40,46-; echo '---'; cat ~/.config/polybar/thermal-zone"
alias mysql="mysql -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-)"
alias mysqldump="mysqldump -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-) profilr > ~/Documents/MySQLDumps/\$(date +'profilr-dump-%m-%d-%Y.sql')"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias btbattery="curl https://raw.githubusercontent.com/TheWeirdDev/Bluetooth_Headset_Battery_Level/master/bluetooth_battery.py @Q | python - FC:58:FA:78:3A:CD"
alias sudoedit="export SUDO_EDITOR=\"\$(echo =gedit)\"; sudo -e"
alias eyeD3="echo 'Enabling eyeD3 virtualenv'; source ~/Software/eyeD3/bin/activate; unalias eyeD3; eyeD3"
alias temp_venv='temp_venv=$(mktemp -d);virtualenv $temp_venv;source $temp_venv/bin/activate;_unset_venv(){deactivate;rm -rf $1};trap "_unset_venv $temp_venv" EXIT;unset temp_venv'
alias animated_wallpaper="xwinwrap -fs -ov -ni -- mpv -wid WID -loop dots/walls/sky\$(xrandr | grep -q 'DP-2 connected' && echo '-double').mp4 & sleep 1"
alias savediff="ls /etc/apt/sources.list.d/ | grep -v save | xargs -I {} bash -c 'diff /etc/apt/sources.list.d/{}{,.save} && echo {} == {}.save'"
alias swvpn="cat <(lpass show \$(<~/.vpn-lpass-id) | sed -Ene '/Username|Password/s/.*: //p') <(echo push) | sudo openconnect --juniper -v https://utswra.swmed.edu -i vpn0"

alias -g @H="| head"
alias -g @T="| tail"
alias -g @G="| grep"
alias -g @L="| less"
alias -g @Q="2>/dev/null"
alias -g @S=">/dev/null"
alias -g @\?='; if [[ $? -eq 0 ]]; then echo "$? (true)"; else echo "$? (false)"; fi'

if [[ -f ~/.zshrc_custom ]]; then source ~/.zshrc_custom; fi
