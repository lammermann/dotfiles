eval (direnv hook elvish | slurp)
eval (starship init elvish)

set E:EDITOR = kak
set E:VISUAL = kak

# Set window title
fn set-title {|title| print "\e]0;"$title"\e\\" }
set edit:before-readline = [ $@edit:before-readline {
  set-title "elvish -> "(tilde-abbr $pwd)
}]

