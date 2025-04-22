#!/usr/bin/env python

import sys
import argparse
import pathlib
import subprocess

def find_direnv_projects():
    home_dir = pathlib.Path.home()
    command = ["fd", ".", f"{home_dir}/.local/share/direnv/allow/", "-x", "cat"]
    try:
        output = subprocess.check_output(command, text=True).strip()
        projects = output.splitlines()
        projects.sort()
        return projects
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")
        return []

def find_lorri_projects():
    lorri_cache_dir = pathlib.Path.home() / ".cache" / "lorri" / "gc_roots"
    lorri_projects = []
    for gc_root in lorri_cache_dir.iterdir():
        if gc_root.is_dir():
            project_info = {}
            nix_file_link = gc_root / "gc_root" / "nix_file"
            shell_gc_root_link = gc_root / "gc_root" / "shell_gc_root"
            if nix_file_link.is_symlink():
                project_info["nix_file"] = nix_file_link.resolve()
            if shell_gc_root_link.is_symlink():
                project_info["shell_gc_root"] = shell_gc_root_link.resolve()
            if project_info:
                lorri_projects.append(project_info)
    return lorri_projects

def combine_lorri_and_direnv_projects(lorri_projects, direnv_projects):
    combined_projects = []
    lorri_project_paths = {pathlib.Path(project["nix_file"]).parent for project in lorri_projects}
    for direnv_project in direnv_projects:
        base_path = pathlib.Path(direnv_project).parent
        if base_path in lorri_project_paths:
            for lorri_project in lorri_projects:
                if pathlib.Path(lorri_project["nix_file"]).parent == base_path:
                    lorri_project["direnv"] = True
                    combined_projects.append(lorri_project)
        else:
            combined_project = {
                "nix_file": direnv_project,
                "direnv": True,
                "shell_gc_root": None
            }
            combined_projects.append(combined_project)
    for lorri_project in lorri_projects:
        if "direnv" not in lorri_project:
            lorri_project["direnv"] = False
            combined_projects.append(lorri_project)
    return combined_projects

def find_obsolete(projects):
    for project in projects:
        if "shell_gc_root" in project:
            project["shell_gc_root_exists"] = project["shell_gc_root"].exists()
        else:
            project["shell_gc_root_exists"] = False
    return projects

def sync():
    """Sync function to be implemented"""
    # TODO find the newest versions for the nix dependencies
    #      of the current project (current folder) and then
    #      update the nix/sources.json accordingly
    print("Sync function called")

def sync_all():
    """Sync all function to be implemented"""
    # TODO find the newest versions for the nix dependencies
    #      of all projects and then
    #      update the nix/sources.json accordingly
    print("Sync all function called")

def list_files():
    direnv_projects = find_direnv_projects()
    lorri_projects = find_lorri_projects()
    combined_projects = combine_lorri_and_direnv_projects(lorri_projects, direnv_projects)
    combined_projects = find_obsolete(combined_projects)

    for project in sorted(combined_projects, key=lambda x: x['nix_file']):
        print(f"  - {project['nix_file']}")
        if "shell_gc_root" in project:
            print(f"    - Shell GC Root: {project['shell_gc_root']}{' (Does not exist)' if not project['shell_gc_root_exists'] else ''}")
        print(f"    - Direnv: {'Enabled' if project['direnv'] else 'Disabled'}")
        print()

def cleanup():
    """Cleanup function to be implemented"""
    # TODO find all obsolete lorri and direnv roots and remove them
    print("Cleanup function called")

def main():
    """Main function to handle command line arguments"""
    parser = argparse.ArgumentParser(description="Script to manage files")
    subparsers = parser.add_subparsers(dest="command")

    sync_parser = subparsers.add_parser("sync", help="Sync files")
    sync_all_parser = subparsers.add_parser("sync_all", help="Sync all files")
    list_parser = subparsers.add_parser("list", help="List files")
    cleanup_parser = subparsers.add_parser("cleanup", help="Cleanup files")

    if len(sys.argv) < 2:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    match args.command:
        case "sync":
            sync()
        case "sync_all":
            sync_all()
        case "list":
            list_files()
        case "cleanup":
            cleanup()
        case _:
            print("Invalid command")
            parser.print_help()
            sys.exit(1)

if __name__ == "__main__":
    main()

