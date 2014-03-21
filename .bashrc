# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias lln='ls -lF'
alias ll='ls -AlF'
alias la='ls -A'
alias lsa='ls -A'
alias ls='ls -F --color=auto --time-style=+"%y-%m-%d %H:%M:%S" --block-size=K'

#vim不使用viminfo文件，可以避免vim保存操作记录
alias svim='vim -i NONE -N -u NONE -c "set noundofile viminfo="'
#不加载所有插件，方便打开大文件
alias qvim='vim --noplugin'
#只加载一个检查文件编码的插件,一般在打开小说文件的时候使用
alias qfvim='vim --noplugin -S /home/newk/.vim/plugin/fencview.vim'

alias du='du -s -BM'

alias gnome-terminal='gnome-terminal --geometry=85x25+10+0'

alias gs='git status'
alias gl='git log --graph --decorate --format=format:"%C(yellow)%h %Cgreen%ad%Cred%d%Creset %s" --date=short --all'
alias commit='git log --name-status -3 > /tmp/git_log.tmp; git commit --verbose; rm -f /tmp/git_log.tmp'

alias p='python'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
 
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -z "$BASH_COMPLETION" ]; then
  if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
      . /etc/bash_completion
  fi
fi

#personal alias
alias gvim='gvim -f -c "call MaximizeWindow()" "$@" > /dev/null'
#alias sudo='sudo env PATH=$PATH'
### chsdir start ###
. $HOME/bin/chs_completion
. $HOME/bin/adb_completion
if [[ "$PATH" != *$Home/bin* ]]; then
  PATH=$PATH:$HOME/bin
fi
#export CHSDIR="{'n':'l'}"
### chsdir finish. ###

PATH=$PATH:$HOME/myscript

#保存历史命令时忽略下面用冒号隔开的每个命令
export HISTIGNORE="[ ]*:&:bg:fg:exit:ls:ll:vim:history:cd:cd ..:truecrypt *"
#显示历史记录时，增加序号和时间
export HISTTIMEFORMAT="%F %T "

#使git使用vim编写提交说明
export EDITOR=vim

#androidSDK=$HOME/Downloads/android-sdk-linux
#PATH=$PATH:$androidSDK/tools/:$androidSDK/platform-tools/

#export WORKON_HOME=$HOME/.virtualenvs
#source /usr/local/bin/virtualenvwrapper.sh

#export QT5PATH=$HOME/qt/src/qt-everywhere-opensource-src-5.1.0/qtbase/bin
#export QMAKE5=$QT5PATH/qmake

set -o vi

eval "$RUN_AFTER_BASHRC"


