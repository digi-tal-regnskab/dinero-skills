---
name: dinero-momskontrol
description: >
  Momskontrol og momsafstemning i Dinero via Dineros officielle MCP-server: kontrollér
  momsgrundlaget før indberetning — salgsmoms mod momspligtig omsætning (25 %-tjek),
  købsmoms-rimelighed, EU-køb/omvendt betalingspligt, uudlignede momssaldi fra gamle
  perioder, og afstemning felt for felt mod Dineros momsopgørelse. Brug denne skill
  når brugeren nævner momskontrol, momsafstemning, momsindberetning, momsopgørelse,
  "stemmer min moms?", momsfrist eller skal indberette moms i dansk Dinero-kontekst.
  Selve indberetningen foretager brugeren i Dineros momsmodul — skill'en
  kontrollerer grundlaget, før der trykkes.
license: MIT
---

# Dinero-momskontrol — kvalitetssikring før der indberettes

**Indberetningen laver Dinero selv.** Dineros momsmodul opgør momsen og overfører
den direkte til SKAT (Moms → Momsindberetning → Indberet moms), og efterangivelser
har sin egen funktion. Du skal hverken bygge en momsopgørelse fra bunden eller
sende brugeren manuelt til TastSelv.

Din rolle er kvalitetssikringen imellem: er grundlaget rigtigt, FØR knappen
trykkes? En momsindberetning er svær at rulle tilbage — en fejl koster en
efterangivelse, og i værste fald renter. Vær ærlig om at AI kan blande momsregler
sammen — citér kun regler du er sikker på, og henvis til SKAT/revisor ved tvivl.

## Kontrollerne (kør i rækkefølge, rapportér pr. punkt)

1. **Ubogført materiale:** Ligger der ubogførte kladder eller løse bilag i
   perioden? De gør momstallene ufuldstændige — få dem bogført først
   (`/dinero-bogfoering`).
2. **Grundlagskontrol salgsmoms:** Momspligtig omsætning (omsætningskonti med
   salgsmoms-kode) × 25 % skal matche salgsmomskontoen. Afvigelse → find
   posteringer med forkert/ingen momskode (fx salg bogført direkte på
   omsætningskonto uden moms).
3. **Rimelighed købsmoms:** Købsmoms markant over ~25 % af periodens momsbelagte
   omkostninger er et rødt flag (dobbelt momskode, beløb inkl./ekskl. forvekslet).
4. **EU-køb/omvendt betalingspligt:** Skal være neutral — både købs- og salgsmoms
   af samme grundlag. Tjek at begge sider findes.
5. **Fradrag uden bilag:** Momsfradrag kræver dokumentation — flag posteringer med
   momskode men uden tilknyttet bilag.
6. **Momskonti over tid:** Efter en afregnet periode skal periodens momskonti være
   udlignet mod skattekontoen/betalingen. Gamle uudlignede momssaldi = perioder
   der aldrig blev afregnet korrekt — flag dem (`/dinero-skattekonto-afstemning`
   tager tråden derfra).
7. **Afstem mod Dineros momsopgørelse:** Bed brugeren vise tallene fra Dineros
   momsindberetnings-billede (før den godkendes) og sammenlign felt for felt mod
   dine kontrolberegninger — salgsmoms, købsmoms, EU-varer/ydelser, rubrikkerne.
   Stemmer de ikke, så find årsagen FØR indberetningen godkendes.

## Max-tilstanden ("/dinero-momskontrol max")

Beder brugeren om **max** (eller "tjek alle bilag"), udvides kontrollen med en
bilag-for-bilag-gennemgang af momskoderne:

1. Hent periodens posteringer med momskode og deres tilknyttede bilag (PDF via
   MCP'en). Kør i mindre bundter — det er mange kald, og serveren rate-limiter.
2. Aflæs hvert bilag og sammenlign bilagets faktiske momsindhold med den
   bogførte momskode: dansk moms på bilaget → `I25`; EU-faktura uden moms
   (reverse charge) → `IEUV`/`IEUY`, ikke I25; momsfrit bilag → ingen kode;
   restauration → `REP` (kvartmoms); omvendt betalingspligt → `OBPK`.
   Momskode-tabellen: konteringsreferencen i `/dinero-bogfoering`.
3. De to klassiske fund: **I25 på et bilag uden dansk moms** (fradrag der ikke
   findes — typisk udenlandske SaaS-fakturaer) og **ingen kode på et bilag med
   dansk moms** (mistet fradrag).
4. Levér omposterings-listen: postering, bogført kode, korrekt kode, momseffekt
   i kroner. Rettelser oprettes som kladde og bogføres kun efter accept — og
   husk efterangivelses-reglen ovenfor for allerede indberettede perioder.

## Rapportering

```
## Momskontrol <periode>
| Kontrol | Bogholderi | Dineros momsopgørelse | Difference | Status |
```

Hver difference forklares med konkrete posteringer. Foreslåede rettelser oprettes
som kladde og bogføres kun efter accept — og de skal være bogført, **før**
brugeren indberetter, ellers indberettes det gamle tal.

Er perioden allerede indberettet, kræver rettelser en **efterangivelse** — den har
Dinero en funktion til. Flag behovet og lad brugeren udføre den; ved større
korrektioner eller usikkerhed om periodisering: henvis til revisor.

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
