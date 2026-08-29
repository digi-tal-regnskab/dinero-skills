#!/usr/bin/env bash
# dinero-skills — installér skills + forbind Dineros MCP-server.
# Brug:  ./install.sh                        (installerer alle moduler)
#        ./install.sh bogfoering momskontrol  (kun udvalgte)
#        ./install.sh --plugin                (namespacet: /dinero-skills:<modul>)
#
# --plugin bruges når et af modulnavnene allerede er optaget af en af dine
# egne skills. Plugin-moduler får deres eget navnerum og kan derfor IKKE
# overskrive noget; det bare navn virker stadig for de moduler, hvor det er ledigt.
set -euo pipefail

ENDPOINT="https://mcp.dinero.dk/mcp"
SKILLS_DIR="$HOME/.claude/skills"
PLUGIN_NAVN="dinero-skills"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PLUGIN=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --plugin) PLUGIN=1 ;;
    *) ARGS+=("$a") ;;
  esac
done
set -- ${ARGS+"${ARGS[@]}"}

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

if [ "$PLUGIN" -eq 1 ]; then
  # Namespacet installation — kan ikke kollidere med eksisterende skills.
  MAAL="$SKILLS_DIR/$PLUGIN_NAVN"
  rm -rf "${MAAL:?}"
  mkdir -p "$MAAL/.claude-plugin" "$MAAL/skills"
  cat > "$MAAL/.claude-plugin/plugin.json" <<JSON
{
  "name": "$PLUGIN_NAVN",
  "description": "Danske bogholder-moduler til Dineros officielle MCP-server: bogføring, afstemninger, momskontrol, månedsluk, årsafslutning og konvertering.",
  "version": "1.0.0",
  "homepage": "https://github.com/digi-tal-regnskab/dinero-skills"
}
JSON
  antal=0
  for mappe in "${MODULER[@]}"; do
    mappe="${mappe%/}"; navn="$(basename "$mappe")"
    [ -f "$mappe/SKILL.md" ] || { gul "  ⚠ springer over: $navn (ingen SKILL.md)"; continue; }
    cp -R "$mappe" "$MAAL/skills/$navn"
    antal=$((antal + 1))
  done
  grøn "  ✓ $antal moduler installeret som pluginet '$PLUGIN_NAVN'"
  echo "    Kald dem /$PLUGIN_NAVN:<modul> — eller bare /<modul>, hvor navnet er ledigt."
  echo "    Kør /reload-plugins i en aktiv session for at aktivere med det samme."
else
  antal=0; konflikt=0
  for mappe in "${MODULER[@]}"; do
    mappe="${mappe%/}"
    navn="$(basename "$mappe")"
    if [ ! -f "$mappe/SKILL.md" ]; then
      gul "  ⚠ springer over: $navn (ingen SKILL.md)"
      continue
    fi
    # Overskriv ALDRIG en skill vi ikke selv har installeret: den kan indeholde
    # andres arbejde (scripts, state, bilag), og cp'en her sletter mappen først.
    if [ -e "$SKILLS_DIR/$navn" ] && [ ! -f "$SKILLS_DIR/$navn/.dinero-skills" ]; then
      gul "  ⚠ SPRINGER OVER: $navn — der findes allerede en skill med det navn."
      konflikt=$((konflikt + 1))
      continue
    fi
    rm -rf "${SKILLS_DIR:?}/$navn"
    cp -R "$mappe" "$SKILLS_DIR/$navn"
    : > "$SKILLS_DIR/$navn/.dinero-skills"
    antal=$((antal + 1))
  done
  grøn "  ✓ $antal moduler installeret i $SKILLS_DIR"
  if [ "$konflikt" -gt 0 ]; then
    echo
    gul "  $konflikt modul(er) blev sprunget over for ikke at overskrive dine egne skills."
    gul "  Kør './install.sh --plugin' for at installere ALLE moduler namespacet i stedet"
    gul "  — så kan de ikke kollidere, og dine egne skills bliver urørt."
  fi
fi

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
