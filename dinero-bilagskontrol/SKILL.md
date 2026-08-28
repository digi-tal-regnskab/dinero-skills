---
name: dinero-bilagskontrol
description: >
  Bilagskontrol i Dinero via Dineros officielle MCP-server — begge veje: find
  materiale der IKKE er bogført (løse bilag i arkivet, ubogførte købs-kladder,
  ubogførte udlæg betalt privat), og find bogførte posteringer UDEN dokumentation
  (momsfradrag kræver bilag). Leverer en mangelliste brugeren kan handle på. Brug
  denne skill når brugeren nævner manglende bilag, løse bilag, bilagsarkivet,
  ubogførte bilag/udlæg, dokumentationskontrol, "er alle bilag bogført?", "hvilke
  posteringer mangler bilag?" eller bilagsoprydning i dansk Dinero-kontekst.
license: MIT
---

# Dinero-bilagskontrol — begge veje

To spørgsmål, der tilsammen giver ro i maven før moms og årsafslutning:

1. **Er alt materiale bogført?** (bilag der ligger i arkivet uden at være blevet
   til posteringer — herunder udlæg betalt privat)
2. **Er alt bogført dokumenteret?** (posteringer uden tilknyttet bilag —
   momsfradrag uden bilag holder ikke ved kontrol)

## Vej 1: Materiale der ikke er bogført

1. Gennemgå bilagsarkivet og del filerne op efter om de er knyttet til et
   bogført bilag eller ej.
2. **Auto-kladder er bare løse bilag.** Dinero behandler filtyper forskelligt
   ved upload: et billede (PNG) lander kun i arkivet, mens en PDF typisk også
   får auto-oprettet en købs-**kladde** — som brugeren ikke selv har lavet og
   sjældent kender til. Behandl derfor en ubogført købskladde som det den er:
   **et stykke dokumentation i arkivet**, ikke en postering der venter på at
   blive færdiggjort. Den kan vedhæftes en postering — også en
   kassekladde-postering — og når posteringen bogføres med filen tilknyttet,
   forsvinder auto-kladden af sig selv, fordi dokumentet er brugt. Alle
   ubogførte bilag (med eller uden auto-kladde) rapporteres i ÉN bunke: **løse
   bilag, der skal konteres og bogføres** (`/dinero-bogfoering`); læs dem
   (dato, beløb, leverandør) via PDF-hentning.
3. **Ubogførte udlæg** — det klassiske hul: et bilag i arkivet som IKKE modsvares
   af nogen bankbetaling er sandsynligvis betalt privat (ejerens/medarbejderens
   udlæg) eller fra en anden konto. Det skal bogføres med **mellemregning som
   modkonto** i stedet for bank (`/dinero-mellemregning` for kontrol af saldoen).
   Det fulde, dedikerede udlægstjek — inkl. fejlbogføringer mod bank og
   refusioner uden dokumentation — er `/dinero-udlaegstjek`.
   - Afgørelsen kræver bankdata: bed om kassekladde-eksport/bankudtræk
     (`/dinero-bankafstemning` har flowet) og match bilag mod bankbetalinger
     (beløb + dato-vindue + leverandør).
   - Uden bankdata: list bilagene og spørg brugeren pr. bilag hvordan det er
     betalt — gæt aldrig modkontoen.

## Vej 2: Bogført uden dokumentation

1. Gennemgå periodens bogførte posteringer/bilag og find dem uden tilknyttet fil.
   Sig tydeligt hvilket datagrundlag opslagene gav dig — og nævn det, hvis
   fil-tilknytning ikke kan ses for alle posteringstyper.
2. Prioritér efter risiko: **udgiftskonti med momsfradrag først** (fradrag kræver
   dokumentation), derefter store beløb.
3. Undtag konti der normalt ikke kræver bilag: løn, A-skat/AM/ATP,
   skattekonto-/momsafregninger, mellemregning, bankgebyrer, renter og
   debitor-indbetalinger (dokumentationen er dér lønsedler, SKAT-afregninger og
   fakturaer — ikke et arkivbilag pr. postering).
4. For hver fundet postering: dato, tekst, beløb, konto, momskode — og hvad der
   skal skaffes (faktura/kvittering fra hvem).

## Mangellisten (output)

```
# Bilagskontrol <periode> — <virksomhed>

## Løse bilag (kontér og bogfør — auto-kladder tæller med her)
| Bilag | Dato | Beløb | Leverandør | Handling |

## Mulige udlæg (bilag uden bankbetaling)
| Bilag | Dato | Beløb | Leverandør | Spørgsmål til brugeren |

## Bogført uden bilag (skaf dokumentation)
| Dato | Tekst | Beløb | Konto | Moms | Skaf fra |
```

Afslut med en prioriteret handlingsliste. Alt der skal oprettes/rettes: kladde →
accept → bogfør → verificér. Leverandør-vinklen på manglende bilag (match mod
leverandørens kontoudtog): `/dinero-leverandoerafstemning`.

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
