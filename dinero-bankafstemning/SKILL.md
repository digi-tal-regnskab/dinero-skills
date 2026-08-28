---
name: dinero-bankafstemning
description: >
  Bankafstemnings-hjælp til Dinero via Dineros officielle MCP-server: Dineros egen
  automatiske bankafstemning gør grovarbejdet — denne skill tager resten. Kør en
  tovejs-diff af et fuldt bankudtog (helår eller delperiode) mod en angivet konto
  i kontoplanen og find både hvad der mangler i Dinero, og hvad der er bogført
  for meget; kontér de linjer automatikken ikke kan placere, fang
  dobbeltbogføring af åbne fakturaer, og håndtér valutabilag med 3 %
  kurstolerance. Brug denne skill når brugeren nævner bankafstemning, uafstemte
  bankposteringer, "banken stemmer ikke", umatchede linjer i bankafstemningen,
  bankudtræk eller kassekladde-eksport i dansk Dinero-kontekst. Bankdata leveres af
  brugeren som fil — MCP'en kan ikke hente dem.
license: MIT
---

# Dinero-bankafstemning — hjælp til det automatikken ikke klarer

**Start altid her: brug Dineros egen automatiske bankafstemning.** Den henter
banktransaktionerne via bankintegration, matcher hovedparten mod bogførte bilag
og lader brugeren bogføre direkte fra afstemningsbilledet — og den er inkluderet
i Pro, som MCP-adgang alligevel kræver. At eksportere data ud og bygge
afstemningen manuelt her ville være en dyrere og dårligere kopi.

Din rolle er det automatikken *ikke* kan: de linjer den ikke kan placere, den
faglige vurdering af konto og momskode, dobbeltbogførings-fælderne, de manglende
bilag — og forklaringen når saldoen alligevel ikke stemmer.

## Skaf datagrundlaget

MCP'en kan hverken hente bankposteringer, se Dineros bankafstemningsbillede eller
læse ubogførte kassekladde-linjer. Det du skal arbejde med, kommer derfor fra
brugeren — bed om det mindste der løser opgaven:

- **Fuldt bankudtog + kontonummer** (stærkest til kontrol): et udtog fra
  netbanken for **helår eller delperiode**, plus hvilken konto i kontoplanen
  der er banken → kør tovejs-diffen nedenfor, som finder både hvad der mangler
  i Dinero, og hvad der er bogført for meget.
- **Kun de uafklarede linjer**: brugeren kopierer/eksporterer de poster,
  Dineros afstemning ikke selv kunne matche — nok når spørgsmålet kun er
  kontering af resterne.
- **Kassekladde-eksport** (bankimport → eksportér): grundlaget når linjerne
  også skal BOGFØRES — det fulde flow ligger i `/dinero-bogfoering`.
  Er banken slet ikke integreret i Dinero, så foreslå bankintegrationen; den
  fjerner det meste af arbejdet fremover.

Fortegn i bankdata: typisk positivt = penge ud (udgift), negativt = penge ind.
Indbetalinger afstemmes mod fakturaer (betalingsregistrering) — de skal ikke
konteres som udgifter.

## FØR kontering: åbne fakturaer (dobbeltbogførings-fælden)

Den hyppigste alvorlige fejl i bankafstemning: en betaling af en **allerede
bogført** faktura konteres som en NY udgift/indtægt — så står udgift og moms
dobbelt. Håndtér derfor de åbne fakturaer FØRST:

- **Udbetalinger:** match mod åbne (bogførte, ubetalte) **købsbilag** — beløb
  inkl. moms + leverandør + dato omkring forfald. Match = det er en **betaling**:
  registrér den på købsbilaget (betalingsregistrering) i stedet for at kontere
  linjen som udgift.
- **Indbetalinger:** match symmetrisk mod åbne **salgsfakturaer** (beløb til øren
  + kundenavn + dato). Match = **debitor-indbetaling**: registrér betalingen på
  fakturaen — aldrig som ny omsætning.
- Åbne fakturaer UDEN bankmatch er også et fund: reelt ubetalte (eller dubletter)
  — de hører med i rapporten.

Kun de banklinjer der IKKE matcher en åben faktura, går videre til kontering.

## Kontér de resterende linjer

Følg konteringsreglerne i `references/kontering-og-moms.md` (inkl. afsnittet om
kryptiske banktekster: indløser-afregninger, EU-reverse-charge, Betalingsservice)
+ virksomhedens egen historik (slå bogførte posteringer op — historikken vægter
højest). Levér en konteringsliste: dato, tekst, beløb, foreslået konto, momskode —
og FLAG alt der kræver brugerens vurdering (MobilePay til personer, store uklare
overførsler, mad/repræsentation, mulige privatudgifter).

