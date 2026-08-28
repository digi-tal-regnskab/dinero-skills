---
name: dinero-debitorafstemning
description: >
  Debitorafstemning i Dinero via Dineros officielle MCP-server: afstem summen af åbne
  salgsfakturaer mod debitorsamlekontoen i saldobalancen, forklar differencer postering
  for postering, og levér en aldersfordelt debitorliste. Brug denne skill når brugeren
  nævner debitorafstemning, debitorer, tilgodehavender, aldersfordeling, "stemmer mine
  debitorer?" eller vil vide præcis hvem der skylder hvad i dansk Dinero-kontekst.
license: MIT
---

# Dinero-debitorafstemning

To uafhængige kilder skal vise samme tal, og enhver difference skal forklares
med konkrete posteringer — ikke bare konstateres. Afstemningen bygger altid på
en **afgrænset periode (helår eller delperiode)** og har to lag: den interne
kontrol (fakturaliste mod samlekonto) og den eksterne tovejs-diff mod et
**udtog fra modparten** — kundens kontoudtog. Det eksterne lag er det stærkeste;
bed om udtoget når saldoen betyder noget (store kunder, tvister, årsafslutning).

**Kør én modpart ad gangen.** En afstemning af alle debitorer på én gang drukner
i støj — vælg kunden (typisk den største eller den med uenighed), afstem den til
bunds, og tag så den næste. Debitorsamlekontoen i standardkontoplanen er
**53000**.

## Arbejdsgang

1. Spørg først: ligger der ubogførte kladder i perioden? (Rapporter viser kun
   bogført — ellers afstemmer du mod et ufuldstændigt tal.)
2. Hent alle salgsfakturaer med åben status (bogførte, ikke betalte — inkl.
   forfaldne). Filtrér kladder fra (kæmpe pladsholder-numre).
3. Summér åbne beløb pr. kunde og totalt.
4. Sammenlign totalen med **debitorsamlekontoen** i saldobalancen pr. samme dato.
5. Difference? Hent kontospecifikationen for samlekontoen og find posteringerne
   der ikke modsvares af en faktura/betaling. Typiske årsager:
   - betalinger registreret uden om fakturaen (direkte på samlekontoen)
   - kreditnotaer der ikke er modregnet (husk: de ses ikke altid i fakturalister)
   - manuelle posteringer på samlekontoen
   - fakturaer bogført i en anden periode end afstemningsdatoen.
6. Levér en aldersfordelt oversigt (ikke forfaldet / 1-30 / 31-60 / 60+ dage) —
   det er den brugeren kan handle på. **Rykkerne selv hører til i Dineros
   rykker-modul**, som beregner renter og gebyrer korrekt og sender dem. Din
   opgave er at gøre listen troværdig først: fejlplacerede betalinger,
   umodregnede kreditnotaer og kendte tvister skal ryddes af vejen, så der ikke
   rykkes på forkert grundlag.

## Tovejs-diff mod kundens kontoudtog (det stærke lag)

Bed brugeren skaffe et **kontoudtog fra kunden** (kundens bogholderi) for
perioden, og match post for post:

- **Fakturaer i Dinero som kunden ikke kender** → aldrig modtaget (send igen
  fra Dineros UI), eller en dublet/fejl der skal krediteres.
- **Betalinger kunden har afsendt som ikke er registreret i Dinero** → find dem
  i banken; typisk en betaling registreret på forkert faktura eller konto.
- **Poster på kundens udtog uden modstykke i Dinero** → mangler i Dinero
  (fx en aftalt kreditnota der aldrig blev oprettet).

Resultat i tre bunker: **mangler i Dinero**, **bogført for meget i Dinero**, og
den åbne saldo begge parter er enige om. Uenighed om saldoen er afklaret, når
hver difference-post har en forklaring.

## Difference-jagten: krydstjek mod indbetalingerne

Når en difference er fundet, så led efter den i betalingsstrømmen — det er dér
den næsten altid gemmer sig:

1. **Bogførte indbetalinger:** gennemgå betalingsregistreringerne og
   posteringerne på 53000/bankkontoen for perioden — er kundens betaling
   registreret på en forkert faktura eller en forkert kunde?
2. **Ubogførte indbetalinger:** bed om kassekladde-eksporten (bankimport →
   eksportér, jf. `/dinero-bogfoering`) og led efter kundens indbetaling blandt
   de endnu ubogførte banklinjer — betalingen kan være landet i banken uden at
   nogen har registreret den.
3. Først når begge spor er tømt, er differencen reel (fx en faktura kunden
   aldrig har modtaget, eller en aftalt kreditnota der mangler).

## Rapportering

```
## Debitorafstemning pr. <dato>
| Kontrol | Fakturaliste | Samlekonto | Difference | Status |
```
Status: stemmer / difference forklaret (med forklaring) / uafklaret. Foreslåede
rettelser oprettes som kladde og bogføres først efter accept.

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
