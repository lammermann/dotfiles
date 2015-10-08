#!/usr/bin/env python
from ranger.api.commands import *

class bulkrename(Command):
  """
  :bulkrename [-cm] [pattern]

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
    import tempfile
    from ranger.ext.shell_escape import shell_escape as esc

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
    listfile = tempfile.NamedTemporaryFile()

    listfile.write("\n".join(filenames).encode("utf-8"))
    listfile.flush()
    self.fm.run(['vim', listfile.name])
    listfile.seek(0)
    new_filenames = listfile.read().decode("utf-8").split("\n")
    listfile.close()
    if all(a == b for a, b in zip(filenames, new_filenames)):
        self.fm.notify("No renaming to be done!")
        return

    # Generate and execute script
    cmdfile = tempfile.NamedTemporaryFile()
    cmdfile.write(b"# This file will be executed when you close the editor.\n")
    cmdfile.write(b"# Please double-check everything, clear the file to abort.\n")
    cmdfile.write("\n".join("mv -vi " + esc(old) + " " + esc(new) \
        for old, new in zip(filenames, new_filenames) if old != new).encode("utf-8"))
    cmdfile.flush()
    self.fm.run(['vim', cmdfile.name])
    self.fm.run(['/bin/sh', cmdfile.name], flags='w')
    cmdfile.close()

