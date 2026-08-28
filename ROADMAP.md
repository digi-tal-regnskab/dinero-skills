# Kortlægning: manglende evner (ikke bygget endnu)

Dette dokument kortlægger hvilke evner samlingen mangler, målt mod de
autoritative kilder for korrekt bogføring, moms og controlling i Danmark.
Intet her er bygget — det er en prioriteret idéliste.

## Kilderne der er målt imod

**Lovgrundlag**
- Bogføringsloven (2022) + Erhvervsstyrelsens vejledninger:
  [vejledning om bogføringsloven](https://erhvervsstyrelsen.dk/vejledning-bogfoeringsloven)
  og [vejledning om bogføring](https://erhvervsstyrelsen.dk/vejledning-bogfoering).
  Nøglekrav: løbende registrering og transaktions-/kontrolspor, **afstemningspligten
  (§ 11)** — afstemninger skal laves senest ved fristerne for moms-, skatte- og
  årsindberetninger, ikke kun ved årsafslutning — samt 5 års betryggende opbevaring
  og kravene til digitale bogføringssystemer.
- Momsloven + momsbekendtgørelsen via SKATs juridiske vejledning:
  [D.A.11.1.7 — dokumentationskrav for momsfradrag](https://info.skat.dk/data.aspx?oid=2085659)
  (fradrag kræver forskriftsmæssig faktura/afregningsbilag; forenklede fakturaer
  kan bruges inden for grænserne) og
  [A.B.3.3.1.1 — generelle fakturakrav](https://info.skat.dk/data.aspx?oid=2068786).
- Udlæg: [C.A.7.2.6 — udlæg efter regning](https://info.skat.dk/data.aspx?oid=1976867)
  (skattefri refusion kræver eksternt udgiftsbilag i virksomhedens
  regnskabsmateriale).

**Praksis/lærestof**
- Erhvervsstyrelsens emnebaserede bogføringsvejledning (god skik: kronologi,
  afstemning, dokumentation).
- Klassisk årsafslutningsstof som fx "Kompendium i Bogføring og Årsafslutning"
  (periodisering, afskrivninger, efterposteringer, lager, feriepengeforpligtelse).

**OBS ved bygning:** satser og beløbsgrænser (godtgørelser, gebyrer,
småaktiv-grænser m.m.) ændres årligt — de skal altid verificeres mod skat.dk på
byggetidspunktet og må ikke hardcodes fra hukommelsen.

## Dækning i dag (18 moduler)

Løbende bogføring, fakturering, betalinger, rapporter, og afstemning af bank,
debitorer, kreditorer, løn, skattekonto, moms(grundlag), mellemregning, bilag,
udlæg — samt månedsluk, årsafslutning, anlægsaktiver, webshopafstemning,
konvertering til Dinero og opsætning.

## Afgrænsningsprincippet (styrer hvad der bygges)

Dinero gør en række ting selv, og bedre end nogen manuel arbejdsgang: **rykkere**
(med automatisk renteberegning og lovlige gebyrer), **momsindberetning direkte til
SKAT**, **automatisk bankafstemning** (Pro — som MCP-adgang alligevel kræver),
**anlægskartotek** med automatiske afskrivninger og udfyldt driftsmiddelsaldo,
**bilagsscan** der aflæser dato/beløb/moms fra et foto, **fakturaafsendelse** og
150+ **integrationer** (løn, webshop, kørsel, betalinger).

Et modul skal derfor bidrage med noget af dette — ellers bygges det ikke:
dømmekraft (er grundlaget rigtigt?), krydsning af kilder Dinero ikke selv har
(SKAT, lønsystem, indløser, kildesystem), eller regnskabsfaglighed automatikken
ikke besidder. Manuelle kopier af eksisterende UI-funktioner er dårligere
produkter og gør brugeren langsommere.

## Manglende evner — prioriteret

### ✅ Bygget siden kortlægningen

`/dinero-aarsafslutning`, `/dinero-anlaegsaktiver`, `/dinero-webshopafstemning`
og `/dinero-konvertering` (flyt til Dinero fra e-conomic/Billy m.fl. med
åbningsbalance-metoden som anbefalet spor; var ikke i den oprindelige
kortlægning).

### ❌ Bygget og fjernet igen

`/dinero-rykkerprocedure` blev bygget, men **fjernet** efter afgrænsningsprincippet
ovenfor: Dineros [rykker-modul](https://dinero.dk/funktioner/rykker-modul/) laver,
beregner og sender rykkere med korrekte satser. Et manuelt rykkerflow ville både
være langsommere og risikere forkerte gebyrer/renter. Den værdifulde rest —
prioritering og kontrol af at der ikke rykkes på forkert grundlag — ligger nu i
`/dinero-debitorafstemning` og `/dinero-fakturering`.

### Mellem prioritet

5. **`/dinero-koerselsgodtgoerelse`** — **først efter en kontrol af
   afgrænsningsprincippet:** Dinero har kørselsintegrationer der bogfører
   godtgørelsen automatisk. Byg kun kontrol-laget (er kørselsregnskabet
   dokumenteret, holder satserne, hvornår er det udlæg efter regning i stedet) —
   ikke en manuel registreringsflow.
6. **`/dinero-varelager`** — lageroptælling, lagerregulering, vareforbrug — for
   handelsvirksomheder en fast del af både måneds- og årsafslutning. Tjek først
   om Dineros egen lagerfunktion/integrationer dækker registreringen; modulets
   værdi er optællings- og reguleringskontrollen.
7. **`/dinero-compliance`** — bogføringslovs-egenkontrol: registreres der løbende
   (dato-huller?), er der transaktionsspor (bilag pr. registrering), overholdes
   afstemningskadencen i § 11 op til momsfristerne, opbevaring. Et samlet
   "er vi compliant?"-tjek på tværs af de eksisterende moduler.
8. **EU-moms-udvidelse af `/dinero-momskontrol`** — EU-salgsangivelse ("EU-salg
   uden moms"/VIES), OSS/Moms One Stop Shop for B2C-webshops, rubrik A/B/C-logik.
   I dag dækkes kun neutralitetstjekket af EU-køb.

### Lav prioritet / kan være referencer frem for moduler

9. **Valutahåndtering** — kursdifferencer ved udenlandske køb/salg (kunne være et
   afsnit i konteringsreferencen frem for et modul).
10. **Personalegoder/privat andel** — fri telefon, privat andel af bil m.m.;
    flag-tungt og revisor-nært.
11. **Kasseafstemning** — daglig kasserapport for fysiske butikker
    (transaktionssporet i bogføringsloven); relevant for et mindretal.
12. **Selvangivelses-forberedelse** — specifikationer af ikke-fradragsberettigede
    poster (repræsentation, bøder) til revisor; grænser tæt op ad
    revisorarbejde og bør i givet fald holdes rent forberedende.

## Bevidst udeladt

- **Alt der sendes til kunden:** rykkere og fakturaafsendelse hører til i Dineros
  UI, som gør det korrekt og sporbart. Modulerne forbereder grundlaget og
  kontrollerer det — de skriver ikke kundekommunikation og sender ikke noget.
- **Momsindberetning og lønkørsel:** sker i hhv. Dineros momsmodul (som selv
  overfører til SKAT) og lønsystemet. Modulerne kvalitetssikrer før og afstemmer
  efter.
- Skatterådgivning: modulerne flagger og henviser til SKAT/revisor; de rådgiver
  ikke om satser og fradrag ud over det dokumenterede.
