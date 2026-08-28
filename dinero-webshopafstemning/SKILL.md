---
name: dinero-webshopafstemning
description: >
  Webshop- og indløserafstemning i Dinero via Dineros officielle MCP-server:
  afstem webshoppens salg mod indløser-afregninger (Stripe, Nets, Clearhaus,
  MobilePay, PayPal, Klarna m.fl.) og mod bankens udbetalinger — brutto-salg vs.
  netto-payout, gebyrer med omvendt betalingspligt, refusioner og
  mellemkonto-nulstilling — og bogfør hele webshopsalget fra en CSV (dag for
  dag, pr. momssats, mod angivet konto) når ingen integration gør det. Brug
  denne skill når brugeren nævner webshop, indløser, payout,
  Stripe/Nets/Clearhaus/MobilePay/PayPal/Klarna-afregning, Shopify/
  WooCommerce-salg, "bogfør mit webshopsalg" eller "stemmer webshop-salget?" i
  dansk Dinero-kontekst. Afregningsrapporter og shopdata leveres af brugeren som
  filer — MCP'en har kun adgang til Dinero.
license: MIT
---

# Dinero-webshopafstemning — salg → afregning → bank

Webshop-penge tager en omvej: kunden betaler indløseren, indløseren trækker
gebyr og udbetaler nettobeløbet til banken — ofte dage senere og i klumper. Det
giver tre tal der ALDRIG er ens, men altid skal kunne forbindes:

```
Shop-salg (brutto) − gebyrer − refusioner ± timing = bank-udbetalinger (netto)
```

Mellemkontoen pr. indløser er broen: salget debiteres dér når det sker,
udbetalingen krediterer den når pengene kommer. En mellemkonto der vokser og
aldrig nulstilles = uafstemt webshop.

**Tjek at mellemkontoen findes, før du bogfører noget.** Standardkontoplanen har
den IKKE — den skal oprettes pr. indløser (Stripe, Nets, MobilePay …), og
MCP'en kan ikke oprette konti. Mangler den, så stop og bed brugeren oprette den
i Dinero (Indstillinger → Kontoplan) som et tilgodehavende, og fortsæt først når
den er der. Bogfør aldrig webshopsalget direkte mod banken eller mod en
nærliggende konto som "Indløsere" for at slippe uden om — så mister du netop den
bro afstemningen bygger på.

## Skaf datagrundlaget (bruger-leveret — MCP'en ser kun Dinero)

1. **Indløserens afregningsrapport** for perioden (Stripe/Nets/Clearhaus/
   MobilePay/PayPal/Klarna-udtræk): brutto pr. payout, gebyrer, refusioner,
   udbetalingsdatoer.
2. **Shopsystemets salgsrapport** (Shopify/WooCommerce m.fl.): omsætning pr.
   dag/ordre, moms, refusioner. Har brugeren en af Dineros webshop-/
   betalingsintegrationer, bogfører den allerede salget — så er dét kilden i
   bogholderiet: afstem den, og bogfør aldrig salget en gang til manuelt.
   Bogfører brugeren webshop-salg i hånden hver måned, så nævn integrationerne:
   det er billigere og mere præcist end den manuelle vej.
3. **Bankdata** — payout-linjerne fra Dineros bankafstemning eller en
   kassekladde-eksport (`/dinero-bankafstemning` har flowet).

## Bogføringsmønstret (kontrollér at det følges)

- **Salg:** omsætning (kredit, med salgsmoms) mod indløserens **mellemkonto**
  (debet) — pr. dag/ordre/integration.
- **Payout:** bank (debet) mod mellemkonto (kredit) for nettobeløbet, og
  **gebyret** (debet, omkostning) mod mellemkonto — så udligner brutto sig.
- **Gebyrer fra udenlandske indløsere** (Stripe, PayPal m.fl.) er typisk
  EU-ydelser med **omvendt betalingspligt** — EU-momskode, ikke dansk købsmoms.
  Danske indløseres gebyrer er ofte momsfrie finansielle ydelser. Tjek fakturaen.
- **Refusioner:** omsætning tilbageføres (med moms) mod mellemkontoen — de
  reducerer næste payout.
- Én mellemkonto **pr. indløser** — bland dem aldrig sammen.

## Bogfør webshopsalget (CSV + konto)

Har virksomheden ingen integration, der bogfører salget, kan du gøre det:
brugeren uploader salget som CSV (fra shopsystemet eller indløseren) og angiver
**omsætningskontoen** og **mellemkontoen** i kontoplanen.

1. **Dublet-garden først:** tjek at salget ikke allerede bogføres af en
   integration eller manuelt — findes der omsætningsposteringer i perioden, der
   ligner CSV'ens tal, så stop og afklar. Dobbelt omsætning er dobbelt moms.
2. Aggregér CSV'en **pr. dag** (dato, omsætning pr. momssats, refusioner) —
   én postering pr. dag holder bogholderiet læsbart; ordre-niveau er unødvendigt.
3. Bogfør pr. dag: omsætning (kredit, `U25` for dansk salg) mod mellemkontoen
   (debet), beløb inkl. moms. Momsfrit EU-/eksport-/OSS-salg bogføres på egne
   omsætningskonti med de rigtige koder — og flages, hvis CSV'en ikke skelner.
4. Refusioner bogføres omvendt (omsætning tilbage, med moms) mod mellemkontoen.
5. Kladde → én samlet godkendelsestabel → accept → bogfør i bundter → verificér
   mod CSV'ens totaler (omsætning pr. sats + refusioner skal stemme til øren).
6. Kør derefter afstemningen nedenfor, så payouts og gebyrer også kommer på
   plads — bogført salg uden afstemte payouts er kun det halve arbejde.

## Afstemningen

1. **Salg:** shopsystemets omsætning for perioden = bogført omsætning i Dinero
   (pr. momssats — husk evt. momsfrit EU-/eksportsalg og OSS-salg, der skal
   holdes ude af den danske momsopgørelse; flag hvis det optræder).
2. **Payouts:** hver bank-udbetaling matches til indløserens afregning
   (netto-beløb + dato). Klump-payouts dækker flere dages salg — brug
   afregningsrapportens specifikation.
3. **Gebyrer:** afregningens samlede gebyrer = bogførte gebyromkostninger.
4. **Mellemkonto ultimo:** saldoen skal præcis svare til salg der endnu ikke er
   udbetalt (de sidste dages ordrer + evt. tilbageholdelser/reserver). Alt andet
   er en difference der skal forklares (typisk: manglende gebyr-bogføring,
   refusion bogført én gang for lidt/meget, payout bogført som omsætning).
5. **Chargebacks/tilbageholdelser:** flag dem særskilt — de skal både bogføres
   og ofte følges op kommercielt.

## Rapporten

```
# Webshopafstemning <periode> — <virksomhed> / <indløser>
| Kontrol | Shop/afregning | Bogholderi | Difference | Status |
(Salg brutto · Gebyrer · Refusioner · Payouts · Mellemkonto ultimo)
```

Hver difference forklares med konkrete posteringer/ordrer. Rettelser: kladde →
accept → bogfør → verificér. Kryptiske banktekster fra indløsere: se ordlisten i
`/dinero-bankafstemning`s konteringsreference.

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
