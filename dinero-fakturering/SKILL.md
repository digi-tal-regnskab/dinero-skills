---
name: dinero-fakturering
description: >
  Opret fakturaer og kreditnotaer og registrér betalinger i Dinero via Dineros
  officielle MCP-server — med respekt for Dineros farligste fælde: den permanente
  nummerserie. Brug denne skill når brugeren vil lave/udstede en faktura, kreditere en
  faktura, registrere en indbetaling/udligning, eller have styr på betalingsbetingelser
  og rykkerliste — og lav tilbud, som er det eneste dokument MCP'en kan sende.
  Trigger på "faktura", "fakturér", "kreditnota", "regning til kunde",
  "registrér betaling", "udlign", "tilbud", "giv et tilbud" og lignende i dansk
  Dinero-kontekst. Bemærk: MCP'en kan IKKE sende fakturaer og kreditnotaer —
  afsendelse sker i Dineros UI.
license: MIT
---

# Dinero-fakturering — fakturaer, kreditnotaer og betalinger

## Nummerserien — lær den udenad

Fakturaer og kreditnotaer deler **én** fortløbende nummerserie. Nummeret tildeles
først ved **bogføring**, kan ikke vælges pr. dokument, og et forbrugt nummer kan
aldrig genbruges — selv hvis dokumentet slettes i Dineros UI bagefter. Ét bogført
testdokument = permanent hul i serien. Derfor: kladde → gennemsyn → bogfør kun på
accept. Skal flere dokumenter bogføres i bestemt rækkefølge: sekventielt,
stop-ved-fejl, aldrig parallelt.

## Fakturaflow

1. Find kunden i kontaktkartoteket FØR du opretter en ny kontakt (undgå dubletter).
   Offentlige kunder med EAN/GLN kræver en att.-person.
2. Fakturalinjer: beløb **ekskl. moms** (aftalt pris inkl. moms ÷ 1,25). Vis altid
   begge tal, og tjek at totalen matcher den aftalte pris.
3. Betalingsbetingelser: "Netto X dage" og "løbende måned + X dage" kræver antal
   dage; "kontant/betalt" må ikke have et. Følg det kunden plejer at få.
4. Linjebeskrivelser: konkrete (ydelse, projekt, periode). Fast tekst/aftaletekst:
   kig på virksomhedens seneste fakturaer og følg stilen.
5. Kladde → vis → accept → bogfør → verificér (nummeret kommer i bogføringssvaret).
6. **Afsendelse sker i Dineros UI** — MCP'en kan ikke sende fakturaer og
   kreditnotaer (kun tilbud kan sendes). Sig det eksplicit, og lov aldrig at
   fakturaen "er sendt".

## Tilbud

Tilbud er den ene undtagelse fra alt ovenstående: **et tilbud har ingen
regnskabsmæssig virkning** — der bogføres intet, og nummerserien røres ikke.
Derfor er det også det eneste dokument MCP'en må sende til kunden.

- **Linjerne er de samme** som på en faktura: konto, momskode, enhed, beløb
  ekskl. moms. Vælg dem lige så omhyggeligt — de følger med over på fakturaen,
  når kunden siger ja, og en forkert momskode her bliver en forkert momskode i
  regnskabet.
- **EU-salg:** skal linjerne på en omvendt betalingspligt-konto, så verificér
  købers momsnummer i VIES **nu** — ikke først når tilbuddet bliver til faktura.
- **Arbejdsgangen:** opret → vis brugeren hele indholdet → få accept → send.
  Afsendelse er en udgående handling til en rigtig kunde: spørg eksplicit før
  du sender, hver gang.
- **Når kunden accepterer** konverteres tilbuddet til en faktura. Først dér
  tildeles et fakturanummer, og alle nummerserie-reglerne ovenfor gælder igen.
- Brug tilbudslisten til at se hvad der er sendt og stadig er ubesvaret.

## Kreditnotaer

Samme linjestruktur og samme nummerserie som fakturaer. Referér til det
oprindelige fakturanummer i teksten. Bemærk: kreditnotaer optræder ikke altid i
fakturalister — led også i salgsbilag når du danner overblik.

## Betalingsregistrering (udligning)

- Registreres på **bogførte** dokumenter; status går åben → betalt. Verificér.
- Faktisk bankbeløb, faktisk betalingsdato, bankkonto (standard: 55000).
- Delbetaling: registrér det betalte — dokumentet forbliver delvist åbent.
- Små differencer (gebyr/øre): spørg før du "sluger" dem som gebyr-rest.

## Forfaldne fakturaer og rykkere

Du leverer overblikket: åbne + forfaldne fakturaer sorteret efter forfaldsdato,
gerne aldersfordelt (1-30/31-60/60+). Filtrér kladder fra (kæmpe
pladsholder-numre). Dybere debitorkontrol: `/dinero-debitorafstemning`.

**Selve rykkerne hører til i Dineros rykker-modul** — det beregner rykkerrenter
løbende, holder gebyrerne inden for lovens grænser, modregner delbetalinger og
sender rykkeren. Skriv derfor ikke rykkertekster og beregn ikke gebyrer eller
renter manuelt; giv den prioriterede liste og lad modulet gøre resten. Til
gengæld er din kontrol før rykkerkørslen guld værd: er betalingen registreret det
rigtige sted, findes der en umodregnet kreditnota, er der en kendt tvist? En
rykker på forkert grundlag koster mere end den henter hjem.

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
