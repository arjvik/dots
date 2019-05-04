#!/usr/bin/env bash

cd "~/.config/Google Play Music Desktop Player/json_store"

TITLE=$(jq --raw-output ".song.title" playback.json)
ARTIST=$(jq --raw-output ".song.artist" playback.json)

PLAY=$(jq --raw-output ".playing" playback.json)
if [ $PLAY == "true" ] ; then
	PAUSED=" | iconName=media-playback-start-symbolic"
else
	PAUSED=" | iconName=media-playback-pause-symbolic"
fi

if [ "$TITLE" == "null" ] ; then
	echo "Nothing Playing"
	echo "---"
elif [ "$TITLE" == "Your music will resume shortly" ] ; then
	echo "Advertisement"
	echo "---"
else
	echo "$TITLE - $ARTIST$PAUSED"
	echo "---"
fi
echo "Show | bash=google-play-music-desktop-player terminal=false"
