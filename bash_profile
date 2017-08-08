# .bash_profile runs every time, when login-shell is started

# Load the default-settings
. $HOME/.bashrc

# Because we are in a login shell (which is typicaly without a window manager)
# start tmux if it's not allready started.
if [[ -z $TMUX ]]; then
  tmux && exit
fi
