#!/usr/bin/env bash
# dinero-skills — installér skills + forbind Dineros MCP-server.
# Brug:  ./install.sh          (installerer alle moduler)
#        ./install.sh bogfoering momskontrol   (kun udvalgte)
set -euo pipefail

ENDPOINT="https://mcp.dinero.dk/mcp"
SKILLS_DIR="$HOME/.claude/skills"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

grøn() { printf '\033[32m%s\033[0m\n' "$1"; }
gul()  { printf '\033[33m%s\033[0m\n' "$1"; }
fed()  { printf '\033[1m%s\033[0m\n' "$1"; }

echo
fed "dinero-skills — installation"
echo

# 1) Skills ------------------------------------------------------------------
if [ $# -gt 0 ]; then
  MODULER=()
  for m in "$@"; do MODULER+=("$SRC/dinero-${m#dinero-}"); done
else
  MODULER=("$SRC"/dinero-*/)
fi

mkdir -p "$SKILLS_DIR"
antal=0
for mappe in "${MODULER[@]}"; do
  mappe="${mappe%/}"
  navn="$(basename "$mappe")"
  if [ ! -f "$mappe/SKILL.md" ]; then
    gul "  ⚠ springer over: $navn (ingen SKILL.md)"
    continue
  fi
  rm -rf "${SKILLS_DIR:?}/$navn"
  cp -R "$mappe" "$SKILLS_DIR/$navn"
  antal=$((antal + 1))
done
grøn "  ✓ $antal moduler installeret i $SKILLS_DIR"

# 2) MCP-serveren ------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  gul "  ⚠ 'claude' blev ikke fundet i PATH — spring MCP-opsætningen over."
  gul "    Bruger du claude.ai eller Claude Desktop: tilføj $ENDPOINT"
  gul "    under Indstillinger → Connectors → Add custom connector."
  exit 0
fi

if claude mcp get dinero >/dev/null 2>&1; then
  grøn "  ✓ Dinero-serveren er allerede tilføjet"
else
  claude mcp add --scope user --transport http dinero "$ENDPOINT" >/dev/null
  grøn "  ✓ Dinero-serveren tilføjet (user scope — virker i alle projekter)"
fi

# 3) Login -------------------------------------------------------------------
status="$(claude mcp get dinero 2>/dev/null | grep -i '^ *Status:' || true)"
echo
if echo "$status" | grep -qi 'connected'; then
  grøn "  ✓ Forbindelsen er aktiv — du er klar."
  echo
  echo "  Prøv:  claude   →   \"Vis saldobalancen for i år\""
else
  fed "  Ét trin tilbage: login hos Visma Connect"
  echo
  echo "    1.  claude          (start en interaktiv session)"
  echo "    2.  /mcp            (vælg 'dinero' og log ind i browseren)"
  echo
  echo "  Login kan kun gøres interaktivt én gang — derefter virker"
  echo "  forbindelsen også i scripts og baggrundssessioner."
  echo
  gul "  OBS: Dineros MCP kræver abonnementet Pro eller Total."
fi
echo
