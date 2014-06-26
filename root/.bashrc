# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export HISTSIZE=10000
export HISTCONTROL="ignoreboth"
shopt -s histappend
PS1='[\u@\h (xge) \W`history -a &>/dev/null`]\$ '
