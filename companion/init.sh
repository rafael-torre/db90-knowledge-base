#!/bin/bash

# init.sh
# Wires the DB90 companion system into Cursor.
# Copies companion files to .cursor/, creates .companion.yaml from the example if absent,
# and adds gitignore entries. Safe to re-run after updates.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_DIR="${REPO_ROOT}/.cursor"
COMPANION_DIR="${REPO_ROOT}/companion"

echo "🔧 Initializing DB90 Companion System..."
echo "Repo root: $REPO_ROOT"
echo ""

# Create .cursor directory if it doesn't exist
mkdir -p "$CURSOR_DIR"

# 1. Copy companion rules
echo "📋 Installing rules..."
mkdir -p "$CURSOR_DIR/rules"
cp "$COMPANION_DIR/rules/db90-companion.mdc" "$CURSOR_DIR/rules/db90-companion.mdc"
echo "   ✓ db90-companion.mdc"

# 2. Copy companion hooks
echo "🪝 Installing hooks..."
mkdir -p "$CURSOR_DIR/hooks"
cp "$COMPANION_DIR/hooks/scan-project-state.sh" "$CURSOR_DIR/hooks/scan-project-state.sh"
chmod +x "$CURSOR_DIR/hooks/scan-project-state.sh"
echo "   ✓ scan-project-state.sh"

cp "$COMPANION_DIR/hooks/update-metadata.sh" "$CURSOR_DIR/hooks/update-metadata.sh"
chmod +x "$CURSOR_DIR/hooks/update-metadata.sh"
echo "   ✓ update-metadata.sh"

# 3. Install hooks.json
echo "⚙️  Installing hooks.json..."
cp "$COMPANION_DIR/hooks.json" "$CURSOR_DIR/hooks.json"
echo "   ✓ hooks.json"

# 4. Copy companion-level skills
echo "🎯 Installing companion skills..."
mkdir -p "$CURSOR_DIR/skills"

cp -r "$COMPANION_DIR/skills/scan-project-state" "$CURSOR_DIR/skills/scan-project-state"
echo "   ✓ scan-project-state"

cp -r "$COMPANION_DIR/skills/session-handoff" "$CURSOR_DIR/skills/session-handoff"
echo "   ✓ session-handoff"

# 5. Copy layer-specific skills
echo "🏗️  Installing layer-specific skills..."

if [[ -d "$REPO_ROOT/layers/layer-1-product/tools/draft-feature-spec" ]]; then
    cp -r "$REPO_ROOT/layers/layer-1-product/tools/draft-feature-spec" "$CURSOR_DIR/skills/draft-feature-spec"
    echo "   ✓ draft-feature-spec (Layer 1)"
fi

if [[ -d "$REPO_ROOT/layers/layer-2-design/tools/draft-design-spec" ]]; then
    cp -r "$REPO_ROOT/layers/layer-2-design/tools/draft-design-spec" "$CURSOR_DIR/skills/draft-design-spec"
    echo "   ✓ draft-design-spec (Layer 2)"
fi

if [[ -d "$REPO_ROOT/layers/layer-3-architecture/tools/draft-technical-spec" ]]; then
    cp -r "$REPO_ROOT/layers/layer-3-architecture/tools/draft-technical-spec" "$CURSOR_DIR/skills/draft-technical-spec"
    echo "   ✓ draft-technical-spec (Layer 3)"
fi

# 6. Create .companion.yaml if it doesn't exist
echo ""
echo "🔐 Configuring companion..."
if [[ ! -f "$REPO_ROOT/.companion.yaml" ]]; then
    cp "$COMPANION_DIR/.companion.yaml.example" "$REPO_ROOT/.companion.yaml"
    echo "   ✓ Created .companion.yaml (edit with your name and role)"
else
    echo "   ℹ️  .companion.yaml already exists (skipping)"
fi

# 7. Update .gitignore
echo ""
echo "📝 Updating .gitignore..."

GITIGNORE_FILE="${REPO_ROOT}/.gitignore"
ENTRIES_TO_ADD=(
    ".companion.yaml"
    ".cursor/session-state.md"
    ".cursor/session-handoff.md"
)

for entry in "${ENTRIES_TO_ADD[@]}"; do
    if ! grep -q "^${entry}$" "$GITIGNORE_FILE" 2>/dev/null; then
        echo "$entry" >> "$GITIGNORE_FILE"
        echo "   ✓ Added $entry"
    else
        echo "   ℹ️  $entry already in .gitignore"
    fi
done

echo ""
echo "✅ DB90 Companion System initialized!"
echo ""
echo "Next steps:"
echo "1. Edit .companion.yaml with your name and role"
echo "2. Restart Cursor to activate the companion rule"
echo "3. The session-start hook will run on next session, generating .cursor/session-state.md"
echo ""
echo "For help, see: companion/README.md"
