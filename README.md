Installation
------------

> ln -s ~/.config/tmux.conf ~/.tmux.conf
> ln -s ~/.config/bashrc ~/.bashrc
> ln -s ~/.config/bash_profile ~/.bash_profile
> ln -s ~/.config/Xdefaults ~/.Xdefaults

Create a file ~/.gitconfig and edit it this way:

~/.gitconfig
> ...
> [core]
> 	editor = vim
> 	autocrlf = input
> 	excludesfile = /home/benjamin/.config/ignore
>     ...
> [merge]
> 	tool = vimdiff
>     ...
> [color]
> 	ui = true
>     ...
> ...
