#!/usr/bin/env python

# Test with:
#     python -m doctest sync_envs.py

import sys
import argparse
import json
import pathlib
import subprocess

def main():
    """Main function to handle command line arguments"""
    parser = argparse.ArgumentParser(description="Script to manage files")
    subparsers = parser.add_subparsers(dest="command")

    sync_parser = subparsers.add_parser("sync", help="Sync current project")
    sync_all_parser = subparsers.add_parser("sync_all", help="Sync all projects")
    list_parser = subparsers.add_parser("list", help="List files")
    cleanup_parser = subparsers.add_parser("cleanup", help="Cleanup obsolete project environments")

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

def list_files():
    direnv_projects = find_direnv_projects()
    lorri_projects = find_lorri_projects()
    combined_projects = combine_lorri_and_direnv_projects(lorri_projects, direnv_projects)
    combined_projects = find_obsolete(combined_projects)
    combined_projects = check_if_has_git(combined_projects)
    combined_projects = find_sources_json(combined_projects)

    for project in sorted(combined_projects, key=lambda x: x['nix_file']):
        print(f"  - {project['nix_file']}")
        if "shell_gc_root" in project:
            print(f"    - Shell GC Root: {project['shell_gc_root']}{' (Does not exist)' if not project['shell_gc_root_exists'] else ''}")
        print(f"    - Direnv: {'Enabled' if project['direnv'] else 'Disabled'}")
        if project["sources.json"] != None:
            base_path = pathlib.Path(project['base_path'])
            sources = add_timestamp_to_sources(base_path / "nix" / "sources.json", project["sources.json"])
            for key, source in sources.items():
                print(f'\t\t{key}: {source["timestamp"]}')

def sync():
    """Sync the current project to use the newest sources."""
    # TODO find the newest versions for the nix dependencies
    #      of the current project (current folder) and then
    #      update the nix/sources.json accordingly
    print("Sync function called")

def sync_all():
    """Sync all projects to used the newest sources."""
    direnv_projects = find_direnv_projects()
    lorri_projects = find_lorri_projects()
    combined_projects = combine_lorri_and_direnv_projects(lorri_projects, direnv_projects)
    combined_projects = find_obsolete(combined_projects)

    modified_projects = False
    for project in sorted(combined_projects, key=lambda x: x['base_path']):
        if project["has_git"]:
            path = project["base_path"]
            if is_git_repo_modified(path):
                print(f"The repository at '{path}' has uncommitted changes")
                modified_projects = True
    if modified_projects:
        print("Do you really want to continue?")

    # TODO function that adds a timestamp to each source in sources.json

    # TODO find the newest versions for the nix dependencies
    #      of all projects and then
    #      update the nix/sources.json accordingly
    print("Sync all function called")

def cleanup():
    """Cleanup function to be implemented"""
    # TODO find all obsolete lorri and direnv roots and remove them
    print("Cleanup function called")

def find_direnv_projects():
    """Find all projects with an active direnv environment."""
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
    """Find all projects with an active lorri setup."""
    lorri_cache_dir = pathlib.Path.home() / ".cache" / "lorri" / "gc_roots"
    lorri_projects = []
    for gc_root in lorri_cache_dir.iterdir():
        if gc_root.is_dir():
            project_info = {}
            nix_file_link = gc_root / "gc_root" / "nix_file"
            shell_gc_root_link = gc_root / "gc_root" / "shell_gc_root"
            project_info["lorri_cache_path"] = gc_root
            if nix_file_link.is_symlink():
                project_info["nix_file"] = nix_file_link.resolve()
            if shell_gc_root_link.is_symlink():
                project_info["shell_gc_root"] = shell_gc_root_link.resolve()
            if project_info:
                lorri_projects.append(project_info)
    return lorri_projects

