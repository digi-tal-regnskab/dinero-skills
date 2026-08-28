---
name: dinero-konvertering
description: >
  Konvertering TIL Dinero via Dineros officielle MCP-server — fra e-conomic, Billy,
  Uniconta, regneark eller en anden Dinero-aftale. To spor: åbningsbalance-metoden
  (anbefalet standard: saldi pr. skæringsdato + åbne debitorer/kreditorer) eller
  fuld historik-migrering (genskab bilag og fakturaer — med nummerserie-fælderne
  håndteret). Brug denne skill når brugeren nævner migrering, "skift til Dinero",
  "flyt regnskabet fra e-conomic/Billy", åbningsbalance, primoposteringer,
  skæringsdato, konvertering af regnskab eller opstart af nyt regnskab i Dinero
  med gamle tal. Data fra kildesystemet leveres af brugeren som eksportfiler —
  MCP'en har kun adgang til Dinero.
license: MIT
---

# Dinero-konvertering — flyt regnskabet ind i Dinero

MCP'en kan kun skrive i Dinero — kildesystemet (e-conomic, Billy, …) leverer
brugeren fra som eksportfiler: saldobalance pr. skæringsdato, åbne
debitor-/kreditorposter, kontoplan, kunde-/leverandørlister, og evt. bilag/
posteringer ved fuld migrering.

**Vælg spor sammen med brugeren — anbefal A:**

- **Spor A — åbningsbalance (standard):** Dinero starter "på en frisk" fra en
  skæringsdato med korrekte saldi og åbne poster. Hurtig, robust, og historikken
  bliver i kildesystemet.
- **Spor B — fuld historik:** dokumenter genskabes i Dinero. Vælges kun når der
  er en tvingende grund (fx kildesystemet lukker helt) — det er stort arbejde
  med skarpe fælder.

**Uanset spor — opbevaringspligten:** bogføringsloven kræver at det gamle
regnskabsmateriale opbevares betryggende i 5 år. Sig det eksplicit: brugeren
skal sikre eksport/fortsat læseadgang til kildesystemet FØR opsigelse — en
migrering fritager ikke for opbevaring af historikken.

## Fælles fundament (begge spor)

1. **Skæringsdato:** typisk et årsskifte eller et momsperiode-skift — så moms
   før skæringen afregnes fra kildesystemet, og Dinero starter med en ren
   momsperiode. Anbefal det; andre datoer kan lade sig gøre men giver mere
   momsbøvl.
2. **Regnskabsår:** skal findes i Dinero — år oprettes kun i Dineros UI.
3. **Kontoplan-mapping:** byg en eksplicit tabel kildekonto → Dinero-konto (og
   momskode). Fælder: likvide konti (bank m.v., 55xxx-området) er en særlig
   kontotype (beholdningskonto) i Dinero; momskoder mappes pr. konto ud fra
   kildens faktiske brug, ikke ud fra navnet. Manglende konti oprettes —
   forelæg hele mappingen til godkendelse FØR der oprettes noget.
4. **Kontakter:** genbrug kildens stamdata (adresse, CVR, betalingsbetingelser).
   Fælde: kontakter med EAN/GLN kræver en att.-person. Slå op før oprettelse —
   ingen dubletter.
5. **Alt verificeres fase for fase** med friske opslag i Dinero (tæl, summér,
   sammenlign mod kilden) — aldrig kun ud fra "det gik godt".

## Spor A: Åbningsbalance-metoden

1. **Saldobalance pr. skæringsdato** fra kilden (efter årsafslutning/
   efterposteringer for perioden før — ellers migreres et forkert tal;
   `/dinero-aarsafslutning` hvis det mangler).
2. **Primoposteringen:** har Dinero en indbygget åbningsbalance-funktion
   tilgængelig (UI), er den at foretrække. Via MCP: én samlet
   kassekladde-postering på skæringsdatoen med alle **balancekonti** (sum = 0,
   modpostér differencer på egenkapital/primokonto), **uden momskoder** — momsen
   før skæringen er kildesystemets sag; skyldig/tilgodehavende moms indgår som
   saldo. Resultatkonti migreres ikke (nyt år) — medmindre skæringen ligger midt
   i et regnskabsår: så migreres også år-til-dato resultatsaldi (flag det som
   særtilfælde og afstem ekstra grundigt).
3. **Åbne debitorer:** to muligheder — anbefal (a):
   - (a) Genskab hver åben salgsfaktura i Dinero (kladde → bogfør), så
     betalinger kan registreres og rykkes pr. faktura. VIGTIGT før bogføring:
     sæt fakturanummer-serien i Dineros UI så den fortsætter kildens numre —
     og bemærk at Dineros egne numre tildeles i bogføringsrækkefølge; læg
     kildens originalnummer i referencefeltet. Debitorernes sum skal derefter
     ERSTATTE debitor-saldoen fra primoposteringen (undgå dobbelt: udelad
     samlekontoen af primoposten, eller modpostér — vis regnestykket).
   - (b) Kun samlekonto-saldo i primoposten + åben-post-liste udenfor Dinero
     (simplere, men udligning pr. faktura mistes).
4. **Åbne kreditorer:** samme valg — genskab som købsbilag (kræver forfaldsdato)
   eller samlekonto-saldo.
5. **Slutkontrol:** Dineros saldobalance pr. skæringsdato == kildens, linje for
   linje; åbne poster == kildens lister; første bankafstemning efter go-live
   (`/dinero-bankafstemning`) bekræfter at primo-banksaldoen var rigtig.

## Spor B: Fuld historik (kun med tvingende grund)

Alt fra spor A gælder, plus:

- **Nummerserie-fælderne styrer rækkefølgen:** fakturanumre tildeles ved
  bogføring, kan ikke vælges pr. dokument, og et forbrugt nummer frigives aldrig
  — bogførte dokumenter kan ikke slettes via MCP, og sletter brugeren dem i
  Dineros UI, er nummeret stadig brugt. Procedure for hul-fri serie: sæt startnummer i UI → bogfør ét
  dokument → verificér nummeret → kør resten **sekventielt i original
  nummerorden med stop-ved-fejl** — aldrig parallelt. Kreditnotaer deler serien.
- **Bilag:** upload filer først (under ~6 MB pr. fil), knyt dem til de genskabte
  dokumenter. Filer kan ikke slettes igen — gør uploads genoptagelige (log hvad
  der er uploadet, spring over ved genkørsel) så afbrydelser ikke giver dubletter.
- **Betalinger/udligninger** genskabes til sidst, så statusser (betalt/åben)
  ender som i kilden.
- **Momsen:** allerede indberettede perioder må ikke kunne "genindberettes" fra
  Dinero — afstem Dineros momstal pr. historisk periode mod kildens indberetninger
  og dokumentér at de matcher.
- Kør i små bundter med verifikation efter hvert bundt; ved fejl: stop, forklar,
  og ret før der fortsættes.

## Rapporten

```
# Migrering til Dinero — <virksomhed>, skæring <dato>, spor A/B
| Fase | Kilde | Dinero | Difference | Status |
(Kontoplan · Kontakter · Primo-balance · Åbne debitorer · Åbne kreditorer · [Historik-faser])
```

Migreringen er først færdig når alle differencer er nul eller forklaret — og
brugeren har bekræftet 5-års-adgangen til det gamle materiale.

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
