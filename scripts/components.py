#!/usr/bin/env python3
"""Discover and copy the bundled iOS Motion UI Swift sources. Python 3 only."""

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import sys
import tempfile


SKILL = "ios-motion-ui"
MANIFEST = ".ios-motion-ui.json"
ROOT = Path(__file__).absolute().parent.parent


class InstallError(Exception):
    """An actionable input, catalog, or destination problem."""


def relative_path(value):
    if not isinstance(value, str) or not value or "\\" in value or "\x00" in value:
        raise InstallError("Catalog paths must be nonempty relative POSIX paths.")
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts or path == PurePosixPath("."):
        raise InstallError("Unsafe relative path: {}".format(value))
    return Path(*path.parts)


def checked_path(path):
    """Check before resolving, so user-created symlinks cannot disappear."""
    if "\x00" in str(path):
        raise InstallError("Paths cannot contain null characters.")
    path = Path(path).expanduser()
    if ".." in path.parts:
        raise InstallError("Use a path without '..': {}".format(path))
    path = path.absolute()
    current = Path(path.anchor)
    for index, part in enumerate(path.parts[1:], start=1):
        current /= part
        if current.is_symlink():
            # macOS exposes its standard temporary directory through /var.
            if current == Path("/var") and current.resolve() == Path("/private/var"):
                current = Path("/private/var")
                continue
            hint = " Use /private/tmp instead of /tmp." if current == Path("/tmp") else ""
            raise InstallError("Symlink paths are not supported: {}.{}".format(current, hint))
        if index < len(path.parts) - 1 and current.exists() and not current.is_dir():
            raise InstallError("A path component is not a directory: {}".format(current))
    return current


def read_file(path):
    path = checked_path(path)
    if not path.is_file():
        raise InstallError("Required regular file is missing: {}".format(path))
    flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0)
    with os.fdopen(os.open(str(path), flags), "rb") as source:
        return source.read()


def source_file(relative):
    return checked_path(ROOT / relative_path(relative))


def parse_json(data, label):
    try:
        value = json.loads(data.decode("utf-8"))
    except (UnicodeDecodeError, ValueError) as error:
        raise InstallError("Invalid JSON in {}: {}".format(label, error)) from error
    if not isinstance(value, dict):
        raise InstallError("{} must contain a JSON object.".format(label))
    return value


def string_list(value, label):
    if not isinstance(value, list) or any(not isinstance(item, str) for item in value):
        raise InstallError("{} must be a list of strings.".format(label))
    return value


def load_catalog():
    catalog = parse_json(read_file(ROOT / "catalog.json"), "catalog.json")
    if catalog.get("schema_version") != 1 or catalog.get("skill") != SKILL:
        raise InstallError("Unsupported catalog schema or skill identifier.")
    for key in ("version", "minimum_ios"):
        if not isinstance(catalog.get(key), str) or not catalog[key]:
            raise InstallError("Catalog requires a nonempty {}.".format(key))
    components = catalog.get("components")
    if not isinstance(components, dict) or not components:
        raise InstallError("Catalog components must be a nonempty object.")
    for slug, entry in components.items():
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug) or not isinstance(entry, dict):
            raise InstallError("Invalid component entry: {}".format(slug))
        if entry.get("kind") not in ("bundled", "native"):
            raise InstallError("Invalid component kind: {}".format(slug))
        for key in ("name", "description", "guide"):
            if not isinstance(entry.get(key), str) or not entry[key]:
                raise InstallError("{} requires {}.".format(slug, key))
        relative_path(entry["guide"])
        if "native_api" in entry and not isinstance(entry["native_api"], str):
            raise InstallError("Native API must be a string: {}".format(slug))
        files = string_list(entry.get("source_files"), slug + ".source_files")
        if (entry["kind"] == "bundled") != bool(files):
            raise InstallError("Only bundled entries must provide source files: {}".format(slug))
        for filename in files:
            if relative_path(filename).suffix != ".swift":
                raise InstallError("Component sources must be Swift files: {}".format(filename))
        for dependency in string_list(entry.get("dependencies"), slug + ".dependencies"):
            if dependency not in components:
                raise InstallError("Unknown dependency '{}' in '{}'.".format(dependency, slug))
    for filename in string_list(catalog.get("preview_files", []), "preview_files"):
        if relative_path(filename).suffix != ".swift":
            raise InstallError("Preview sources must be Swift files: {}".format(filename))
    return catalog


def component(catalog, slug):
    if slug not in catalog["components"]:
        raise InstallError("Unknown component '{}'. Run 'list' to see available slugs.".format(slug))
    return catalog["components"][slug]


