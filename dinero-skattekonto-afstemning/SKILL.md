---
name: dinero-skattekonto-afstemning
description: >
  Skattekonto-afstemning i Dinero via Dineros officielle MCP-server: afstem trækkene
  på virksomhedens skattekonto hos SKAT (A-skat/AM-bidrag, moms, selskabsskat) mod de
  tilsvarende skyldig-konti og skattekonto-kontoen i bogholderiet, og fang
  indberettet-men-ikke-betalt (eller omvendt). Brug denne skill når brugeren nævner
  skattekonto, skattekontoafstemning, A-skat, AM-bidrag, "stemmer skattekontoen?",
  skyldig skat/moms eller løntræk mod SKAT i dansk Dinero-kontekst. Skattekonto-udtrækket
  hentes af brugeren på skat.dk — MCP'en har ikke adgang til SKAT.
license: MIT
---

# Dinero-skattekonto-afstemning

Skattekontoen hos SKAT er en uafhængig kilde — perfekt til afstemning. MCP'en har
ingen adgang til SKAT, så bed brugeren hente **skattekonto-udtrækket** på skat.dk
(TastSelv Erhverv → Skattekontoen) som fil for perioden.

**Findes 63300 ikke i kontoplanen?** Så kan du ikke oprette den — bed brugeren
gøre det i Dinero (Indstillinger → Kontoplan) under kortfristet gæld, og vent.
Uden den konto er der intet at afstemme mod.

**Målbilledet:** konto **63300 Skattekonto** i bogholderiet skal spejle SKATs
skattekonto 1:1 — hver bevægelse på udtoget har en postering på 63300, og
63300-saldoen matcher SKATs saldo på enhver dato. SKAT-relaterede posteringer
der ligger andre steder (som driftsomkostning, eller direkte på skyldig-konti
uden om 63300), flyttes til 63300 via omposteringer, så kontoen bliver hele
sandheden om mellemværendet med SKAT.

## Mønstret du afstemmer mod

Virksomheder med ansatte har et fast månedsmønster:

- Lønkørsel opbygger **skyldig A-skat/AM-bidrag** i bogholderiet → skattekontoens
  træk måneden efter udligner den (varierende beløb).
- **Moms** afregnes kvartalsvis/halvårligt → momskontienes udligning skal matche
  skattekontoens momstræk (`/dinero-momskontrol` kontrollerer grundlaget).
- **ATP** trækkes kvartalsvis (lille fast beløb).
- I bankdata genkendes trækkene ofte som "INFO-OVF…"-overførsler eller betalinger
  til Skattestyrelsen — de skal stå på skattekonto-/skyldig-konti, ikke som
  driftsomkostninger.

## Arbejdsgang

1. Hent kontospecifikationer for **63300 Skattekonto** og skyldig-kontiene
   (**65000** Skyldig AM-bidrag, **65020** Skyldig A-skat, **65040** Skyldig
   ATP, samt **64100** Momsafregning) for perioden.
2. Match SKAT-udtrækket linje for linje mod 63300 (dato, beløb, art).
3. Fire fund-typer — og handlingen for hver:
   - **På udtoget, ikke på 63300 (mangler):** opret posteringen på 63300 med
     korrekt modkonto — A-skat/AM-træk mod 65020/65000, ATP mod 65040,
     momsafregning mod 64100, renter/gebyrer fra SKAT mod renteomkostning.
     Kladde → accept → bogfør.
   - **Bogført et forkert sted:** SKAT-betalinger konteret som driftsomkostning
     eller direkte på en skyldig-konto uden om 63300 → ompostér til/via 63300,
     så kontoen spejler udtoget.
   - **På 63300, ikke på udtoget (bogført for meget):** fejlpostering eller
     dublet → foreslå rettelse.
   - **Indberettet men ikke betalt:** skyldig-saldo vokser uden tilsvarende træk
     hos SKAT → betalingsrestance; flag tydeligt (SKAT renteberegner dagligt).
4. Slutfacit: 63300-saldoen == SKATs saldo pr. udtogets slutdato — og gerne
   stikprøvevis på mellemliggende datoer. Nul eller fuldt forklaret.

## Rapportering

```
## Skattekonto-afstemning <periode>
| Post | Bogholderi | SKAT | Difference | Status |
```
Lønbeløbene kan desuden krydstjekkes mod lønsystem/eIndkomst hvis brugeren kan
levere tallene — nævn muligheden.

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
