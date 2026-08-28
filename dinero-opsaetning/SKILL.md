---
name: dinero-opsaetning
description: >
  Opsætningsguide til Dineros officielle MCP-server (beta): forbind Claude eller en
  anden AI-assistent til Dinero-regnskabet via https://mcp.dinero.dk/mcp med Visma
  Connect-login. Brug denne skill når brugeren vil koble AI/Claude på Dinero, nævner
  "Dinero MCP", "forbind Dinero", "Dinero connector", spørger hvorfor Dinero-tools
  ikke virker, eller vil fjerne/styre adgangen igen. Kræver Dinero Pro eller Total.
license: MIT
---

# Dinero-opsætning — forbind AI-assistenten til Dinero

## Krav

- Dinero-abonnement med **Pro eller Total** (ikke tilgængelig på Starter).
- En MCP-kompatibel AI-klient: Claude (claude.ai, Claude Desktop, Claude Code),
  ChatGPT m.fl.
- Serveren er i **beta**: funktioner kan tilføjes, ændres eller fjernes uden varsel.

## Endpoint

```
https://mcp.dinero.dk/mcp
```

Login via **Visma Connect** med brugerens eget Dinero-login. Assistenten arbejder
med brugerens egne rettigheder og får adgang til alle organisationer, logins er
knyttet til — man får ikke adgang til mere end man har i forvejen.

## Tilslutning i Claude

**claude.ai / Claude Desktop:** Indstillinger → Connectors → "Add custom
connector" → indsæt URL'en → gennemfør Visma Connect-login.

**Claude Code:**

```bash
claude mcp add --transport http dinero https://mcp.dinero.dk/mcp
```

Første brug udløser OAuth-login i browseren (eller kør `/mcp` i en interaktiv
session).

## Fjern adgangen igen

- I AI-klientens connector-/MCP-indstillinger, eller
- i Dinero: **Konto → Brugerprofil → Gå til Visma Connect** → fjern appens adgang.

## Fortæl brugeren ved opsætning

- Assistenten kan **skrive** i regnskabet. Aftal arbejdsformen: alt oprettes som
  kladde og bogføres først efter godkendelse (standard i alle dinero-skills).
- Brugeren bærer ansvaret for regnskabet — AI kan blande moms-/skatteregler
  sammen; verificér vigtige spørgsmål hos SKAT eller revisor.
- Regnskabsdata er person- og forretningsdata: overvej databehandleraftale hos
  AI-leverandøren. Dineros betingelser:
  https://dinero.dk/sikkerhed/betingelser-mcp/
- Rammer man en serverfejl: skriv "Send ovenstående til Dinero som feedback" — så
  oprettes et issue direkte hos Dinero-teamet.

## Første testtur (uden risiko — kun læsning)

1. "Hvilke organisationer har jeg adgang til?"
2. "Vis kontoplanen"
3. "Træk saldobalancen for i år"

Skriv-test uden skade: opret en faktura-KLADDE, se den, og slet kladden igen.
Bogfør ALDRIG et testdokument — fakturanumre forbruges permanent.

## Grundregler (fælles for alle Dinero-skills)

Du arbejder i en rigtig virksomheds rigtige regnskab via Dineros officielle
MCP-server (beta). Arbejd som en omhyggelig bogholder: forstå, foreslå, få accept,
udfør, verificér.

1. **Kladde først — bogfør aldrig uden eksplicit accept.** Bogført er reelt
   permanent: via MCP kan bogførte dokumenter ikke slettes, og sletter brugeren
   dem i Dineros UI, er fakturanummeret alligevel forbrugt. Vis brugeren præcis hvad du
   har lavet (beløb, konto, momskode, dato, modpart) før der bogføres. Kladder kan
   slettes — bogfør aldrig noget "for at prøve".
2. **Verificér efter skrivning.** Frisk opslag efter enhver oprettelse/bogføring —
   rapportér det du faktisk ser, ikke det du forventede.
3. **Vælg rigtig organisation.** Har brugerens login adgang til flere virksomheder,
   så bekræft ALTID hvilken der arbejdes i, før du skriver noget.
4. **Beta: gæt aldrig tools.** Orientér dig i de faktisk tilgængelige Dinero-tools
   før du planlægger. Ingen Dinero-tools? Så er forbindelsen ikke sat op — guide:
   tilføj `https://mcp.dinero.dk/mcp` som connector (login via Visma Connect,
   kræver Dinero Pro/Total) — og stop der; lad som om intet er udført.
5. **MCP v1 kan:** slå fakturaer/kontakter/produkter/kontoplan op; oprette og
   bogføre fakturaer, kreditnotaer, køb og kassekladder; registrere betalinger;
   hente bilag som PDF; uploade til bilagsarkivet; trække saldobalance og
   kontospecifikation. **Kan bevidst IKKE:** sende fakturaer, hente bankdata eller
   læse ubogførte kassekladde-linjer — og rapporter viser kun bogført materiale.
6. **Beløbsfælden:** købsbilag og kassekladde-linjer angives **inkl. moms**;
   salgsfaktura-linjer angives **ekskl. moms**. Vis altid begge tal.
7. **Flag i stedet for at gætte** ved uklare betalinger og skarpe fradragsregler —
   og vær ærlig om at AI kan blande moms-/skatteregler sammen; henvis til
   SKAT/revisor ved tvivl. Brugeren bærer ansvaret for regnskabet.
8. **Fejl på serveren?** Brugeren kan skrive "Send ovenstående til Dinero som
   feedback" — så oprettes et issue direkte hos Dinero-teamet.
9. **Dineros eget UI vinder over manuelt arbejde.** Har Dinero en indbygget
   funktion til opgaven — rykkere, momsindberetning til SKAT, automatisk
   bankafstemning, fakturaafsendelse, integrationer til løn/webshop/kørsel — så
   er den vejen. Din værdi er dømmekraften omkring den: kontrollér grundlaget
   før knappen trykkes, tag det funktionen ikke kan matche, og forklar tallene
   bagefter. Byg aldrig en manuel omvej rundt om en funktion brugeren allerede
   har og betaler for.
