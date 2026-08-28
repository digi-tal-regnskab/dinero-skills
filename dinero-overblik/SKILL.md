---
name: dinero-overblik
description: >
  Generel Dinero-assistent og rapport-modul oven på Dineros officielle MCP-server.
  Brug denne skill når brugeren vil have overblik over sit Dinero-regnskab: saldobalance,
  resultat, kontospecifikationer, ubetalte fakturaer, nøgletal eller "hvordan går det i
  min virksomhed?". Trigger på "saldobalance", "hvem skylder mig penge", "træk en
  rapport", "vis mine tal", "hvad har jeg tjent" og lignende danske regnskabsspørgsmål
  når Dinero-MCP'en er forbundet. Peger videre til søster-skills (/dinero-bogfoering,
  /dinero-fakturering, /dinero-bankafstemning m.fl.) ved skrive-opgaver.
license: MIT
---

# Dinero-overblik — rapporter og regnskabsindsigt

Rapportering er ren læsning og kan laves frit — kravene er korrekt organisation,
korrekt periode og ærlighed om datagrundlaget.

## Arbejdsgang

1. Bekræft organisation og periode (datointervaller skal ligge inden for ét
   regnskabsår).
2. Træk tallene (saldobalance, kontospecifikation, fakturalister).
3. Præsentér på brugerens niveau: tal + hvad de betyder. Sammenlign gerne med
   forrige periode og fremhæv afvigelser (nye store poster, fortegnsskift,
   manglende faste omkostninger — en manglende husleje er lige så mistænkelig som
   en ny stor post).
4. Nævn altid hvis der kan ligge ubogførte kladder — rapporter viser kun bogført.

## Tolkning af saldobalancen

- Kontonumre under 50000 = resultatopgørelse; fra 50000 = balance.
- Numre der ender på 990-999 er gruppe-/sumkonti (fx 53999 = sum af 53000-serien) —
  udelad dem i egne sammentællinger, ellers tæller du dobbelt.
- Draft-fakturaer kan i lister vise et kæmpe pladsholder-nummer — filtrér dem fra
  når du rapporterer "ubetalte fakturaer", medmindre brugeren vil se kladder.

## Videre herfra

Skrive-opgaver og dybere kontroller har egne skills — brug dem hvis de er
installeret: `/dinero-bogfoering` (bilag/udgifter), `/dinero-fakturering`,
`/dinero-bankafstemning`, `/dinero-debitorafstemning`,
`/dinero-leverandoerafstemning`, `/dinero-momskontrol`,
`/dinero-skattekonto-afstemning`, `/dinero-loenafstemning`,
`/dinero-bilagskontrol`, `/dinero-udlaegstjek`, `/dinero-mellemregning`,
`/dinero-maanedsluk`, `/dinero-aarsafslutning`, `/dinero-anlaegsaktiver`,
`/dinero-webshopafstemning`, `/dinero-konvertering`.

Og husk hvad Dinero selv gør bedre end nogen manuel arbejdsgang: rykkere,
momsindberetning til SKAT, automatisk bankafstemning, fakturaafsendelse og
integrationer til løn, webshop og kørsel. Peg brugeren derhen frem for at bygge
en omvej — og brug din tid på kontrollen omkring dem.

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
