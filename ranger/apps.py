# Copyright (C) 2009, 2010  Roman Zimbelmann <romanz@lavabit.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
This is the default ranger configuration file for filetype detection
and application handling.

You can place this file in your ~/.config/ranger/ directory and it will be used
instead of this one.  Though, to minimize your effort when upgrading ranger,
you may want to subclass CustomApplications rather than making a full copy.
            
This example modifies the behaviour of "feh" and adds a custom media player:

#### start of the ~/.config/ranger/apps.py example
    from ranger.defaults.apps import CustomApplications as DefaultApps
    from ranger.api.apps import *
            
    class CustomApplications(DefaultApps):
        def app_kaffeine(self, c):
            return tup('kaffeine', *c)

        def app_feh_fullscreen_by_default(self, c):
            return tup('feh', '-F', *c)

        def app_default(self, c):
            f = c.file #shortcut
            if f.video or f.audio:
                return self.app_kaffeine(c)

            if f.image and c.mode == 0:
                return self.app_feh_fullscreen_by_default(c)

            return DefaultApps.app_default(self, c)
#### end of the example
"""
from ranger.defaults.apps import CustomApplications as DefaultApps
from ranger.api.apps import *
        
class CustomApplications(DefaultApps):
    def app_default(self, c):
        """How to determine the default application?"""
        f = c.file #shortcut

        if f.container:
            return tup('7zFM', *c)

        if f.video or f.audio:
            if f.video:
                c.flags += 'd'
            return self.either(c, 'mplayer', 'gnome-mplayer', 'smplayer',
                    'vlc', 'totem')

        return DefaultApps.app_default(self, c)


    # ----------------------------------------- application definitions
    # Note: Trivial application definitions are at the bottom
    def app_pager(self, c):
        return tup('vimpager', *c)

# By setting flags='d', this programs will not block ranger's terminal:
CustomApplications.generic('opera', 'firefox', 'apvlv', 'evince',
        'zathura', 'gimp', 'mirage', 'eog', 'luakit', 'chromium', flags='d')

