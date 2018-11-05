#===============================================================================
#
# Global Bash Configuration
#===============================================================================
# Load Guard {{{
# Check for an interactive session
[ -z "$PS1" ] && return
# }}}
#===============================================================================
# Aliases {{{
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias ftp='ncftp'
alias vim='nvim'
# }}}
#===============================================================================
# Variables {{{
# Use vim as default editor
export BROWSER=/usr/bin/chromium
export EDITOR='/usr/bin/kak'
export VISUAL='/usr/bin/kak'

# export GNU_PG for vim
export GPG_TTY=`tty`

# Man farbig gestalten
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;34m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Modify luapath for local development
#export LUA_INIT="package.path = './?.lua;$HOME/.luarocks/share/lua/5.1/?.lua;' .. package.path; package.cpath = './?.so;$HOME/.luarocks/lib/lua/5.1/?.so;' .. package.cpath"
export LUA_INIT_5_2="package.path = './?.lua;$HOME/.luarocks/share/lua/5.2/?.lua;' .. package.path; package.cpath = './?.so;$HOME/.luarocks/lib/lua/5.2/?.so;' .. package.cpath"
export LUA_INIT_5_3="package.path = './?.lua;$HOME/.luarocks/share/lua/5.3/?.lua;' .. package.path; package.cpath = './?.so;$HOME/.luarocks/lib/lua/5.3/?.so;' .. package.cpath"
#export LUA_PATH="./?.lua;$HOME/.luarocks/share/lua/5.1/?.lua;/usr/share/luajit-2.0.0-beta10/?.lua;`lua -e 'print(package.path)'`"
#export LUA_CPATH="./?.so;$HOME/.luarocks/lib/lua/5.1/?.so;`lua -e 'print(package.cpath)'`"

# android tools
export ANDROID_HOME="${HOME}/bin/android-sdk-linux"
export NDK_HOME="${ANDROID_HOME}/ndk-bundle"
# }}}
#===============================================================================
# Commands {{{
# completion
if [ -f /etc/bash_completion ]; then
   . /etc/bash_completion
fi
# unmap ctrl-s for mapping it in vim
stty stop undef
# }}}
#===============================================================================
# Erweiterten Prompt einstellen {{{
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[0;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[0;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

function parse_git_branch {
    git rev-parse --git-dir &> /dev/null
    git_status="$(LANG=en_US.UTF-8; git status 2> /dev/null)"
    branch_pattern="^On branch ([^${IFS}]*)"
    remote_pattern="Your branch is (.*) of"
    diverge_pattern="Your branch and (.*) have diverged"
    if [[ ! ${git_status} =~ "working tree clean" ]]; then
        if [[ ${git_status} =~ "Changes to commited" ]]; then
            state="${RED}"
        elif [[ ${git_status} =~ "Changes not staged for commit" ]]; then
            state="${RED}"
        else
            untracked="${LIGHT_RED}*"
            state="${GREEN}"
        fi
    else
        state="${GREEN}"
    fi
    # add an else if or two here if you want to get more specific
    if [[ ${git_status} =~ ${remote_pattern} ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
            remote="${YELLOW}↑"
        else
            remote="${YELLOW}↓"
        fi
    fi
    if [[ ${git_status} =~ ${diverge_pattern} ]]; then
        remote="${YELLOW}↕"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[1]}
        echo " ${state}(${branch})${remote}${untracked}"
    fi
}

function prompt_func() {
    previous_return_value=$?;
    prompt="${BLUE}[${COLOR_NONE} \w$(parse_git_branch)${BLUE}]${COLOR_NONE}"
    if test $previous_return_value -eq 0
    then
        PS1="${prompt}${GREEN}\\\$${COLOR_NONE} "
    else
        PS1="${prompt}${LIGHT_RED}\\\$${COLOR_NONE} "
    fi
}

PROMPT_COMMAND=prompt_func
# }}}
#===============================================================================
# ssh daemon starten {{{
if [[ -o login ]]; then
  echo "You are on a login shell. No ssh daemon will be started"
else
  eval $(gnome-keyring-daemon --start --components=pkcsll,secrets,ssh)
  export SSH_AUTH_SOCK
fi
# }}}
#===============================================================================
# vim: fdm=marker:
