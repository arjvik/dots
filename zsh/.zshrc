#!/bin/zsh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/arjvik/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

# Powerlevel9k settings
POWERLEVEL9K_MODE="nerdfont-complete"
POWERLEVEL9K_OS_ICON_BACKGROUND="blue"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir dir_writable vcs root_indicator background_jobs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_STRATEGY=truncate_folders
POWERLEVEL9K_DIR_PATH_SEPARATOR="  "


ZSH_THEME="powerlevel9k/powerlevel9k"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)


# Install oh-my-zsh if it is not already installed
if ! [ -d ~/.oh-my-zsh ]; then
	echo "*** Arjun's oh-my-zsh install script:"
	echo "*** Installing oh-my-zsh:"
	rm -rf ~/.oh-my-zsh
	echo exit | sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	echo "*** Done!"
	echo "*** Removing wget log:"
	rm wget-log*
	echo "*** Done!"
	echo "*** Removing oh-my-zsh's configuration and installing ours over it"
	rm ~/.zshrc
	mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
	echo "*** Done!"
	echo "*** Installing powerlevel9k theme:"
	git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
	echo "*** Done!"
fi



source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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

alias rr2="cd ~/Programming/IronReign/ftc_app_rr2"
alias contests="cd ~/Programming/java/contests/Contests"
alias dots="cd ~/dots"
alias gs="git status"

