face global PhantomSelection black,green+F

decl -hidden str-list phantom_selections
decl -hidden range-specs phantom_selections_ranges

addhl global/ ranges phantom_selections_ranges

def -hidden phantom-sel-store-and-highlight %{
    set window phantom_selections %reg{^}
    set window phantom_selections_ranges %val{timestamp}
    eval -no-hooks -draft -itersel %{
        set -add window phantom_selections_ranges "%val{selection_desc}|PhantomSelection"
    }
}

def -hidden phantom-sel-iterate-impl -params 1 %{
    eval -save-regs ^ %{
        reg ^ %opt{phantom_selections}

        try %{ exec <a-z>a }
        exec %arg{1}
        # keep the main selection and put all the other in the mark
        try %{
            eval -draft %{
                exec -save-regs '' '<a-space>Z'
                phantom-sel-store-and-highlight
            }
            exec <space>
        }
    }
}

def phantom-sel-iterate-next -docstring "
Turn secondary selections into phantoms and select the next phantom
" %{
    phantom-sel-iterate-impl ')'
}

def phantom-sel-iterate-prev -docstring "
Turn secondary selections into phantoms and select the previous phantom
" %{
    phantom-sel-iterate-impl '('
}

def phantom-sel-clear -docstring "
Remove all phantom selections
" %{
    unset window phantom_selections
    unset window phantom_selections_ranges
}

def phantom-sel-select-all -docstring "
Select all phantom selections
" %{
    eval -save-regs ^ %{
        reg ^ %opt{phantom_selections}
        try %{
            exec <a-z>a
            echo ""
        }
    }
}

def phantom-sel-add-selection -docstring "
Create phantoms out of the current selections
" %{
    eval -draft -save-regs ^ %{
        reg ^ %opt{phantom_selections}
        try %{ exec "<a-z>a" }
        exec -save-regs '' "Z"
        phantom-sel-store-and-highlight
    }
}

