#!/bin/zsh

function 1p () {
	if ! keyctl request user 1password 1>/dev/null 2>/dev/null || test -z $(keyctl pipe %user:1password); then
		until local SESSION=$(pinentry <<<'GETPIN' | grep -Po '(?<=^D ).*$' | command op signin 2>/dev/null | grep -o 'OP_SESSION_\w*="\w*"' | tr -d '"'); do done
		keyctl padd user 1password @u <<< "$SESSION" 1>/dev/null
	else
		local SESSION=$(keyctl pipe %user:1password)
	fi
	env "$SESSION" op "$@"
}

function qutectl() {
	echo $0 "$@" >/dev/stderr
	[[ -n $QUTE_FIFO ]] && >$QUTE_FIFO <<<"${(@q-)*}" || qutebrowser ":${(j/ /)${(@q-)*}}"
}

function fakekey() {
	emulate -L zsh -o extended_glob
	typeset -A keysubst=('<' '<less>' '>' '<greater>' $'\t' '<Tab>')
	qutectl fake-key "${1//(#m)?/${keysubst[$MATCH]:-$MATCH}}${2:+<Tab>${2//(#m)?/${keysubst[$MATCH]:-$MATCH}}}"
}

function consoledie() {
	echo "$*"
	exit 1
}

function die() {
	qutectl message-error "$*"
	exit 1
}

function get_candidate_domains() {
	candidates=()
	if [[ $1 = <0-255>.<0-255>.<0-255>.<0-255> ]]; then
		candidates+=($1)
	else
		local prefix=$1
		while [[ $1 = *.* ]]; do
			candidates+=($1)
			prefix=${1%%.*}
			1=${1#*.}
		done
		candidates+=($prefix)
	fi
}

function get_entry_id() {
	get_candidate_domains ${${${QUTE_URL#*://}%%/*}%%:*}
	for c in $candidates; do
		if 1p item list --format json | jq --arg c "${c:l}" -re 'first(.[] | select(.urls | arrays[].href | ascii_downcase | contains($c)).id)'; then
			return
		fi
	done
	die "No candidates found for '${candidates[0]}'."
}

function get_login() {
	1p item get $1 --format json --fields username,password | jq -re '.[].value'
}

[[ -n "$QUTE_URL" ]] || consoledie "Run as a Qutebrowser userscript or populate \$QUTE_URL"
id=$(get_entry_id)
typeset -a login=("${(f)"$(get_login $id)"}")
if [[ $1 == "" || $1 == "-a" ]]; then
	# Username and password
	fakekey $login[1] $login[2]
	qutectl mode-enter insert
elif [[ $1 == "-u" ]]; then
	# Username only
	fakekey $login[1]
	qutectl mode-enter insert
elif [[ $1 == "-p" || $1 == "-w" ]]; then
	# Password only
	fakekey $login[2]
	qutectl mode-enter insert
elif [[ $1 == "-t" ]]; then
	die "TOTP not implemented yet"	
elif [[ $1 == "-b" ]]; then
	# Basic auth mode
	qutectl prompt-accept "$login[1]:$login[2]"
else
	die "Password entry mode '$1' unknown"
fi