def list_components(catalog, search=None):
    entries = catalog["components"]
    matches = []
    for slug in sorted(entries):
        entry = entries[slug]
        searchable = " ".join([slug, entry["name"], entry["kind"], entry["description"],
                               entry.get("native_api", "")]).casefold()
        if not search or search.casefold() in searchable:
            matches.append(slug)
    print("iOS Motion UI {} · iOS {}+".format(catalog["version"], catalog["minimum_ios"]))
    for slug in matches:
        entry = entries[slug]
        print("{} [{}] — {}".format(slug, entry["kind"], entry["name"]))
        print("  {}".format(entry["description"]))
        print("  Guide: {}".format(entry["guide"]))
    if not matches:
        print("No components match {!r}.".format(search))


def info_component(catalog, slug):
    entry = component(catalog, slug)
    print("{} ({}) [{}]".format(entry["name"], slug, entry["kind"]))
    print(entry["description"])
    print("Guide: {}".format(entry["guide"]))
    print("Dependencies: {}".format(", ".join(entry["dependencies"]) or "none"))
    if entry["kind"] == "native":
        print("Use SwiftUI directly; this entry has no bundled source files.")
        if entry.get("native_api"):
            print("Native API: {}".format(entry["native_api"]))
    else:
        print("Source files:")
        for filename in entry["source_files"]:
            print("  {} → {}".format(filename, Path(filename).name))


def resolve_components(catalog, requested):
    ordered, complete, visiting = [], set(), []

    def visit(slug):
        entry = component(catalog, slug)
        if slug in complete:
            return
        if slug in visiting:
            raise InstallError("Dependency cycle: {}".format(" → ".join(visiting + [slug])))
        visiting.append(slug)
        for dependency in entry["dependencies"]:
            visit(dependency)
        visiting.pop()
        complete.add(slug)
        ordered.append(slug)

    for slug in requested:
        visit(slug)
    return ordered


def digest(data):
    return hashlib.sha256(data).hexdigest()


def load_manifest(destination, catalog):
    path = checked_path(destination / MANIFEST)
    if not path.exists():
        return {"schema_version": 1, "skill": SKILL, "catalog_version": catalog["version"],
                "components": [], "files": {}}, None
    data = read_file(path)
    advice = " Use a fresh destination, then manually review and merge the sources; keep your customized files."
    try:
        value = parse_json(data, str(path))
        if (value.get("schema_version") != 1 or value.get("skill") != SKILL
                or value.get("catalog_version") != catalog["version"]):
            raise InstallError("Existing manifest has a different skill, schema, or catalog version.")
        for slug in string_list(value.get("components"), "manifest components"):
            component(catalog, slug)
        if not isinstance(value.get("files"), dict):
            raise InstallError("Manifest files must map destination filenames to SHA-256 hashes.")
        for name, checksum in value["files"].items():
            if relative_path(name).name != name or name == MANIFEST:
                raise InstallError("Unsafe filename in manifest: {}".format(name))
            if not isinstance(checksum, str) or not re.fullmatch(r"[0-9a-f]{64}", checksum):
                raise InstallError("Invalid SHA-256 in manifest: {}".format(name))
    except InstallError as error:
        raise InstallError(str(error) + advice) from error
    return value, data


def prepare_install(catalog, slugs, destination, include_preview):
    requested = list(slugs)
    for slug in requested:
        component(catalog, slug)
    if include_preview:
        requested += [slug for slug, entry in catalog["components"].items()
                      if entry["kind"] == "bundled"]
    resolved = resolve_components(catalog, requested)
    files = {}

    def add_file(relative, name=None):
        source = source_file(relative)
        name = name or source.name
        if name == MANIFEST:
            raise InstallError("Source filename collides with the installer manifest.")
        data = read_file(source)
        if name in files and files[name] != data:
            raise InstallError("Multiple different sources map to {}.".format(name))
        files[name] = data

    for slug in resolved:
        for relative in component(catalog, slug)["source_files"]:
            add_file(relative)
    if include_preview:
        for relative in catalog.get("preview_files", []):
            add_file(relative)
    if not files:
        return resolved, {}, None, None
    add_file("LICENSE", "IOSMotionUI-LICENSE.txt")
    add_file("references/provenance.md", "IOSMotionUI-PROVENANCE.md")
    if destination.exists() and not destination.is_dir():
        raise InstallError("Destination is not a directory: {}".format(destination))
    manifest, previous = load_manifest(destination, catalog)
    conflicts = []
    for name, data in files.items():
        target = checked_path(destination / name)
        if target.exists() and (not target.is_file() or read_file(target) != data):
            conflicts.append(name)
    if conflicts:
        raise InstallError("Nothing was copied. Existing files differ or are not regular files: {}. "
                           "Use a fresh destination and manually merge changes to preserve your app customizations."
                           .format(", ".join(sorted(conflicts))))
    manifest["components"] = sorted(set(manifest["components"]) | set(resolved))
    manifest["files"].update({name: digest(data) for name, data in files.items()})
    serialized = (json.dumps(manifest, indent=2, sort_keys=True) + "\n").encode("utf-8")
    return resolved, files, serialized, previous


