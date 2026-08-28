---
name: dinero-leverandoerafstemning
description: >
  Leverandørafstemning (kreditorafstemning) i Dinero via Dineros officielle
  MCP-server: afstem åbne købsbilag mod kreditorsamlekontoen, match mod leverandørens
  kontoudtog, og find manglende omkostningsbilag — den hyppigste fejl i små
  virksomheder. Brug denne skill når brugeren nævner leverandørafstemning,
  kreditorafstemning, kreditorer, leverandørkontoudtog, skyldige leverandører eller
  "stemmer mine kreditorer?" i dansk Dinero-kontekst.
license: MIT
---

# Dinero-leverandørafstemning (kreditorer)

En leverandørafstemning **kræver leverandørens kontoudtog** — uden udtoget kan
kun den interne sandsynlighedskontrol (åbne købsbilag mod samlekontoen) køres,
og det skal siges ærligt. Afstemningen bygger altid på en **afgrænset periode
(helår eller delperiode)**, og køres **én leverandør ad gangen** — vælg den
største eller den med uenighed, afstem til bunds, tag så den næste.
Kreditorsamlekontoen i standardkontoplanen er **63000**.

## Arbejdsgang (internt lag)

1. Spørg først om ubogførte kladder i perioden (rapporter viser kun bogført).
2. Hent åbne købsbilag (bogførte, ikke betalte) og summér pr. leverandør.
3. Sammenlign med **kreditorsamlekontoen** i saldobalancen.
4. Difference? Hent kontospecifikationen for samlekontoen og forklar posteringerne.

## To vigtige forbehold

- Køb registreret som **kontant/straksbetalt** rører aldrig samlekontoen — kun køb
  på kredit indgår i afstemningen.
- Kan MCP'ens opslag ikke liste alle købsbilag direkte, så byg listen fra
  bilagsarkivet/posteringerne på samlekontoen i stedet — og sig tydeligt hvilket
  datagrundlag du brugte.

## Tovejs-diff mod leverandørens kontoudtog (det stærke lag)

Bed brugeren skaffe leverandørens kontoudtog for perioden (de fleste
leverandører sender et på forlangende) og match faktura for faktura:

- **Mangler i Dinero:** fakturaer på kontoudtoget uden modstykke i bogholderiet
  = manglende omkostningsbilag — den hyppigste fejl overhovedet. Levér en
  mangelliste (leverandør, fakturanr., dato, beløb) brugeren kan skaffe bilag
  ud fra.
- **Bogført for meget i Dinero:** fakturaer i bogholderiet som leverandøren
  ikke kender = dubletter eller fejlkonteringer → foreslå rettelse.
- **Saldo-difference:** forklar resten med betalinger undervejs, kreditnotaer
  og gebyrer — udtogets saldo og bogholderiets saldo skal mødes, post for post.

## Difference-jagten: krydstjek mod betalingerne

Når en difference er fundet, så led i betalingsstrømmen før du konkluderer:

1. **Bogførte betalinger:** gennemgå betalingsregistreringerne og posteringerne
   på 63000/bankkontoen — er betalingen registreret på en forkert faktura eller
   leverandør?
2. **Ubogførte betalinger:** bed om kassekladde-eksporten (bankimport →
   eksportér, jf. `/dinero-bogfoering`) og led efter betalingen blandt de endnu
   ubogførte banklinjer.
3. Først når begge spor er tømt, er differencen reel — typisk et manglende
   omkostningsbilag (skaf det) eller en kreditnota leverandøren har udstedt,
   som aldrig er bogført.

## Rapportering

```
## Leverandørafstemning pr. <dato>
| Leverandør | Bogholderi (åben) | Kontoudtog | Difference | Status |
```
Manglende bilag bogføres først når bilaget er skaffet (momsfradrag kræver
dokumentation) — opret evt. som kladde uden momskode og flag det, jf.
`/dinero-bogfoering`.

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
