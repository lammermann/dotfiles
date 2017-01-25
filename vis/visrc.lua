-- load standard vis module, providing parts of the Lua API
require('vis')
require('plugins/filetype')
require('plugins/textobject-lexer')

local modpath = os.getenv("HOME") .. ".config/vis/modules/"
package.path = package.path..modpath.."?.lua;"..modpath.."?/init.lua;"

vis.events.subscribe(vis.events.INIT, function()
  -- Your global configuration options
  vis:command("set theme ".. (vis.ui.colors <= 16 and "default-16" or "default-256"))
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)

  -- Your local configuration options e.g.
  vis:command('set relativenumber yes')
  vis:command('set tabwidth 2')
  vis:command('set expandtab yes')
  vis:command('set autoindent yes')

  --vis:map(vis.MODE_INSERT,"<Tab>",function() vis:info("Tab is not supported! in file "..win.file.name) end)
  --vis:map(vis.MODE_INSERT,"t",function()
  --  local f = win.file
  --  vis:info("Pressed t! in file "..f.name)
  --  -- insert text in all cursors
  --  for c in win:cursors_iterator() do
  --    f:insert(c.pos, "t")
  --  end
  --  win:draw()
  --end)
end)
