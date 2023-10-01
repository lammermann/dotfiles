# Configure environment variables
set E:EDITOR = kak
set E:VISUAL = kak

# Set window title
fn set-title {|title| print "\e]0;"$title"\e\\" }
set edit:before-readline = [ $@edit:before-readline {
  set-title "elvish -> "(tilde-abbr $pwd)
}]

# Integrate external tools
eval (direnv hook elvish | slurp)
eval (starship init elvish)
eval (carapace _carapace | slurp)
eval (navi widget elvish | slurp)
