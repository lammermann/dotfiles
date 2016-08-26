#!/usr/bin/env python
"""
The original file is at /usr/lib/python3.5/site-packages/ranger/config/commands.py
"""

from ranger.api.commands import *

class bulkrename(Command):
    """:bulkrename [-cm] [pattern]

    This command opens a list of selected files in an external editor.
    After you edit and save the file, it will generate a shell script
    which does bulk renaming according to the changes you did in the file.

    This shell script is opened in an editor for you to review.
    After you close it, it will be executed.
    """
    def execute(self):
        if self.arg(1) and self.arg(1)[0] == '-':
          flags = self.arg(1)[1:]
          command = self.rest(2)
        else:
          flags = ''
          command = self.rest(1)

        self.do_bulkrename(command, flags=flags)

    def do_bulkrename(self, pattern, flags):
        import os.path
        import sys
        import tempfile
        from ranger.ext.shell_escape import shell_escape as esc
        py3 = sys.version_info[0] >= 3

        if not pattern:
            filenames = [f.basename for f in self.fm.thistab.get_selection()]
            if len(filenames) == 1:
                filenames = [os.path.basename(f).strip() for f in os.popen("ls")]
        elif 'c' in flags:
            filenames = [f.strip() for f in os.popen(pattern)]
        else:
            filenames = [os.path.basename(f).strip() for f in
                    os.popen("ls " + pattern)]

        # Create and edit the file list
        listfile = tempfile.NamedTemporaryFile(delete=False)
        listpath = listfile.name

        if py3:
            listfile.write("\n".join(filenames).encode("utf-8"))
        else:
            listfile.write("\n".join(filenames))
        listfile.close()
        self.fm.run(['vis', listpath])
        #self.fm.run(['nvim', listfile.name])
        listfile = open(listpath, 'r')
        new_filenames = listfile.read().split("\n")
        listfile.close()
        os.unlink(listpath)
        if all(a == b for a, b in zip(filenames, new_filenames)):
            self.fm.notify("No renaming to be done!")
            return

        # Generate script
        cmdfile = tempfile.NamedTemporaryFile()
        script_lines = []
        script_lines.append("# This file will be executed when you close the editor.\n")
        script_lines.append("# Please double-check everything, clear the file to abort.\n")
        script_lines.extend("mv -vi -- %s %s\n" % (esc(old), esc(new)) \
                for old, new in zip(filenames, new_filenames) if old != new)
        script_content = "".join(script_lines)
        if py3:
            cmdfile.write(script_content.encode("utf-8"))
        else:
            cmdfile.write(script_content)
        cmdfile.flush()

        # Open the script and let the user review it, then check if the script
        # was modified by the user
        self.fm.run(['vis', cmdfile.name])
        #self.fm.run(['nvim', cmdfile.name])
        cmdfile.seek(0)
        script_was_edited = (script_content != cmdfile.read())

        # Do the renaming
        self.fm.run(['/bin/sh', cmdfile.name], flags='w')
        cmdfile.close()

        # Retag the files, but only if the script wasn't changed during review,
        # because only then we know which are the source and destination files.
        if not script_was_edited:
            tags_changed = False
            for old, new in zip(filenames, new_filenames):
                if old != new:
                    oldpath = self.fm.thisdir.path + '/' + old
                    newpath = self.fm.thisdir.path + '/' + new
                    if oldpath in self.fm.tags:
                        old_tag = self.fm.tags.tags[oldpath]
                        self.fm.tags.remove(oldpath)
                        self.fm.tags.tags[newpath] = old_tag
                        tags_changed = True
            if tags_changed:
                self.fm.tags.dump()
        else:
            fm.notify("files have not been retagged")

