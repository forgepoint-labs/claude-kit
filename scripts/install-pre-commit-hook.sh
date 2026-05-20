#!/bin/bash
# Installs the separation-audit script as a git pre-commit hook.
# Run once after cloning the repo.

set -e

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"
AUDIT_SCRIPT=".github/scripts/separation-audit.sh"

if [ ! -d "$HOOK_DIR" ]; then
  echo "❌ Not inside a git repo (no .git/hooks directory found)."
  exit 1
fi

if [ ! -f "$AUDIT_SCRIPT" ]; then
  echo "❌ $AUDIT_SCRIPT not found."
  exit 1
fi

cat > "$HOOK_FILE" <<'EOF'
#!/bin/bash
# Pre-commit hook:
#   1. Regenerate skills/ mirror from plugins/*/skills/*/SKILL.md and
#      restage any changes so the mirror is always in sync.
#   2. Block client or employer content from reaching the public repo.
set -e
ROOT="$(git rev-parse --show-toplevel)"
if [ -x "$ROOT/scripts/sync-skills.sh" ]; then
  bash "$ROOT/scripts/sync-skills.sh" >/dev/null
  git add "$ROOT/skills" 2>/dev/null || true
fi
bash "$ROOT/.github/scripts/separation-audit.sh" staged
EOF

chmod +x "$HOOK_FILE"
chmod +x "$AUDIT_SCRIPT"

echo "✅ Pre-commit hook installed at $HOOK_FILE"
echo "   Runs sync-skills.sh + separation-audit.sh on every commit."
