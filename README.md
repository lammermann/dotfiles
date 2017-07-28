Installation
------------

> sh install.sh

Create a file ~/.gitconfig and edit it this way:

~/.gitconfig
> ...
> [core]
> 	editor = nvim
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

## Installing the default programms

> sh install_progs.sh
