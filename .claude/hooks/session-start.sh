#!/bin/bash
set -euo pipefail

# Registers every skill under .agents/skills/ (installed via `npx skills add`)
# into Claude Code's user-level skills directory, so they're available via the
# Skill tool from the very first turn of every new session on this branch,
# instead of only after a fresh session is started following an install.

SKILLS_SRC="${CLAUDE_PROJECT_DIR:-$(pwd)}/.agents/skills"
SKILLS_DEST="$HOME/.claude/skills"

mkdir -p "$SKILLS_DEST"

if [ -d "$SKILLS_SRC" ]; then
  for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_dir="${skill_dir%/}"
    name="$(basename "$skill_dir")"
    target="$SKILLS_DEST/$name"

    # Don't clobber a real (non-symlink) directory that might already be
    # there (e.g. a platform-provided built-in skill of the same name).
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Skipping $name: $target already exists and is not a symlink" >&2
      continue
    fi

    ln -sfn "$skill_dir" "$target"
  done
fi
