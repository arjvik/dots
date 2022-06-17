#!/bin/zsh

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

function get_entry() {
	get_candidate_domains ${${${QUTE_URL#*://}%%/*}%%:*}
	for c in $candidates; do
		if lpass show -Gxj . | jq --arg c "${c:l}" -re '.[] | select(.url  | ascii_downcase | contains($c)) | (.username, .password)'; then
			return
		fi
	done
	for c in $candidates; do
		if lpass show -Gxj . | jq --arg c "${c:l}" -re '.[] | select(.name | ascii_downcase | contains($c)) | (.username, .password)'; then
			qutectl message-info "No candidates found through URL, selecting one through name $c."
			return
		fi
	done
	die "No candidates found for '${candidates[0]}'."
}

[[ -n "$QUTE_URL" ]] || consoledie "Run as a Qutebrowser userscript or populate \$QUTE_URL"
typeset -a login=("${(f)"$(get_entry)"}")
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
elif [[ $1 == "-b" ]]; then
	# Basic auth mode
	qutectl prompt-accept "$login[1]:$login[2]"
else
	die "Password entry mode '$1' unknown"
fi