def ensure_directory(destination, created):
    checked_path(destination)
    if destination.exists():
        if not destination.is_dir():
            raise InstallError("Destination is not a directory: {}".format(destination))
        return
    ensure_directory(destination.parent, created)
    destination.mkdir()
    created.append(destination)


def write_install(destination, files, manifest, previous):
    """Payloads are read and checked in memory before the first destination write."""
    created_files, created_dirs = [], []
    temporary_manifest = None
    try:
        ensure_directory(destination, created_dirs)
        for name, data in files.items():
            target = checked_path(destination / name)
            if target.exists():
                if read_file(target) != data:
                    raise InstallError("Destination changed during installation: {}".format(target))
                continue
            flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0)
            with os.fdopen(os.open(str(target), flags, 0o644), "wb") as output:
                created_files.append(target)
                output.write(data)
        manifest_path = checked_path(destination / MANIFEST)
        current = read_file(manifest_path) if manifest_path.exists() else None
        if current != previous:
            raise InstallError("Manifest changed during installation; rerun after other installers finish.")
        if manifest != previous:
            handle, temporary_name = tempfile.mkstemp(prefix=".ios-motion-ui-", dir=str(destination))
            temporary_manifest = Path(temporary_name)
            with os.fdopen(handle, "wb") as output:
                output.write(manifest)
            checked_path(manifest_path)
            os.replace(str(temporary_manifest), str(manifest_path))
            temporary_manifest = None
    except (OSError, InstallError):
        # Remove only files created by this attempt, never preexisting app files.
        for path in reversed(created_files):
            try:
                path.unlink()
            except OSError:
                pass
        if temporary_manifest is not None:
            try:
                temporary_manifest.unlink()
            except OSError:
                pass
        for path in reversed(created_dirs):
            try:
                path.rmdir()
            except OSError:
                pass
        raise


def install(catalog, args):
    destination = checked_path(args.destination)
    resolved, files, manifest, previous = prepare_install(
        catalog, args.slugs, destination, args.include_preview)
    for slug in resolved:
        entry = component(catalog, slug)
        if entry["kind"] == "native":
            print("{}: use {}. Guide: {}".format(
                slug, entry.get("native_api", "SwiftUI directly"), entry["guide"]))
    if not files:
        print("Native guidance only; no files to copy.")
        return
    print("{} {}".format("Dry run:" if args.dry_run else "Destination:", destination))
    print("Components: {}".format(", ".join(resolved)))
    for name in sorted(files):
        print("  {} {}".format("skip (identical)" if (destination / name).exists() else "copy", name))
    print("  {} {}".format("skip (identical)" if manifest == previous else "update", MANIFEST))
    if args.dry_run:
        print("Preflight passed. No files or directories were created.")
        return
    write_install(destination, files, manifest, previous)
    print("Ready. Add the Swift files to your iOS target in Xcode if needed.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    listing = commands.add_parser("list", help="List bundled components and native SwiftUI guides")
    listing.add_argument("--search", metavar="TEXT", help="Filter by slug, name, description, kind, or native API")
    info = commands.add_parser("info", help="Show sources, dependencies, and guidance for one component")
    info.add_argument("slug")
    copying = commands.add_parser("install", help="Copy sources and dependencies; never overwrite different files")
    copying.add_argument("slugs", nargs="+", metavar="SLUG")
    copying.add_argument("--destination", required=True, metavar="DIR", help="Directory for Swift sources")
    copying.add_argument("--dry-run", action="store_true", help="Validate and show the plan without writing anything")
    copying.add_argument("--include-preview", action="store_true", help="Include showcase and all its bundled components")
    args = parser.parse_args()
    try:
        catalog = load_catalog()
        if args.command == "list":
            list_components(catalog, args.search)
        elif args.command == "info":
            info_component(catalog, args.slug)
        else:
            install(catalog, args)
    except (InstallError, OSError) as error:
        print("Error: {}".format(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
