
map global insert <c-o> '<esc>: edit '
# <c-s> - Save file
map global normal <c-s> ': w<ret>'
map global insert <c-s> '<a-;>: w<ret>'

# cut, copy, paste
map global insert <c-x> '<a-;>d'
map global insert <c-c> '<a-;>y'
map global insert <c-v> '<a-;>P'

# <tab>/<s-tab> for completion selection
hook global InsertCompletionShow .* %{
    map window insert <tab>   '<c-n>'
    map window insert <s-tab> '<c-p>'
}
hook global InsertCompletionHide .* %{
    unmap window insert <tab>   '<c-n>'
    unmap window insert <s-tab> '<c-p>'
}

# undo, redo
map global insert <c-z>    '<a-;>u'
map global insert <c-y>    '<a-;>U'

# Ctrl for moving objects in insert mode
map global insert <c-left>    '<a-;>b<a-;>;'
map global insert <c-right>   '<a-;>w<a-;>;'
map global insert <c-up>      '<a-;>[p<a-;>;'
map global insert <c-down>    '<a-;>]p<a-;>;'
map global normal <c-left>    'b;'
map global normal <c-right>   'w;'
map global normal <c-up>      '[p;'
map global normal <c-down>    ']p;'

# Selection
# ––––––––––––––––––––––––––––––––––––––
#map global fixsel <"> ': surround<ret>"' -docstring 'surround with ""'
#map global fixsel <'> ": surround<ret>'" -docstring "surround with ''"
#map global fixsel <(> ': surround<ret>(' -docstring 'surround with ()'
#map global fixsel <{> ': surround<ret>{' -docstring 'surround with {}'

map global insert <c-a>       '<a-;>%'
map global insert <s-left>    '<a-;>H'
map global insert <s-right>   '<a-;>L'
map global insert <s-up>      '<a-;>K'
map global insert <s-down>    '<a-;>J'
map global insert <c-s-left>  '<a-;>B'
map global insert <c-a-left>  '<a-;>B'
map global insert <c-s-right> '<a-;>W'
map global insert <c-a-right> '<a-;>W'
map global insert <c-s-up>    '<a-;>{p'
map global insert <c-a-up>    '<a-;>{p'
map global insert <c-s-down>  '<a-;>}p'
map global insert <c-a-down>  '<a-;>}p'

