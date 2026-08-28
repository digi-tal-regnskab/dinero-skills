---
name: dinero-aarsafslutning
description: >
  Årsafslutning i Dinero via Dineros officielle MCP-server: kør hele
  årsafslutningstjeklisten — primo-kontrol mod sidste år, periodisering af
  forudbetalte og skyldige omkostninger, afskrivninger, feriepengeforpligtelse,
  moms-årskontrol, mellemregning/kapitalejerlån — og bogfør revisors
  efterposteringer som kladder til godkendelse. Brug denne skill når brugeren
  nævner årsafslutning, årsregnskab, efterposteringer, statusdag, periodisering,
  "luk året", "gør klar til revisor" eller årsrapport-forberedelse i dansk
  Dinero-kontekst.
license: MIT
---

# Dinero-årsafslutning — fra bogholderi til årsrapport-klar

Årsafslutningen er dér, hvor bogholderiet gøres retvisende pr. statusdagen.
Bogføringslovens afstemningspligt kræver reelt, at dette er på plads senest ved
fristen for årsrapporten/oplysningsskemaet — ikke "engang når der er tid".

Rollefordelingen er vigtig: du klargør, afstemmer og bogfører **godkendte**
efterposteringer. Vurderinger med skattemæssigt skøn (nedskrivninger,
feriepengeforpligtelse, igangværende arbejder, delvis momsfradragsprocent) hører
til hos brugeren/revisor — du beregner forslag og flagger, du beslutter ikke.

## Trin 0: Fundamentet

1. Kør (eller verificér) månedsluk-kontrollerne for årets sidste periode —
   `/dinero-maanedsluk` er tjeklisten: bank, debitorer, kreditorer, moms, løn,
   bilag. Årsafslutning oven på en uafstemt december er spildt arbejde.
2. **Primo-kontrol:** Hent primo-balancen for året og sammenlign med sidste års
   ultimo-saldi. Difference = sidste års efterposteringer (revisors ark) blev
   aldrig bogført — find og bogfør dem FØRST, ellers jagter du spøgelser hele
   vejen.
3. Tjek at det nye regnskabsår findes i Dinero — år kan kun oprettes i Dineros UI.

## Trin 1: Efterposterings-kandidaterne (gennemgå alle)

Gennemgå saldobalancen og kontospecifikationerne pr. statusdagen for:

- **Forudbetalte omkostninger:** forsikringer, abonnementer, husleje betalt
  forud — den del der vedrører næste år flyttes til periodeafgrænsning (aktiv).
  Find dem: store betalinger sidst på året + faste aftaler med skæv dækningsperiode.
- **Skyldige omkostninger:** omkostninger der vedrører året men først faktureres
  efter statusdagen — klassikerne er revisor, el/varme, renter, bonus/provision.
  Afsættes som skyldig post.
- **Afskrivninger:** årets afskrivninger på driftsmidler m.m. —
  `/dinero-anlaegsaktiver` har kartotek og beregning.
- **Varelager:** optælling pr. statusdag og regulering af vareforbrug (flag til
  brugeren — optællingen kan kun de selv lave).
- **Feriepengeforpligtelse:** virksomheder med funktionærer skal afsætte — beregn
  kun efter brugerens/revisors metode; flag ellers.
- **Igangværende arbejder / forudfaktureret omsætning:** omsætning skal ligge i
  det år arbejdet er udført — flag projekter der spænder over statusdagen.
- **Valutaposter:** bankkonti/mellemværender i fremmed valuta kursreguleres pr.
  statusdag — flag med beregningsforslag.
- **Privat andel / personalegoder:** fri telefon m.m. — flag til revisor
  (satser verificeres mod skat.dk).
- **Mellemregning:** retning og dokumentation pr. statusdag —
  `/dinero-mellemregning` (kapitalejerlåns-flag er skarpest her).
- **Moms-årskontrol:** årets momsgrundlag hænger sammen
  (`/dinero-momskontrol`), og momskonti for afregnede perioder er udlignet.
- **Ikke-fradragsberettigede poster:** bøder, gaver, repræsentation — skal ikke
  omposteres, men specificeres til revisor (lav listen).

## Trin 2: Bogfør efterposteringerne

- Alle efterposteringer bogføres som kassekladde-posteringer **på statusdagen**,
  uden momskoder (moms er periodens sag, ikke årsafslutningens — undtagen
  momsreguleringer, der aftales med revisor).
- Kommer der et efterposteringsark fra revisor: bogfør det 1:1 (kladde → vis →
  accept → bogfør → verificér), og afstem bagefter at ultimo-balancen matcher
  revisors kolonne.

## Trin 3: Slutkontrol og aflevering

1. Ultimo-saldobalancen efter efterposteringer = grundlaget for årsrapporten —
   træk den og gem/aflevér den.
2. Kontrollér: resultat før/efter efterposteringer forklaret post for post.
3. Rapportér:

```
# Årsafslutning <år> — <virksomhed>
| # | Område | Status | Efterpostering | Bemærkning |
```

med en restliste over det, der afventer bruger/revisor (optælling,
forpligtelses-skøn, godkendelser). Året er først "lukket", når restlisten er tom
og primo i det nye år matcher ultimo.

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
