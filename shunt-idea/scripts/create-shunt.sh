#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: create-shunt.sh <INVOKING_REPO> <TARGET>" >&2
  exit 1
fi

repo_root=$1
target_path=$2

if [[ ! -d "$repo_root" ]]; then
  echo "INVOKING_REPO is not a directory: $repo_root" >&2
  exit 1
fi

mkdir -p "$target_path"

repo_abs=$(cd "$repo_root" && pwd -P)
target_abs=$(cd "$target_path" && pwd -P)

if [[ "$target_abs" == "$repo_abs" || "$target_abs" == "$repo_abs"/* ]]; then
  echo "TARGET must not be inside INVOKING_REPO: $target_abs" >&2
  exit 1
fi

name=$(basename "$target_abs")
shunt_dir="$repo_abs/shunt"
link_path="$shunt_dir/$name"
mkdir -p "$shunt_dir"

if [[ -e "$link_path" || -L "$link_path" ]]; then
  if [[ ! -L "$link_path" ]]; then
    echo "Path exists and is not a symlink: $link_path" >&2
    exit 1
  fi
  existing_abs=$(cd "$link_path" && pwd -P)
  if [[ "$existing_abs" != "$target_abs" ]]; then
    echo "Slide already exists and points elsewhere: $link_path -> $existing_abs" >&2
    exit 1
  fi
else
  ln -s "$target_abs" "$link_path"
fi

gitignore="$repo_abs/.gitignore"
if [[ -f "$gitignore" ]]; then
  if ! grep -Eq '^shunt/' "$gitignore"; then
    printf '\n# Local slides (junctions/symlinks to other folders on this machine)\nshunt/\n' >> "$gitignore"
  fi
else
  printf '# Local slides (junctions/symlinks to other folders on this machine)\nshunt/\n' > "$gitignore"
fi

cat > "$repo_abs/INSTRUCTIONS.md" <<EOF
Sliding means taking a file that belongs in TARGET and copying it across the slide (the symlink at SLIDE). The original stays in this repo unless the user specifically asks to clean it up.

TARGET: $target_abs
SLIDE: $link_path

When an idea or file belongs in TARGET, copy it across this SLIDE. Do not switch windows. Do not delete the invoking-repo copy unless the user requests cleanup.
EOF

echo "SLIDE=$link_path"
echo "TARGET=$target_abs"
