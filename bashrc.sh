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
export BROWSER=firefox
export EDITOR=kak
export VISUAL=kak

# Man farbig gestalten
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;34m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Add Rust Path to PATH
export PATH="$PATH:$HOME/.cargo/bin"
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
function set_windows_titles() {
    trap 'echo -ne "\033]2;$(pwd); $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"' DEBUG
}

starship_precmd_user_func="set_windows_titles"
# }}}
#===============================================================================
# vim: fdm=marker:
