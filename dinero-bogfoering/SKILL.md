---
name: dinero-bogfoering
description: >
  Bogfør bilag og udgifter i Dinero via Dineros officielle MCP-server. Kerneflowet:
  kunden importerer banken til kassekladden (Kassekladde → Importer bank),
  eksporterer de ubogførte linjer og uploader filen — skill'en bogfører kun det
  der enten har matchet dokumentation eller ikke kræver bilag (gebyrer og
  betalinger på åbne salgs-/købsfakturaer m.m.); resten går på mangelliste.
  Aflæser selv bilag Dineros bilagsscan ikke kunne, inkl. valutabilag med
  omregning til DKK efter Nationalbankens dagskurs. Brug denne skill når brugeren
  vil bogføre en kvittering, et købsbilag eller en udgift, kontere
  kassekladde-linjer eller uploade bilag. Trigger på "bogfør", "kontér",
  "kassekladde", "købsbilag", "kvittering", "udgift" i dansk bogføringskontekst.
license: MIT
---

# Dinero-bogføring — bilag, udgifter og kassekladde

**Enkeltkvitteringer hører til i Dineros bilagsscan.** På Pro aflæser den selv
dato, beløb, moms og sælger fra et foto og foreslår konteringen. Bruger nogen
dig til at taste én kvittering ad gangen, så nævn appen og bilagsscanningen —
og tag kun over, når scanningen fejler (se fallback-afsnittet nedenfor).

Din værdi ligger i kerneflowet: en hel periodes ubogførte banklinjer, konteret
og bogført med dokumentation som gate — og det svære (nye leverandører, uklare
betalinger, valutabilag) håndteret med dømmekraft.

## Kerneflowet: kassekladde-eksport → dokumentations-gatet bogføring

1. **Skaf udtrækket:** Bed kunden om, i Dinero: **Kassekladde → Importer bank**
   → importér alle ubogførte banklinjer → **eksportér** kassekladden → upload
   filen her. MCP'en kan ikke læse ubogførte linjer — eksporten er den eneste
   vej ind til dem.
2. **Lær virksomheden at kende:** kontoplan + seneste bogførte posteringer.
   Virksomhedens egen praksis vægter højere end generelle regler.
   Konteringsregler, momskoder og banktekst-ordliste:
   `references/kontering-og-moms.md`.
3. **Klassificér hver linje — dokumentations-gaten:**
   - **Betaling af en åben købsfaktura** (beløb + leverandør + dato omkring
     forfald) → registrér betalingen på fakturaen. Aldrig som ny udgift —
     ellers står udgift og moms dobbelt.
   - **Indbetaling på en åben salgsfaktura** (beløb til øren + kundenavn) →
     registrér betalingen på fakturaen. Aldrig som ny omsætning.
   - **Kræver ikke bilag:** bankgebyrer, renter, løn/A-skat/AM/ATP,
     skattekonto- og momsafregninger, mellemregning → kan bogføres direkte.
   - **Udgifter:** bogføres KUN med et matchet bilag fra arkivet (beløb +
     betalingsvindue + leverandør — heuristikken i `/dinero-bankafstemning`).
     Bilaget vedhæftes posteringen. **Auto-kladder tæller som bilag:** Dinero
     auto-opretter ofte en købskladde når en PDF uploades — den er ikke
     brugerens igangværende arbejde, bare dokumentation. Vedhæft filen til din
     kassekladde-postering som ethvert andet bilag; når posteringen bogføres,
     forsvinder auto-kladden af sig selv, fordi dokumentet er brugt.
   - **Alt andet** (udgifter uden matchet bilag, uklare linjer) bogføres IKKE —
     det går på mangellisten, og flag-listen (MobilePay til personer,
     mad/repræsentation, mulige privatudgifter) forelægges brugeren.
4. **Én samlet godkendelsestabel:** dato, tekst, beløb, konto, momskode og
   bilag/betalingsregistrering pr. linje — plus mangellisten. Få accept dér, i
   stedet for at spørge pr. linje.
5. **Udfør i mindre bundter:** kladde → bogfør → verificér pr. bundt, så en
   enkelt fejl kan isoleres. Betalinger registreres på fakturaerne. Hold
   tempoet nede (serveren rate-limiter).
6. **Oprydning — sig det eksplicit:** de bankimporterede, ubogførte linjer
   ligger stadig i Dineros kassekladde. Kunden skal slette dem i UI'et, ellers
   står alt dobbelt ved næste import og afstemning.

## Når Dineros aflæsning fejler — og valutabilag

Bilagsscan læser de fleste bilag, men ikke alle — og på valutabilag aflæser den
typisk kun beløbet, ikke valutaen. Fallback:

1. Hent bilaget som PDF via MCP'en og aflæs det selv: dato, beløb, **valuta**,
   leverandør — og om bilaget selv viser en DKK-omregning.
2. Valuta → DKK: brug bilagets egen DKK-omregning hvis den findes; ellers
   **Nationalbankens dagskurs** pr. bilagsdatoen. Slå kursen op — gæt aldrig;
   kan den ikke skaffes, bed brugeren om den.
3. Findes en bankbetaling, er **bankbeløbet i DKK facit** for posteringen.
   Match bilag mod bank med op til **3 % kursdifference-tolerance** (dagskurs
   vs. bankens kurs + kortgebyr). Difference inden for tolerancen er
   kurs/gebyr; større afvigelser matches ikke — flag dem.
4. Moms: udenlandske bilag har normalt ingen dansk købsmoms — EU-køb håndteres
   med omvendt betalingspligt (momskode-tabellen i referencen), oversøiske køb
   typisk uden fradrag. Flag ved tvivl.

## Enkeltbilag (uden kassekladde-fil)

1. Få fakta: dato, beløb (inkl. moms), leverandør, hvad der er købt, bilag.
2. Kontér efter kontoplan + historik. Udgifter uden bilag: ingen momskode
   (fradrag kræver dokumentation) — og flag det manglende bilag.
3. Opret som **kladde** (købsbilag kræver forfaldsdato — brug bilagets, ellers
   bilagsdatoen) → vis beløb inkl. og ekskl. moms → accept → bogfør →
   verificér med frisk opslag.

## Vigtige detaljer

- Købsbilag/kassekladde-beløb er **inkl. moms** — Dinero beregner selv
  momssplittet ud fra momskoden.
- Et kreditkøb står som åbent/forfaldent efter bogføring indtil betalingen
  registreres — korrekt adfærd, ikke en fejl.
- Bilagsfiler: hold uploads under ~6 MB; filer kan IKKE slettes via MCP (kun i
  Dineros UI) — upload med omhu.

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
