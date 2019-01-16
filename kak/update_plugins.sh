#!/usr/bin/bash
#
# A script to update the plugins

# Go to base direktory
cd `git rev-parse --show-toplevel`

# Update all plugins
# To add another one just run
#git subtree add -P kak/plugins/${repo_name} ${repo_url} master
# from the git root and than add the following line to the script
#git subtree pull -P kak/plugins/${repo_name} ${repo_url} master

git subtree pull -P kak/plugins/kakoune-expand https://github.com/occivink/kakoune-expand.git master
git subtree pull -P kak/plugins/kakoune-find https://github.com/occivink/kakoune-find.git master
git subtree pull -P kak/plugins/kakoune-gdb https://github.com/occivink/kakoune-gdb.git master
git subtree pull -P kak/plugins/kakoune-phantom-selection https://github.com/occivink/kakoune-phantom-selection.git master
git subtree pull -P kak/plugins/kakoune-sudo-write https://github.com/occivink/kakoune-sudo-write.git master
git subtree pull -P kak/plugins/kakoune-vertical-selection https://github.com/occivink/kakoune-vertical-selection.git master
git subtree pull -P kak/plugins/replace.kak https://github.com/alexherbo2/replace.kak.git master
git subtree pull -P kak/plugins/fzf.kak https://github.com/andreyorst/fzf.kak.git master

