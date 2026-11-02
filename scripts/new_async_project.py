"""Create a firmware project from the workspace's Embassy template."""

import os
import re
import shutil
import sys
import tempfile
import tomllib
from pathlib import Path


def add_workspace_member(manifest: str, member: str) -> str:
    """Insert into the existing multiline members array without reformatting it."""
    workspace = tomllib.loads(manifest).get("workspace", {})

    if member in workspace.get("members", []):
        raise ValueError(f"Workspace already contains {member}.")

    workspace_table = re.search(
        r"(?ms)^\[workspace\][ \t]*\n(?P<body>.*?)(?=^\[|\Z)", manifest
    )

    if workspace_table is None:
        raise ValueError("Cargo.toml does not contain a workspace table.")

    members = re.search(
        r"(?ms)^members[ \t]*=[ \t]*\[.*?^(?P<closing>[ \t]*\])",
        workspace_table.group("body"),
    )

    if members is None:
        raise ValueError("Expected a multiline workspace members array in Cargo.toml.")

    insertion = workspace_table.start("body") + members.start("closing")
    updated = manifest[:insertion] + f'  "{member}",\n' + manifest[insertion:]
    tomllib.loads(updated)

    return updated


def ensure_unique_package_name(workspace_root: Path, manifest: str, name: str) -> None:
    """Reject names already used by a package in the workspace."""
    workspace = tomllib.loads(manifest).get("workspace", {})

    for member in workspace.get("members", []):
        for package_root in workspace_root.glob(member):
            package_manifest = tomllib.loads((package_root / "Cargo.toml").read_text())

            if package_manifest.get("package", {}).get("name") == name:
                raise ValueError(f"Workspace already has a package named {name}.")


def write_manifest_atomically(manifest_path: Path, contents: str) -> None:
    """Keep the original manifest intact until the replacement is complete."""
    descriptor, temporary = tempfile.mkstemp(
        prefix=".Cargo.toml.", dir=manifest_path.parent
    )
    staged_path = Path(temporary)

    try:
        with os.fdopen(descriptor, "w") as staged_manifest:
            staged_manifest.write(contents)

        shutil.copymode(manifest_path, staged_path)
        staged_path.replace(manifest_path)
    finally:
        staged_path.unlink(missing_ok=True)


def create_project(workspace_root: Path, name: str) -> Path:
    """Prepare all files before making the new workspace member visible."""
    if re.fullmatch(r"[a-z][a-z0-9_-]*", name) is None:
        raise ValueError("Use a project name starting with a lowercase letter, followed by lowercase letters, digits, '-' or '_'.")

    projects_root = workspace_root / "projects"
    destination = projects_root / name

    if destination.exists() or destination.is_symlink():
        raise ValueError(f"Project already exists: {destination}")

    manifest_path = workspace_root / "Cargo.toml"
    manifest = manifest_path.read_text()
    ensure_unique_package_name(workspace_root, manifest, name)
    updated_manifest = add_workspace_member(manifest, f"projects/{name}")
    template_root = workspace_root / "templates" / "async-project"

    with tempfile.TemporaryDirectory(prefix=".new-async-", dir=projects_root) as temporary:
        staged_project = Path(temporary) / name
        shutil.copytree(template_root, staged_project)

        for path in staged_project.rglob("*"):
            if path.is_file():
                path.write_text(path.read_text().replace("__PROJECT_NAME__", name))

        staged_project.rename(destination)

        try:
            write_manifest_atomically(manifest_path, updated_manifest)
        except OSError:
            shutil.rmtree(destination)
            raise

    return destination


def main() -> None:
    workspace_root = Path(__file__).resolve().parent.parent

    try:
        name = os.environ["ASYNC_PROJECT_NAME"]
        destination = create_project(workspace_root, name)
    except (KeyError, OSError, ValueError) as error:
        sys.exit(str(error))

    print(f"Created {destination.relative_to(workspace_root)} and added it to the workspace.")
    print(f"Build: cd projects/{name} && cargo build")
    print("Run on a connected micro:bit V2: cargo run")


if __name__ == "__main__":
    main()
