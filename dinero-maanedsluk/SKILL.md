---
name: dinero-maanedsluk
description: >
  Månedsafslutning (månedsluk) i Dinero via Dineros officielle MCP-server: kør hele
  lukke-tjeklisten — bilag, bank, debitorer, kreditorer, moms, mellemregning, løn/
  skattekonto og resultat-rimelighed — og levér én samlet statusrapport med differencer
  og handlingspunkter. Brug denne skill når brugeren nævner månedsafslutning, månedsluk,
  periodelukning, kvartalsafslutning, "luk måneden", "er måneden klar?" eller vil have
  et samlet kontroltjek af regnskabet i dansk Dinero-kontekst.
license: MIT
---

# Dinero-månedsluk — den samlede tjekliste

Formålet: at kunne sige "måneden er lukket" med dokumentation — eller præcis hvad
der mangler. Kør punkterne i rækkefølge og rapportér status pr. punkt
(OK / difference + forklaring / kræver bruger). Er søster-skills installeret
(fx `/dinero-bankafstemning`, `/dinero-momskontrol`), så følg deres dybere
arbejdsgange for de enkelte punkter — ellers dækker resuméerne her.

## Tjeklisten

1. **Bilag:** Løse bilag i arkivet (auto-oprettede købskladder tæller som løse
   bilag — de er dokumentation, ikke igangværende arbejde)? Bogførte posteringer
   uden dokumentation? Ubogførte udlæg (bilag uden bankbetaling)?
   `/dinero-bilagskontrol` har begge veje — få det fundet og bogført
   (kladde → accept → bogfør).
2. **Bank:** Bogholderiets banksaldo vs. faktisk bank. Kør Dineros egen
   automatiske bankafstemning først; MCP'en kan ikke hente bankdata, så bed om
   de linjer den ikke kunne matche (`/dinero-bankafstemning`) og forklar
   differencen ned til nul.
3. **Debitorer:** Summen af åbne salgsfakturaer = debitorsamlekontoen. Aldersfordel
   de åbne (rykker-kandidater).
4. **Kreditorer:** Summen af åbne købsbilag = kreditorsamlekontoen (husk:
   kontantkøb rører ikke samlekontoen).
5. **Moms:** Salgsmoms = 25 % af momspligtig omsætning; købsmoms rimelig;
   EU-køb neutrale; ingen gamle uudlignede momssaldi.
6. **Mellemregning:** Forklarlig og dokumenteret; flag hvis selskabet har penge
   til gode hos ejeren (muligt kapitalejerlån → revisor).
7. **Løn/skattekonto:** Lønposteringer matcher lønsystem/eIndkomst
   (`/dinero-loenafstemning`), og skattekonto-trækkene udligner skyldig-kontiene
   som forventet (`/dinero-skattekonto-afstemning`).
8. **Resultat-rimelighed:** Sammenlign resultatopgørelsen med forrige måneder.
   Flag markante afvigelser — og manglende faste poster (husleje, løn, abonnementer
   der plejer at være der): en manglende post er lige så mistænkelig som en ny stor.

## Den samlede rapport

```
# Månedsluk <måned år> — <virksomhed>
| # | Kontrol | Status | Difference | Forklaring/handling |
```

Afslut med en prioriteret handlingsliste (manglende bilag, omposteringer,
kunder der skal rykkes i Dineros rykker-modul) som brugeren kan sige ja til punkt
for punkt. Alle rettelser oprettes som kladde og bogføres først efter accept — og
verificér med friske opslag før du erklærer måneden lukket. Er det årets sidste
måned: fortsæt med `/dinero-aarsafslutning`.

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
