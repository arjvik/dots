#!/bin/zsh

# Disable Ctrl-S and Ctrl-Q in terminal
stty -ixon

# Set tabstops to 4 spaces
tabs -4

# Powerlevel10k Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Increase history file storage
typeset -i HISTSIZE=10_000_000 SAVEHIST=100_000

# If you come from bash you might have to change your $PATH.
export PATH=~/bin:~/.local/bin:/usr/local/bin:$PATH

# Powerlevel10k settings
function p10k-set() { local i; for ((i=1; i < $#; i++)); { typeset -g POWERLEVEL9K_${@[$i]:u}=$@[-1] } }
function p10k-prompt() { if [[ $1 == "right" ]]; then typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${=2}); else typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(${=2}); fi }

p10k-set mode nerdfont-complete
p10k-prompt left "os_icon context dir vcs dvc anaconda virtualenv singularity slurm_jobs docker_context aws_profile background_jobs status newline prompt_char"
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
p10k-set {left,right}_prompt_last_segment_end_symbol $([[ $TERM != "linux" ]] && echo '' || echo '>')
p10k-set {left,right}_prompt_first_segment_start_symbol $([[ $TERM != "linux" ]] && echo '' || echo '<')
p10k-set {left,right}_{sub,}segment_separator "%k%F{$POWERLEVEL9K_BACKGROUND}$POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL%k $POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL"
p10k-set prompt_char_background ''
p10k-set prompt_char_ok_{viins,vicmd,vivis,viowr}_foreground 76
p10k-set prompt_char_error_{viins,vicmd,vivis,viowr}_foreground 196
p10k-set prompt_char_{ok,error}_viins_content_expansion $([[ $TERM != "linux" ]] && echo '❯' || echo '>')
p10k-set prompt_char_{ok,error}_vi{cmd,vis}_content_expansion '❮'
p10k-set prompt_char_{ok,error}_viowr_content_expansion ''
p10k-set prompt_char_overwrite_state true
p10k-set prompt_char_left_prompt_{last_segment_end,first_segment_start}_symbol ''
p10k-set prompt_char_left_{left,right}_whitespace ''
p10k-set os_icon_foreground 039
p10k-set os_icon_content_expansion ' '
p10k-set context_foreground 220
p10k-set context_root_foreground 46
p10k-set context_root_prefix ' '
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
p10k-set vcs_git_github_icon ' '
p10k-set {anaconda,virtualenv}_foreground 37
p10k-set {anaconda,virtualenv}_show_python_version false
p10k-set {anaconda,virtualenv}_{left,right}_delimiter ''
p10k-set {anaconda,virtualenv}_visual_identifier_expansion ''
p10k-set background_jobs_verbose{,_always} true
p10k-set background_jobs_foreground 48
p10k-set background_jobs_visual_identifier_expansion ''
p10k-set status_extended_states true
p10k-set status_{ok,ok_pipe,error,error_signal} true
p10k-set status_ok_foreground 70
p10k-set status_{ok_pipe,error,error_signal,error_pipe}_foreground 160
p10k-set status_ok_visual_identifier_expansion ' '
p10k-set status_{ok_pipe,error,error_signal,error_pipe}_visual_identifier_expansion '↵ '
# Custom segments
function prompt_singularity() { p10k segment -c "$SINGULARITY_CONTAINER" -i '' -t "${${${SINGULARITY_CONTAINER##*/}#*LabImage?}%.*}" }
p10k-set singularity_foreground 1
function prompt_slurm_jobs() { (( ${+commands[squeue]} )) && p10k segment -c "$(squeue -u $USER -o %i -h 2>/dev/null)" -i '' -t "$(squeue -u $USER -o %i -h 2>/dev/null | wc -l)" }
function instant_prompt_slurm_jobs() { (( ${+commands[squeue]} )) && p10k segment -i ' ' }
p10k-set slurm_jobs_foreground 75
function prompt_docker_context() { [[ -f ~/.docker/config.json ]] || return; local context="${${DOCKER_HOST:+%15>…>$DOCKER_HOST%>>}:-${DOCKER_CONTEXT:-$(grep -Fq '"currentContext"' ~/.docker/config.json && grep -Po '(?<="currentContext": ")[^"]*(?=")' ~/.docker/config.json)}}"; p10k segment -c "${context}" -i '' -t "${context}" }
p10k-set docker_context_foreground 39
function prompt_aws_profile() { if [[ -n ${AWS_ACCESS_KEY_ID} ]]; then p10k segment -i ' ' -s sourced -t "$AWS_ACCESS_KEY_ID[1,4]…$AWS_ACCESS_KEY_ID[-4,-1]"; else p10k segment -c "${AWS_PROFILE}" -i '' -t "$AWS_PROFILE"; fi }
p10k-set aws_profile_foreground 208
p10k-set aws_profile_sourced_foreground 160

# Antigen plugin manager

if ! [[ -f ~/.antigen/antigen.zsh ]]; then
	echo "Installing antigen"
	mkdir ~/.antigen
	wget git.io/antigen -O ~/.antigen/antigen.zsh ||
		curl -L git.io/antigen -o ~/.antigen/antigen.zsh ||
		print -P '%F{red}%B!!! Unable to install antigen via wget or curl !!!%b%f'
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

# Enable extended globs
setopt extendedglob

# Coloured man pages using less as pager
function man() {
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

function dig drill () {
	if [[ ! -t 1 ]]; then
		command $0 "$@"
	else
		# https://github.com/repro/dig-color/blob/master/dig-color.sh
		command $0 "$@" | awk '
			!/^;/		{ print "\x1b[32m"$0 }
			/^;[^;]/	{ print "\x1b[35m"$0 }
			/^;;/		{ print "\x1b[38;5;242m"$0 }
			END			{ print "\x1b[0m" }
		';
	fi
}


function watch() {
	local -A opts
	zparseopts -D -F -M -A opts c -color=c n: -interval:=n e -eval=e t -no-title=t k -keep=k && (( $# > 0 )) || {
		cat <<-'USAGE'
			watch: execute a program periodically, showing output fullscreen (zsh reimplementation)
			    -c, --color: currently ignored, all ANSI escapes are passed through verbatim
			    -n, --interval: specify update interval, uses $WATCH_INTERVAL or 1 by default
			    -e, --eval: pass arguments to eval builtin (requires special quoting) instead of attempting to alias-expand and exec
			    -t, --no-title: turn off the colored header showing time, context, and command
			    -k, --keep: do not clear screen each time before command is run
		USAGE
		return 1
	}
	if (( ! ${+opts[-e]} )); then
		local recursive_alias=0
		while (( ${+aliases[$1]} )) && (( ! recursive_alias )); do
			#echo -n "Expanding '$*'"
			[[ ${=aliases[$1]:0:1} == $1 ]] && recursive_alias=1
			set -- ${=aliases[$1]} ${@:2}
			#echo " to '$*'${recursive_alias+ (recursion)}"
		done
	fi
	while true; do
		(( ${+opts[-k]} )) || clear
		(( ${+opts[-t]} )) || print -P  '%F{2}%D{%a %b %d %Y %r}%f |'\
										'%F{4}%n@%m%f |'\
										'Every $(printf "%.1f" ${opts[-n]:-${WATCH_INTERVAL:-1}})s:'\
										'%{\x1b[3m%}${opts[-e]+eval }$*%{\x1b[0m%}\n'
		if (( ${+opts[-e]} )); then
			eval ${(q)*}
		else
			$@
		fi
		sleep ${opts[-n]:-${WATCH_INTERVAL:-1}}
	done
}

unalias gss
function gss() { if [[ -t 1 ]]; then  git status -s; else git status -s | cut -c4-; fi }

function highlight() { grep -Ei --color=always "$(printf -- '%s|' "$@")^" }

function addswap() {
	if ! [[ $1 == /swap/swapfile<1-> && $2 =~ [0-9]+[KMG]? ]]; then
		echo "Usage example: addswap /swap/swapfile2 5G"
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

function swssh() {
	if [[ ! -v 1 ]]; then
		echo "Usage: swssh <vnc port> [+L] [<ssh args>]"
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
	if [[ $port == 005 ]]; then
		local hostname=localhost
	elif [[ $port == @* ]]; then
		local hostname=Nucleus${port#@}
	else
		for min_port in "${(@Ok)portpartitions}"; do
			if [[ $port -gt $min_port ]]; then
				local hostname=$(printf $portpartitions[$min_port] $(( ($port-$min_port)/10 )) )
				break
			fi
		done
	fi
	if ! [[ -v hostname ]]; then
		echo "No valid hostname found for port #$port"
		return 1
	fi
	if [[ $1 == +L=* ]]; then
		typeset -a fwports=("${(@s/,/)${1##+L}#=}")
		echo "Forwarding ports ${(@j/, /)fwports}"
		local extra_args="$(printf '-L %1$s:localhost:%1$s ' "${(@)fwports}")"
		extra_args="${extra_args%,}"
		shift
	else
		local extra_args=
	fi
	ssh -J root@localhost:8222,s199758@nucleus.biohpc.swmed.edu s199758@$hostname "${(z)extra_args}" "$@"
}

function capslockava() {
	emulate -L zsh -o extended_glob
	[[ -n /sys/class/leds/*/brightness(#qNW) ]] ||
		sudo chmod a+w /sys/class/leds/input*::capslock/brightness(^W)
	cava -p  <(<<-'EOF'
		[general]
		framerate = 30
		bars = 4
		[output]
		method = raw
		raw_target = /dev/stdout
		data_format = ascii
		bit_format = 8bit
		EOF
	) | while IFS=';' read _ _ c _; do
		tee /sys/class/leds/*/brightness(W) <<<$(( c >= ${last:-0} )) >/dev/null
		last=$c
	done
}

function p10k-dvc(){
	antigen bundle mafredri/zsh-async
	function run_dvc() {
		emulate -L zsh
		builtin cd -q -- $1
		dvc status --show-json
	}
	
	function dvc_async_callback() {
		emulate -L zsh
		if [[ $3 == '{}' ]]; then
			typeset -g prompt_dvc_clean=1
		else
			typeset -g prompt_dvc_dirty=$(jq 'keys | length' <<<"$3")
		fi
		typeset -g prompt_dvc_loading=
		p10k display -r
		unset -f prompt_dvc
	}
	
	async_stop_worker         dvc_async_worker
	async_start_worker        dvc_async_worker -u
	async_unregister_callback dvc_async_worker
	async_register_callback   dvc_async_worker dvc_async_callback
	
	function prompt_dvc() {
		emulate -L zsh -o extended_glob
		(( $+commands[dvc]         )) || return
		[[ -n ./(../)#(.dvc)(#qN/) ]] || return
		typeset -g prompt_dvc_clean= prompt_dvc_dirty= prompt_dvc_loading=1
		p10k segment -i $'\uF6B9' -s LOADING -c '$prompt_dvc_loading' -t 'dvc loading...'
		p10k segment -i $'\uF6B9' -s CLEAN -c '$prompt_dvc_clean' -t 'dvc '
		p10k segment -i $'\uF6B9' -s DIRTY -c '$prompt_dvc_dirty' -e -t 'dvc  $prompt_dvc_dirty'
		async_job dvc_async_worker run_dvc $PWD
	}
	p10k-set dvc_foreground 208
	p10k-set dvc_loading_foreground 245
}

function take() { mkdir -p "$1" && cd "$1" || return 1 }
function _take() { _files -W "$1" -/ }

function clipcopy() { xclip -in -selection clipboard < "${1:-/dev/stdin}"; }
function clippaste() { xclip -out -selection clipboard; }

function ipinfo() {
	if [[ $# -gt 0 ]]; then
		for ip in $@; do curl -s ipinfo.io/$ip; done | jq
	elif [[ -t 0 ]]; then
		curl -s ipinfo.io | jq
	else
		xargs -i curl -s ipinfo.io/{} | jq
	fi
}

function pdfmerge() { if [[ $# -ge 2 ]]; then command gs -sDEVICE=pdfwrite -DNOPAUSE -dBATCH -dSAFER -sOutputFile="$1" "${@:2}"; else echo "Usage: pdfmerge destination.pdf source1.pdf source2.pdf ... sourceN.pdf"; fi }

function _0 .{1..9} () { local d=.; repeat ${0:1} d+=/..; cd $d;}

function 0x0.st() { curl -Ffile="@$1" 0x0.st -s | sed -e 's_http://_https://_' | tee >(clipcopy) }

function flashiso() {
	if ! [[ $# == 2 && -e $1 && -b $2 && $2 == /dev/* ]]; then
		echo "Usage: $0 ./live.iso /dev/device"
		return 1
	fi
	# Important check
	if [[ $2 == /dev/nvme* ]]; then
		echo "Refusing to flash NVMe drive! You definitely don't know what you're doing!" 
		return 1
	fi
	if ! [[ $2 == "/dev/sda" || $2 == "/dev/mmcblk0" ]]; then
		read -q "?Selected a device other than /dev/sda or /dev/mmcblk0 ($2). Are you sure you know what you're doing? " || { echo "\nAborted" && return 1 }
		echo
	fi
	if file -b $1 | grep -vq "ISO 9660 CD-ROM filesystem data"; then
		read -q "?Selected an image other than a ISO9660 file ($1). Are you sure you know what you're doing? " || { echo "\nAborted" && return 1 }
		echo
	fi
	echo "\nDevice: $(cat /sys/block/${2##/dev/}/device/model 2>/dev/null) ($(grep --color=never DEVNAME= /sys/block/${2##/dev/}/uevent))"
	local size="$(sudo blockdev --getsize64 $2)"
	echo "Size: $(numfmt --to=si <<<"$size")B ($(numfmt --to=iec-i <<<"$size")B)"
	read -q "?Are you 100% sure you want to overwrite all data on this device? " || { echo "\nAborted" && return 1 }
	echo
	sudo -kv
	pv $1 | sudo dd iflag=fullblock of=$2 oflag=direct bs=1M
}

function gedit() { command $0 $@ 2>/dev/null & }

_AWS_DEFAULT_PROFILE='dagshub-devrel'
function aws() {
	if [[ $# -eq 0 ]]; then
		echo "Use the source, Luke!" >&2
		return 42
	elif [[ $0 == "aws" && $1 == (add|rotate|exec|remove|login) ]]; then 
		aws-vault $1 ${AWS_PROFILE:-$_AWS_DEFAULT_PROFILE} $@[2,-1]
	elif [[ $0 == "aws" && $1 == (list|clear|--help*) ]]; then 
		aws-vault $@
	elif [[ $0 == "aws" && $1 == "source" ]]; then
		eval $(aws-vault exec ${AWS_PROFILE:-$_AWS_DEFAULT_PROFILE} -- zsh -c "typeset -pm 'AWS_*'")
	elif [[ $0 == "aws" && $1 == "unsource" ]]; then
		[[ -v AWS_PROFILE ]] && local _AWS_PROFILE=$AWS_PROFILE || true
		unset -m 'AWS_*'
		[[ -v _AWS_PROFILE ]] && AWS_PROFILE=$_AWS_PROFILE || true
	elif [[ $0 == "aws" && $1 == "whoami" ]]; then
		aws-vault exec ${AWS_PROFILE:-$_AWS_DEFAULT_PROFILE} -- aws sts get-caller-identity
	else
		aws-vault exec ${AWS_PROFILE:-$_AWS_DEFAULT_PROFILE} -- $0 $@
	fi
}

export MYSQL_PS1="MySQL \d>\_"
export PIP_REQUIRE_VIRTUALENV=true
export PYTHONSTARTUP="$HOME/.pystartup"

command -v sudo-askpass-rofi >/dev/null && export SUDO_ASKPASS=~/bin/sudo-askpass-rofi

declare -A diraliases=(
	["dots"]="$HOME/dots"
	["amc-club"]="$HOME/Documents/Math/AMC-Club"
	["aops"]="$HOME/Documents/Math/AoPS-Notes/WOOT 2020/Notes"
	["contests"]="$HOME/Programming/java/contests/Contests"
	["irbot"]="$HOME/Programming/java/robotics/ironreignbot"
	["api"]="$HOME/Programming/java/ArjMart/API"
	["profilr"]="$HOME/Programming/java/web/profilr"
	["pwportal"]="$HOME/Programming/java/web/password-portal"
	["automl"]="$HOME/Programming/python/AutoML"
	["vui"]="$HOME/Programming/python/needletail-vui"
	["asl"]="$HOME/Programming/python/ASLTranslator"
	["bee"]="$HOME/Programming/python/BeeHealthy"
	["cd-zoomer"]="$HOME/Programming/python/Zoomer"
	["cd-ng"]="$HOME/Programming/UTSW/nuclear-grading"
	["qpsc"]="$HOME/Programming/UTSW/QuPath/groovy/QuPath-Scripts"
	["cd-dvcdemo"]="$HOME/Programming/python/dvc-demo"
	["cd-mathpy"]="$HOME/Programming/python/math"
)

for key value in "${(@kv)diraliases}"; do
	alias $key="cd \"$value\""
done

alias gs="git status"
alias gdc="git diff --cached"
alias glog="git log --oneline --decorate --graph --all"
alias ls="lsd"
alias ll="ls -lh"
alias la="ls -lAh"
alias lst="ls --tree"
alias llt="ll --tree"
alias lsta="llt -A"
alias alert="pw-play /usr/share/sounds/freedesktop/stereo/complete.oga"
alias python="python3"
alias pip="pip3"
alias sudo="sudo "
alias {grep=grep,egrep=egrep,fgrep=fgrep}' --color=auto --exclude-dir=.git'
alias diff="diff --color=auto" 
alias gh="xdg-open \$(git remote get-url origin)"
alias ng="cd-ng && exec pipenv shell"
alias ngpy="cd-ng && exec pipenv shell python3"
alias ng-jpurl='jq ".\"python.dataScience.jupyterServerURI\" |= \"$(head -n1 ~/jupyter.txt)\"" $diraliases[cd-ng]/.vscode/settings.json | {sleep 1 && tee $diraliases[cd-ng]/.vscode/settings.json >/dev/null}'
alias neofetch='neofetch --config ~/.config/neofetch/custom.conf'
alias zoomer="cd-zoomer && source venv/bin/activate"
alias dvcdemo="cd-dvcdemo && exec pipenv shell"
alias mathpy="cd-mathpy && source venv/bin/activate && python3"
alias ip="ip -c"
alias keybind="xev -event keyboard | sed -Ene 's/.*keycode\s*([0-9]*)\s*\(keysym\s*\w*,\s*(\w*)\).*/keycode \1 (\2)/' -e '/keycode/p'"
alias fehbg="feh --bg-scale --no-fehbg"
alias thermalzone="grep --color=always \".\" /sys/class/thermal/thermal_zone*/type | cut -c40,46-; echo '---'; cat ~/.config/polybar/thermal-zone"
alias mysql-aws="mysql -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-)"
alias mysqldump-aws="mysqldump -h mydbinstance.cbg4coxfme7c.us-east-2.rds.amazonaws.com -u root -p\$(find ~ -name jdbc.properties | head -n1 | xargs cat | tail -n1 | cut -c12-) profilr > ~/Documents/MySQLDumps/\$(date +'profilr-dump-%m-%d-%Y.sql')"
alias speedtest-cli="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias btbattery="curl https://raw.githubusercontent.com/TheWeirdDev/Bluetooth_Headset_Battery_Level/master/bluetooth_battery.py @Q | python - FC:58:FA:78:3A:CD"
alias sudoedit="SUDO_EDITOR=\"\$(echo =gedit)\" sudo -e"
alias temp_venv='temp_venv=$(mktemp -d);python3 -m venv $temp_venv;source $temp_venv/bin/activate;function _unset_venv(){eval deactivate;rm -rf $1};trap "_unset_venv $temp_venv" EXIT;if [[ $PWD == ~ ]]; then cd $temp_venv; fi; unset temp_venv'
alias animated_wallpaper="xwinwrap -fs -ov -ni -- mpv -wid WID -loop dots/walls/sky\$(xrandr | grep -q 'DP-2 connected' && echo '-double').mp4 & sleep 1"
alias savediff="ls /etc/apt/sources.list.d/ | grep -v save | xargs -I {} bash -c 'diff /etc/apt/sources.list.d/{}{,.save} && echo {} == {}.save'"
alias adb-ip="adb shell ip address show wlan0 | grep 'wlan0$' | cut -d' ' -f 6 | cut -d/ -f 1"
alias swvpn="docker --context default run --cap-add=NET_ADMIN --device=/dev/net/tun -p 8222:22 --env-file <(lpass show -F 'swmed.edu' | sed -Ene '/^(Username|Password): /s/(.*): /VPN_\U\1=/p') --rm --init -it --name dockervpn dockervpn"
alias swsshfs='[[ -d /media/$USER/UTSW && -O /media/$USER/UTSW ]] || { sudo mkdir -p /media/$USER/UTSW && sudo chown -R $USER:$USER /media/$USER/UTSW }; echo "Mounting at /media/$USER/UTSW"; sshfs -f s199758@nucleus.biohpc.swmed.edu:/ /media/$USER/UTSW -o follow_symlinks -o ssh_command="ssh -J root@localhost:8222"; fusermount -u /media/$USER/UTSW || true'
alias swproxy='ssh root@localhost -p 8222 -D 9050'
alias cmdprompt="prompt_powerlevel9k_teardown && PS1='%BC:\${\${PWD//\//\\\\}/home/Users}>%b '"
alias i3-workspaces="i3-msg -t get_workspaces | jq -r '[\"ID\", \"Output\", \"Visibility\"], [\"-----------------------\"], (map([.num, .output, if .focused then \"Focused\" else if .visible then \"Visible\" else \"Unfocused\" end end]) | sort | .[]) | @tsv'"
alias docker-run-x11="xhost + && docker run -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=:0"
alias docker-run-x11-xephyr="{ pgrep -f 'Xephyr :1' || Xephyr :1 @Q &} && docker run -v /tmp/.X11-unix/X1:/tmp/.X11-unix/X1 -e DISPLAY=:1"

alias -g @Q="2>/dev/null"
alias -g @S=">/dev/null"
alias -g @\?='; if [[ $? -eq 0 ]]; then echo "$? (true)"; else echo "$? (false)"; fi'

if [[ -f ~/.zshrc_custom ]]; then source ~/.zshrc_custom; fi
