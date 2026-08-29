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
claude mcp add --scope user --transport http dinero https://mcp.dinero.dk/mcp
```

`--scope user` er vigtig: uden den lander serveren i *local* scope og virker kun
i den mappe, kommandoen blev kørt i. Regnskabet skal typisk være tilgængeligt i
alle projekter.

Derefter **login**: kør `/mcp` i en **interaktiv** `claude`-session, vælg dinero
og gennemfør Visma Connect i browseren. Login kan ikke gennemføres i en
non-interaktiv session (fx `claude -p`, et script eller en baggrundsagent) —
serveren kan tilføjes, men status forbliver "Needs authentication", indtil nogen
logger ind interaktivt én gang. Efter det virker forbindelsen også i
non-interaktive sessioner.

Verificér undervejs: `claude mcp get dinero` viser scope og status, og et kald
mod endpointet uden token svarer korrekt `HTTP 401` (= serveren lever, login
mangler).

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

## Det brugeren selv skal gøre i Dinero

MCP'en kan skrive bilag, men ikke ændre regnskabets rammer. Rammer du et af
disse, så stop, forklar hvorfor, og bed brugeren gøre det i Dineros UI — fortsæt
først når det er bekræftet gjort:

- **Oprette eller ændre konti i kontoplanen** (Indstillinger → Kontoplan) —
  fx en mellemregningskonto, en skattekonto eller en mellemkonto pr. indløser.
- **Oprette et regnskabsår** (Indstillinger → Regnskabsår). Uden året afvises
  enhver postering med den dato.
- **Oprette aktiver i anlægskartoteket**, som afskrivningerne kører fra.
- **Sende fakturaer og kreditnotaer** (kun tilbud kan sendes via MCP).

Find aldrig en vej udenom ved at bruge en tilfældig eksisterende konto — det
flytter bare fejlen ind i regnskabet.

## Grundregler (fælles for alle Dinero-skills)

Du arbejder i en rigtig virksomheds rigtige regnskab via Dineros officielle
MCP-server (beta). Arbejd som en omhyggelig bogholder: forstå, foreslå, få accept,
udfør, verificér.

1. **Kladde først — bogfør aldrig uden eksplicit accept.** Bogført er reelt
   permanent: via MCP kan bogførte dokumenter ikke slettes, og sletter brugeren
   dem i Dineros UI, er fakturanummeret alligevel forbrugt. Vis brugeren præcis hvad du
   har lavet (beløb, konto, momskode, dato, modpart) før der bogføres. Kladder kan
   slettes — dog kan finansbilag-kladder kun slettes i Dineros UI, ikke via MCP —
   og bogfør aldrig noget "for at prøve".
2. **Verificér efter skrivning.** Frisk opslag efter enhver oprettelse/bogføring —
   rapportér det du faktisk ser, ikke det du forventede.
3. **Vælg rigtig organisation.** Har brugerens login adgang til flere virksomheder,
   så bekræft ALTID hvilken der arbejdes i, før du skriver noget.
4. **Beta: gæt aldrig tools.** Orientér dig i de faktisk tilgængelige Dinero-tools
   før du planlægger. Ingen Dinero-tools? Så er forbindelsen ikke sat op — guide:
   tilføj `https://mcp.dinero.dk/mcp` som connector (login via Visma Connect,
   kræver Dinero Pro/Total) — og stop der; lad som om intet er udført.
5. **Hvad MCP'en kan — og ikke kan.**
   **Opslag:** organisationer, kontakter, produkter, kontoplan (og den separate
   købskontoliste), momskoder, regnskabsår, salgsfakturaer og -kreditnotaer
   (filtrérbart på status og dato), kontoudtog pr. kontakt, posteringer i et
   datointerval, og bilagsarkivets filer — herunder hvilke der endnu er ubrugte,
   og den smart-scannede købskladde en fil har affødt.
   **Skrivning:** oprette og bogføre salgsfakturaer, salgs- og købskreditnotaer,
   købsbilag og finansbilag; registrere ind- og udbetalinger; oprette og rette
   kontakter; oprette produkter; uploade bilag; slette **kladder**.
   **Tilbud:** oprette, liste, **sende** og konvertere til faktura.
   **Kan IKKE:** sende fakturaer og kreditnotaer (kun tilbud kan sendes); hente
   bankdata; læse ubogførte kassekladde-linjer (købs- og fakturakladder kan
   derimod godt læses); oprette eller ændre konti i kontoplanen; oprette
   regnskabsår; slette bogført materiale.
   **Rapport-fælden:** resultat, balance og saldobalance kan kun trækkes for et
   **helt regnskabsår** — ikke en vilkårlig periode. Skal du bruge en måned eller
   et kvartal, byg tallet af posteringslisten, som til gengæld kun kan spænde over
   ét regnskabsår ad gangen. Rapporter viser kun bogført materiale.
6. **Beløbsfælden:** købsbilag og kassekladde-linjer angives **inkl. moms**;
   salgsfaktura-linjer angives **ekskl. moms**. Vis altid begge tal.
   I finansbilag skal momskoden sidde på linjens **hovedkonto** — en momskode på
   modkontoen bliver IKKE beregnet (kladden viser moms 0). Vend i stedet
   retningen med et negativt beløb (fx salg som minus på omsætningskontoen), og
   verificér ALTID kladdens momssplit med et frisk opslag, FØR der bogføres.
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
