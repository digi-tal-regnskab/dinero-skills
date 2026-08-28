# dinero-skills — Claude-skills til Dineros MCP-server

En samling [agent-skills](https://code.claude.com/docs/en/skills), der gør Claude
til en omhyggelig dansk bogholder-assistent oven på
[Dineros officielle MCP-server](https://dinero.dk/funktioner/mcp/) (beta).

Dineros MCP giver din AI-assistent adgang til dit regnskab — men uden faglige
rammer bogfører en AI gerne først og spørger bagefter. Disse skills lægger rammerne
på: **kladde først, bogfør aldrig uden accept, verificér alt, flag i stedet for at
gætte** — plus danske konteringsregler, momskoder og Dineros vigtigste fælder
(den permanente nummerserie, beløb inkl./ekskl. moms, rapporter der kun viser
bogført materiale).

**Skills'ene genopfinder ikke Dinero.** Rykkere, momsindberetning til SKAT,
automatisk bankafstemning, fakturaafsendelse og integrationer til løn, webshop og
kørsel klarer Dinero allerede selv — bedre end nogen manuel omvej. Modulerne peger
dig derhen og bruger i stedet kræfterne på dømmekraften omkring dem: er grundlaget
rigtigt, før du trykker? Hvad kunne automatikken ikke matche? Hvad betyder tallene
bagefter?

Hver skill er sit eget modul og sin egen kommando. Installér alle, eller kun de
moduler du bruger — hvert modul er selvstændigt og indeholder de fælles grundregler.

## Modulerne

| Kommando | Gør |
|---|---|
| `/dinero-opsaetning` | Forbind AI-assistenten til Dinero (endpoint, Visma Connect, sikkerhed) |
| `/dinero-overblik` | Saldobalance, rapporter, ubetalte fakturaer, "hvordan går det?" |
| `/dinero-bogfoering` | Kassekladde-eksport → dokumentations-gatet bogføring; aflæser også valutabilag |
| `/dinero-fakturering` | Fakturaer, kreditnotaer, betalingsregistrering, forfaldne fakturaer |
| `/dinero-bankafstemning` | Tovejs-diff: fuldt bankudtog mod kontoplanen — mangler/bogført for meget |
| `/dinero-debitorafstemning` | Samlekonto-kontrol + tovejs-diff mod kundens kontoudtog |
| `/dinero-leverandoerafstemning` | Samlekonto-kontrol + tovejs-diff mod leverandørens kontoudtog |
| `/dinero-momskontrol` | Kvalitetssikring af momsgrundlaget før du trykker indberet i Dinero |
| `/dinero-skattekonto-afstemning` | Skattekontoen hos SKAT mod skyldig-konti og bogholderi |
| `/dinero-loenafstemning` | Løn mod lønsystem, eIndkomst (felt 0013/0015/0016/0046) og bank |
| `/dinero-bilagskontrol` | Ubogførte bilag/udlæg + bogførte posteringer uden dokumentation |
| `/dinero-udlaegstjek` | Krydser bank + posteringer + arkiv og finder alle udlægs-huller |
| `/dinero-mellemregning` | Mellemregning med ejer/holding + kapitalejerlåns-flag |
| `/dinero-maanedsluk` | Hele månedslukningstjeklisten i én samlet rapport |
| `/dinero-aarsafslutning` | Primo-kontrol, periodisering, efterposteringer — årsrapport-klar |
| `/dinero-anlaegsaktiver` | Aktivér eller straksafskriv, ind i Dineros kartotek, kartotek ↔ balance |
| `/dinero-webshopafstemning` | Salg ↔ indløser-afregning ↔ bank, mellemkonto-nulstilling |
| `/dinero-konvertering` | Flyt til Dinero fra e-conomic/Billy m.fl. — åbningsbalance eller fuld historik |

## Krav

- Dinero **Pro eller Total** (MCP-serveren er ikke tilgængelig på Starter).
- En Claude-klient med skill-understøttelse: Claude Code, Claude Desktop eller
  claude.ai.

## Installation

### 1. Forbind Dineros MCP-server

**claude.ai / Claude Desktop:** Indstillinger → Connectors → *Add custom connector* →
`https://mcp.dinero.dk/mcp` → log ind via Visma Connect.

**Claude Code:**

```bash
claude mcp add --transport http dinero https://mcp.dinero.dk/mcp
```

### 2. Installér skills

**Claude Code — alle moduler:**

```bash
git clone https://github.com/digi-tal-regnskab/dinero-skills.git
cp -r dinero-skills/dinero-* ~/.claude/skills/
```

**Claude Code — kun udvalgte moduler:** kopiér blot de mapper du vil have.

**claude.ai / Claude Desktop:** zip den enkelte modulmappe (fx
`dinero-bankafstemning/`) og upload den under Indstillinger → Capabilities →
Skills.

### 3. Brug dem

Skills aktiverer sig selv ud fra det du beder om ("bogfør de her tre
kvitteringer", "hvem skylder mig penge?", "afstem min moms for 2. kvartal") — eller
kald et modul direkte med dets kommando, fx `/dinero-maanedsluk`.

## Vigtigt om ansvar og sikkerhed

- Du bærer selv ansvaret for dit regnskab. AI-assistenter kan blande momsregler og
  satser sammen — modulerne instruerer Claude i at flage usikkerhed, men verificér
  altid væsentlige skatte- og momsspørgsmål hos SKAT eller din revisor.
- Assistenten arbejder med dit eget Dinero-login og dine egne rettigheder. Adgangen
  kan altid fjernes igen i Dinero under Konto → Brugerprofil → Visma Connect.
- Dineros MCP-server er i beta og kan ændre sig uden varsel. I første version kan
  den bevidst **ikke** sende fakturaer eller hente bankdata — modulerne kender
  begrænsningerne og arbejder udenom dem (bankdata leveres via kassekladde-eksport).
- Læs Dineros egne [MCP-betingelser](https://dinero.dk/sikkerhed/betingelser-mcp/).

## Uofficiel

Dette projekt er ikke tilknyttet, godkendt af eller supporteret af Dinero eller
Visma. "Dinero" er Visma Dinero A/S' varemærke. Fejl i og brug af disse skills er
på eget ansvar.

## Struktur

```
dinero-<modul>/
├── SKILL.md              # Modulets arbejdsgang + fælles grundregler
└── references/           # (hvor relevant) fx kontering-og-moms.md
```

Grundreglerne (kladde-først, verifikation, beløbsfælden, v1-begrænsninger) er
indlejret i hvert modul, så et enkelt modul også virker alene.

## Bidrag

Issues og pull requests er velkomne — især nye kontering-mønstre, rettelser når
Dineros beta ændrer sig, forslag til nye moduler og erfaringer fra andre
MCP-klienter. Planlagte/manglende moduler er kortlagt i [ROADMAP.md](ROADMAP.md).

## Licens

MIT — se [LICENSE](LICENSE).
