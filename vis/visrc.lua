-- load standard vis module, providing parts of the Lua API
require('vis')

local modpath = os.getenv("HOME") .. ".config/vis/modules/"
package.path = package.path..modpath.."?.lua;"..modpath.."?/init.lua;"

vis.events.win_open = function(win)
	-- enable syntax highlighting for known file types
	vis.filetype_detect(win)

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
end