def combine_lorri_and_direnv_projects(lorri_projects, direnv_projects):
    """Combine datasets of lorri and direnv projects into a single dataset.

    Arguments:
        lorri_projects:  A list of dicts with information about a lorri project
        direnv_projects: A list of paths to a direnv .envrc file

    Usage Examples:
        >>> lorri = [{
        ...     'lorri_cache_path': '/home/user/.cache/lorri/gc_roots/somehash',
        ...     'nix_file': '/home/user/path/to/project/shell.nix',
        ...     'shell_gc_root': '/nix/store/someotherhash-lorri-keep-env-hack-nix-shell',
        ... }]
        >>> direnv = [
        ...     '/home/user/path/to/project/.envrc'
        ... ]
        >>> result = combine_lorri_and_direnv_projects(lorri, direnv)
        >>> result == [{
        ...     'base_path': '/home/user/path/to/project',
        ...     'direnv': True,
        ...     'lorri_cache_path': '/home/user/.cache/lorri/gc_roots/somehash',
        ...     'nix_file': '/home/user/path/to/project/shell.nix',
        ...     'shell_gc_root': '/nix/store/someotherhash-lorri-keep-env-hack-nix-shell',
        ... }]
        True
    """
    combined_projects = []
    lorri_project_paths = {pathlib.Path(project["nix_file"]).parent for project in lorri_projects}
    for direnv_project in direnv_projects:
        base_path = pathlib.Path(direnv_project).parent
        if base_path in lorri_project_paths:
            for lorri_project in lorri_projects:
                if pathlib.Path(lorri_project["nix_file"]).parent == base_path:
                    lorri_project["base_path"] = str(base_path)
                    lorri_project["direnv"] = True
                    combined_projects.append(lorri_project)
        else:
            combined_project = {
                "nix_file": direnv_project,
                "base_path": base_path,
                "direnv": True,
                "shell_gc_root": None
            }
            combined_projects.append(combined_project)
    for lorri_project in lorri_projects:
        if "direnv" not in lorri_project:
            lorri_project["base_path"] = str(pathlib.Path(lorri_project["nix_file"]).parent)
            lorri_project["direnv"] = False
            combined_projects.append(lorri_project)
    return combined_projects

def search_string_in_git_file(file_path, search_string):
    """Search a string in a git-managed file"""
    dir_in_git_repo = str(pathlib.Path(file_path).parent)
    file_path = str(file_path)
    try:
        # TODO how to handle if the file is not checked into git?
        git_blame_output = subprocess.check_output(["git", "-C", dir_in_git_repo, "blame", "-c", file_path])
        git_blame_output = git_blame_output.decode("utf-8")
        git_blame_lines = git_blame_output.splitlines()
        for git_blame_line in git_blame_lines:
            if search_string in git_blame_line:
                date_time = git_blame_line.split('\t')[2]
                return date_time
    except subprocess.CalledProcessError as e:
        return f"Error: {e}"
    return "Error: String not found"

def add_timestamp_to_sources(path, input):
    results = {}
    for key, source in input.items():
        source["timestamp"] = search_string_in_git_file(path, source["rev"])
        results[key] = source
    return results

def find_obsolete(projects):
    """Mark if the project is still a valid lorri project."""
    for project in projects:
        if "shell_gc_root" in project:
            project["shell_gc_root_exists"] = project["shell_gc_root"].exists()
        else:
            project["shell_gc_root_exists"] = False

    return projects

def find_sources_json(projects):
    """Find the sources.json file."""
    for project in projects:
        base_path = pathlib.Path(project['base_path'])
        sources_json_path = base_path / "nix" / "sources.json"
        if sources_json_path.exists:
            project["sources.json"] = read_json_file(sources_json_path)
    return projects

def check_if_has_git(projects):
    """Mark if a project is managed by git."""
    for project in projects:
        base_path = pathlib.Path(project['base_path'])
        project["has_git"] = is_git_root(base_path)
    return projects

def is_git_repo_modified(path):
    """Check if a git repository was modified."""
    try:
        output = subprocess.check_output(["git", "status", "--porcelain"], cwd=path)
        return output!= b""
    except subprocess.CalledProcessError:
        return False

def is_git_root(path):
    """Check if a directory is a git directory."""
    git_dir = pathlib.Path(path) / ".git"
    return git_dir.is_dir()

def read_json_file(file_path):
    try:
        with open(file_path, 'r') as file:
            data = json.load(file)
            return data
    except FileNotFoundError:
        print(f"File '{file_path}' not found")
        return None
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return None

if __name__ == "__main__":
    main()

