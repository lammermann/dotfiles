# Vis snippets

Providing snippet completetion for vis. This
module is highly influenced by 
[vims ultisnips plugin](https://github.com/SirVer/ultisnips) and by
[textadepts snippet module](http://foicica.com/textadept/api.html#textadept.snippets).

Main features are:

* dynamic lua interpolation
* multiple triggers

# Installation

# Usage

## Snippet definition

### Assign multiple triggers to a snippet

## Module properties
Module properties have to be set before calling the `start` function.

```lua
local snippets = require "snippets"

-- set all properties here
snippets.show_triggers = false
...

-- initialize the module
snippets:start(vis)
```

### show_triggers

If it is set to `true` all matching triggers are shown in the info line.

# Hacking