#!/bin/bash

# Godot's project manager list is an INI file with one section per project:
#
#   [/path/to/project]
#   favorite=false
#
# Orca repo hooks keep worktrees in sync with it:
#
#   setup   ->  bash "$ORCA_ROOT_PATH/godot-projects.sh" add
#   archive ->  bash "$ORCA_ROOT_PATH/godot-projects.sh" remove

set -uo pipefail

ACTION="${1:-}"
ROOT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="${2:-${ORCA_WORKTREE_PATH:-$PWD}}"

# Godot's editor data dir, where projects.cfg lives (EditorPaths::get_data_dir)
case "$(uname -s)" in
Darwin) GODOT_DATA_DIR="$HOME/Library/Application Support/Godot" ;;
Linux) GODOT_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot" ;;
*) GODOT_DATA_DIR="${APPDATA:-$HOME/AppData/Roaming}/Godot" ;;
esac

PROJECTS_FILE="$GODOT_DATA_DIR/projects.cfg"
SECTION="[$PROJECT_PATH]"

if [[ "$ACTION" != "add" && "$ACTION" != "remove" ]]; then
  echo "usage: godot-projects.sh add|remove [project path]" >&2
  exit 1
fi

# The root checkout is a permanent entry, only worktrees come and go
if [[ "$PROJECT_PATH" == "$ROOT_PATH" ]]; then
  [[ "$ACTION" == "remove" ]] && echo "godot-projects: no worktree path given (set ORCA_WORKTREE_PATH)" >&2
  exit 0
fi

# Godot greys out anything else as a missing project, so don't add it at all
if [[ ! -f "$PROJECT_PATH/project.godot" ]]; then
  echo "godot-projects: $PROJECT_PATH has no project.godot, skipping" >&2
  exit 0
fi

is_listed() {
  [[ -f "$PROJECTS_FILE" ]] && grep -qxF "$SECTION" "$PROJECTS_FILE"
}

if [[ "$ACTION" == "add" ]]; then
  is_listed && exit 0
  mkdir -p "$GODOT_DATA_DIR"
  printf '\n%s\nfavorite=false\n' "$SECTION" >>"$PROJECTS_FILE"
  exit 0
fi

is_listed || exit 0

# Drop the section, its keys and the blank line above it, leaving every other project untouched
TMP_FILE="$(mktemp)"
awk -v section="$SECTION" '
  { line[NR] = $0 }
  $0 == section { skip = 1 }
  $0 != section && /^\[/ { skip = 0 }
  skip { drop[NR] = 1; if (line[NR - 1] == "") { drop[NR - 1] = 1 } }
  END { for (i = 1; i <= NR; i++) if (!drop[i]) { print line[i] } }
' "$PROJECTS_FILE" >"$TMP_FILE"
mv "$TMP_FILE" "$PROJECTS_FILE"
