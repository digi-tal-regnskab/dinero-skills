---
name: dinero-anlaegsaktiver
description: >
  Anlægsaktiver og afskrivninger i Dinero via Dineros officielle MCP-server:
  afgør aktivering vs. straksafskrivning, få aktiverne ind i Dineros
  anlægskartotek (som afskriver automatisk), håndtér salg/skrotning med avance/tab,
  og afstem kartoteket mod balancekontiene. Brug denne skill når brugeren nævner
  anlægsaktiver, anlægskartotek, afskrivninger, driftsmidler, aktivering,
  straksafskrivning, småaktiver, "skal denne maskine/bil/computer afskrives?"
  eller salg/skrotning af udstyr i dansk Dinero-kontekst.
license: MIT
---

# Dinero-anlægsaktiver — beslutning, kontrol og afstemning

Princippet: et aktiv med flerårig levetid koster ikke det hele i købsåret —
kostprisen fordeles over levetiden som afskrivninger.

**Dinero har sit eget anlægskartotek** (Pro/Total). Oprettes aktivet dér, bogfører
Dinero afskrivningerne automatisk og løbende og udfylder oven i købet den
skattemæssige driftsmiddelsaldo. Det er vejen — byg aldrig et konkurrerende
kartotek i et regneark og bogfør ikke afskrivninger manuelt, når kartoteket kan
gøre det. Har brugeren allerede et kartotek hos revisor, er dét master.

Din værdi ligger før og efter kartoteket:

- **Før:** beslutningen — skal købet aktiveres eller straksafskrives, hvilken
  levetid, er det ét aktiv eller flere?
- **Efter:** kontrollen — stemmer kartoteket med balancekontiene, er der aktiver
  der fejlagtigt blev udgiftsført (eller omvendt), er salg og skrot håndteret?

Regnskabsmæssig afskrivning er typisk **lineær over forventet levetid** (evt. med
restværdi). Skattemæssige afskrivninger (saldometoden) er en anden verden — sig
altid eksplicit hvilken slags der tales om, og lad revisor stå for den
skattemæssige opgørelse.

## Aktivering eller straksafskrivning?

- Under **småaktiv-grænsen** kan et aktiv udgiftsføres straks. Grænsen reguleres
  årligt — **slå det aktuelle beløb op på skat.dk før du rådgiver; hardcode det
  aldrig**.
- **Samlesæt-fælden:** aktiver der fungerer sammen (fx skrivebord+reol-systemer,
  pc med udstyr købt samlet) skal vurderes som ét aktiv — flag til vurdering i
  stedet for at splitte til under grænsen.
- Forbedringer af eksisterende aktiver aktiveres på aktivet; reparation/
  vedligehold udgiftsføres. Tvivl → flag.

## Bogføringen

- **Køb (aktivering):** kostpris på balancens anlægskonto (ikke omkostning),
  købsmoms efter normale regler. Opret derefter aktivet i **Dineros
  anlægskartotek**, så afskrivningerne kører af sig selv.
- **Afskrivning:** kører automatisk fra kartoteket. Din opgave er at kontrollere
  at den faktisk gør det (er aktivet oprettet? passer levetiden?) — ikke at
  bogføre den i hånden. Manuel afskrivning via kassekladde er kun relevant for
  aktiver der bevidst holdes uden for kartoteket (fx efter aftale med revisor);
  gør det da som kladde → accept → bogfør, uden momskode, og sig hvorfor.
- **Salg:** salgssummen er normalt momspligtig når der er taget momsfradrag ved
  købet. Avance/tab = salgssum ekskl. moms minus bogført værdi — bogføres som
  gevinst/tab, og aktivet + dets akkumulerede afskrivninger udgår af både
  kartotek og balance.
- **Skrotning:** bogført værdi udgiftsføres som tab; aktivet udgår.
- Biler har særregler (moms ved køb/salg/leasing af person- vs. varebiler) —
  flag og henvis til revisor frem for at gætte.

## Afstemningen (kør altid til sidst)

1. Kartotekets sum af kostpriser = anlægskontienes saldo.
2. Kartotekets akkumulerede afskrivninger = akk. afskrivningskontienes saldo.
3. Difference forklares aktiv for aktiv (typisk: køb udgiftsført ved en fejl →
   ompostér til aktivering og opret i kartoteket; aktiv aktiveret men aldrig
   oprettet i kartoteket → ingen afskrivninger; solgt aktiv der aldrig udgik).
4. Rapportér som statustabel med de konkrete aktiver der skal rettes eller
   oprettes i kartoteket.

Ved årsafslutning kaldes dette modul fra `/dinero-aarsafslutning` — levér årets
afskrivninger som efterposteringsforslag dertil.

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
