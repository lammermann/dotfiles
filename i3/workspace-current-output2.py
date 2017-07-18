#!/usr/bin/env python

from json import loads
from os import popen
from sys import argv

def ipc_query(req="command", msg=""):
    ans = popen("i3-msg -t " + req + " '" +  msg + "'").readlines()[0]
    return loads(ans)

if __name__ == "__main__":
    # Usage & checking args
    if len(argv) != 2:
        print("Usage: switch-workspace.py name-of-workspace")
        exit(-1)

    newworkspace = argv[1]

    # Go throug all workspaces and retrieve the active display, the current
    # display of the workspace and wether it's currently visible or not
    active_output = None
    current_output = None
    ws_is_visible = False
    for w in ipc_query(req="get_workspaces"):
        if w['name'] == newworkspace:
            current_output = w['output']
            ws_is_visible = w['visible']
        if w['focused']:
            active_output = w['output']

    # When the workspace is allready shown on the current display then we are
    # done
    if current_output == active_output and ws_is_visible:
        exit(0) # Nothing to do

    # If the workspace is not shown on any display we can just switch over to
    # it
    if not ws_is_visible:
        print(ipc_query(msg="workspace " + newworkspace + ";" +
            "move workspace to output " + active_output + ";" +
            "workspace " + newworkspace + ";"))
        exit(0)

    # Otherwise it seems that the workspace is currently shown on another
    # display

    # Move the current workspace to the display of the new workspace
    cmd1 = "move workspace to output " + current_output + ";"
    # Switch to the new workspace
    cmd2 = "workspace " + newworkspace + ";"
    # Move the new workspace to the display I'm currently working on
    cmd3 = "move workspace to output " + active_output + ";"
    # Switch to the new workspace
    cmd4 = "workspace " + newworkspace + ";"
    # Execute it all
    print(ipc_query(msg=cmd1 + cmd2 + cmd3))

    # Sometimes i3 won't execute this last command (Maybe because it's busy).
    # So we have to reexecute it until it's done
    while True:
        result = ipc_query(msg=cmd4)
        if result == []:
            # Nothing is done jet
            continue
        if result[0]["success"]:
            break
        else:
            # There is some kind of problem here
            exit(1)

