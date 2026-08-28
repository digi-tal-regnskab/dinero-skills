---
name: dinero-loenafstemning
description: >
  Lønafstemning i Dinero via Dineros officielle MCP-server: afstem bogført løn mod
  lønsystemets lønkørsler og eIndkomst-indberetningen (A-indkomst, A-skat, AM-bidrag,
  ATP), match nettoløns-udbetalingerne i banken mod lønsedlerne, og kontrollér at
  skyldig-kontiene udlignes af skattekonto-trækkene. Brug denne skill når brugeren
  nævner lønafstemning, løn, lønkørsel, lønsedler, eIndkomst, A-skat, AM-bidrag,
  nettoløn, ATP eller "stemmer lønnen?" i dansk Dinero-kontekst. MCP'en har ikke
  adgang til lønsystem eller SKAT — brugeren leverer lønrapport/eIndkomst-udtræk.
license: MIT
---

# Dinero-lønafstemning

Løn er det område hvor flest tal skal mødes: lønsystemet, banken, bogholderiet,
eIndkomst og skattekontoen skal alle fortælle samme historie. MCP'en har kun adgang
til bogholderiet — resten leverer brugeren som filer.

## Skaf datagrundlaget

Afstemningen kræver ÉN uafhængig kilde — **lønsystemets rapport ELLER et
eIndkomst-udtræk**. Bed om den brugeren lettest kan skaffe; begge er sjældent
nødvendige (kun ved mistanke om indberetningsfejl, hvor lønsystem og eIndkomst
skal holdes mod hinanden):

- **Lønsystemets rapport** for perioden (Danløn, Zenegy, Salary, Lessor m.fl.):
  bruttoløn, A-skat, AM-bidrag, ATP, nettoløn pr. medarbejder — ELLER
- **eIndkomst-udtræk** fra SKAT (virk.dk/TastSelv). Nøglefelter:
  **0013** = A-indkomst, **0015** = A-skat, **0016** = AM-bidrag, **0046** = ATP.

Valgfrie supplementer:
- **Skattekonto-udtræk** (skat.dk) — de faktiske betalinger til SKAT
  (dybere afstemning: `/dinero-skattekonto-afstemning`).
- Bankdata via kassekladde-eksport, hvis nettoløn skal matches mod banken.

Bogholderiets løn-konti i standardkontoplanen: lønudgift **3000**-serien,
skyldig AM-bidrag **65000**, skyldig A-skat **65020**, skyldig ATP **65040**,
skyldig løn **65100**.

## Mønstret

En normal månedsløn sætter disse spor:

1. **Lønkørslen bogføres:** lønudgift (bruttoløn m.m.) debiteres; **nettoløn**
   krediteres bank (eller skyldig løn); **A-skat/AM-bidrag** krediteres en
   skyldig-konto; **ATP** krediteres sin skyldig-konto.
2. **Banken:** nettoløns-udbetalinger til medarbejderne (ofte "løn", "transfer of
   salary" eller en samlet lønoverførsel via lønsystemet).
3. **Måneden efter:** skattekonto-trækket udligner skyldig A-skat/AM-bidrag.
   **ATP** trækkes kvartalsvis (lille fast beløb).

## Afstemningerne (kør dem der er data til)

1. **Bogført vs. lønsystem:** Periodens bogførte lønudgift = lønsystemets
   bruttoløn (+ evt. pension, feriepenge, personalegoder — se forbehold).
2. **Bank vs. lønsedler:** Hver nettoløns-udbetaling i banken matcher en lønseddel
   (beløb + måned). Udbetalinger der ligner løn men ikke findes i lønsystemet →
   flag (forskud? mellemregning? sort plet?).
3. **eIndkomst vs. lønsystem/bogholderi:** Felt 0013/0015/0016/0046 skal matche
   lønsystemets tal og de bogførte skyldig-poster. Difference = indberetningsfejl
   eller manglende/dobbelt lønkørsel.
4. **Skyldig-kontienes livscyklus:** Skyldig A-skat/AM opbygges ved lønkørsel og
   udlignes af skattekonto-trækket. En skyldig-saldo der vokser uden at blive
   udlignet = indberettet men ikke betalt — flag tydeligt.
5. **Ingen ansatte?** Så skal der ingen lønposteringer være. Faste "løn-lignende"
   overførsler til ejeren uden lønsystem bag er typisk mellemregning eller udbytte
   — flag dem (`/dinero-mellemregning`).

## Forbehold — flag, gæt ikke

- **Feriepenge/feriepengeforpligtelse** (især funktionærer og fratrådte),
  **pension** og **personalegoder** har hver deres periodiserings- og
  afregningsregler. Konstatér differencer der ligner disse, og henvis til
  lønsystemets specifikation eller revisor — regn dem ikke "på plads" med gæt.
- Lønrettelser bagud (genindberetning i eIndkomst) kan forskyde en måned — tjek
  nabo-månederne før du erklærer en difference.

## Rapportering

```
## Lønafstemning <periode>
| Kontrol | Bogholderi | Lønsystem/eIndkomst/bank | Difference | Status |
```

Status pr. kontrol: stemmer / difference forklaret / uafklaret (med de konkrete
posteringer). Rettelser oprettes som kladde og bogføres først efter accept.

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
