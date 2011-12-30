# .bash_profile runs every time, when login-shell is started

# Load the default-settings
. $HOME/.bashrc

if [ -z "$TMUX" ]
then
    #eval `ssh-agent`
    export SSH_ASKPASS=${HOME}/bin/askpass
    eval `keychain --eval ${HOME}/.ssh/id_rsa --noask --confirm --nogui`
fi