**Konti der ikke kræver bilag** (løn, A-skat/AM/ATP, skattekonto-/momsafregninger,
mellemregning, bankgebyrer, renter, debitor-indbetalinger) kan bogføres uden bilag.
Alle andre udgifter uden bilag hører til på mangellisten — ikke i bogføringen
(momsfradrag kræver dokumentation; kontér evt. uden momskode og flag).

## Match bilag mod banklinjer (hvis arkivet gennemgås)

Matcher du bilagsarkivets filer mod banklinjerne, så brug disse heuristikker:

- **Betalingsvindue:** kvittering (ingen forfaldsdato) → bankdato inden for
  bilagsdato ± 3 dage; faktura → fra bilagsdato − 3 til forfaldsdato + 3.
- **Entydigt distinkte beløb** (forekommer præcis én gang på begge sider OG har
  skæve ører eller er ≥ 1.000 kr.) må matche uanset dato — det fanger sene
  betalinger. Gængse beløb (fx 199,00) kræver navne-overlap + vindue.
- **Én banklinje = flere bilag** (og omvendt) accepteres kun med
  leverandørnavn-overlap.
- **Valutabilag:** omregn til DKK (bilagets egen omregning, ellers
  Nationalbankens dagskurs pr. bilagsdatoen — slå den op, gæt aldrig) og match
  mod bankbeløbet med op til **3 % kursdifference-tolerance**; differencen er
  kurs/gebyr. Større afvigelser matches ikke — flag dem.
- Skeln mellem **bekræftede match** (bogfør) og **forslag** ("er det samme
  som …?" — forelæg brugeren, bogfør ikke automatisk).
- Bilag helt uden bankbetaling = muligt privat betalt udlæg →
  `/dinero-bilagskontrol` tager den tråd.

## Registrér — afklar arbejdsdelingen eksplicit

- **Skal manglende linjer bogføres af dig,** så kør kassekladde-flowet i
  `/dinero-bogfoering`: kunden importerer banken til kassekladden, eksporterer,
  du bogfører det dokumenterede — og kunden sletter de importerede ubogførte
  linjer i UI'et bagefter, ellers står alt dobbelt (du kan ikke se dem via MCP).
- **Arbejder brugeren selv i Dineros afstemningsbillede,** så levér
  konteringslisten (dato, tekst, beløb, konto, momskode) og lad dem taste —
  og opret ingenting parallelt via MCP.

## Tovejs-diffen (fuldt udtog mod bogholderiet)

Kør denne når brugeren har leveret et fuldt bankudtog og udpeget bankkontoen i
kontoplanen:

1. Afgræns perioden efter udtoget (helår eller delperiode) og hent
   kontospecifikationen for den udpegede konto for præcis samme periode.
2. Match posteringerne (dato ± få dage, beløb, tekst; valutabilag med 3 %
   tolerance). Resultatet er tre bunker:
   - **Mangler i Dinero** — i banken, men ikke bogført → typisk manglende
     bilag; bogføres via kassekladde-flowet i `/dinero-bogfoering`.
   - **Bogført for meget i Dinero** — i bogholderiet, men ikke i banken →
     fejlposteringer, dubletter eller forkert konto/dato → foreslå
     ompostering/rettelse (kladde → accept).
   - **Beløbsdifferencer** → gebyrer, valutakurs, delbetalinger.
3. Saldokontrol: udtogets primo- OG ultimo-saldo mod kontoens bogførte saldi på
   samme datoer — differencen skal være nul eller fuldt forklaret af bunkerne
   ovenfor. "Næsten stemmer" er ikke færdigt.

## Rapporten (mangelliste-strukturen)

Saml resultatet i sektioner brugeren kan handle på — medtag kun sektioner med
indhold:

- **Manglende bilag** — banklinjer uden bilag: dato, tekst, beløb (brugeren
  skaffer bilaget og sender det til Dineros bilagsindbakke/app).
- **Uafklarede indbetalinger** — indtægter der hverken matcher faktura eller
  kendt mønster (brugeren forklarer).
- **Umatchet dokumentation** — bilag i arkivet uden bankbetaling (muligt udlæg /
  betalt fra anden konto — `/dinero-bilagskontrol`).
- **Forfaldne ubetalte regninger / salgsfakturaer** — åbne fakturaer uden
  bankmatch (dublet eller reelt ubetalt / rykker-kandidat).
- **Yderligere dokumentation** — udtog der skal bruges til fuld afstemning: andre
  bankkonti, indløser-afregninger (Nets/Clearhaus m.fl.), MobilePay-udtog,
  neobank-konti (Revolut/Lunar) spottet i bankteksterne.

Beder brugeren om "bankafstemning i Dinero" (modulet): vær ærlig — selve modulet
betjenes i Dineros UI; det du kan, er kontrolarbejdet her.

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
