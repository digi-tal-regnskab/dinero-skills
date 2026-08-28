---
name: dinero-udlaegstjek
description: >
  Udlægstjek i Dinero via Dineros officielle MCP-server: krydser tre kilder —
  bankdata (kassekladde-eksport), alle bogførte posteringer og bilagsarkivet — og
  finder udlæg i alle afskygninger: bilag betalt privat der aldrig er bogført,
  posteringer fejlbogført mod bank uden bankbetaling, refusioner udbetalt uden
  dokumentation, og mellemregnings-posteringer uden bilag. Brug denne skill når
  brugeren nævner udlæg, udlægstjek, udlæg efter regning, refusion af udgifter,
  "har jeg lagt ud privat?", medarbejderudlæg, eller vil rydde op i
  udlæg/mellemregning i dansk Dinero-kontekst.
license: MIT
---

# Dinero-udlægstjek — tre kilder krydses

Et udlæg er en erhvervsudgift betalt med private penge. De gemmer sig i hullerne
mellem tre kilder, som hver især ser komplette ud:

1. **Bankdata** — brugerens fil (MCP'en kan ikke hente bank): kassekladde-eksport
   fra Dinero (bankimport → eksportér CSV) eller netbank-udtræk.
2. **Bogførte posteringer** — via MCP (kontospecifikationer for perioden, især
   bank- og mellemregningskonti).
3. **Bilagsarkivet** — via MCP (filer + deres tilknytning; læs bilag som PDF for
   dato/beløb/leverandør).

Uden bankdata kan tjekket kun laves delvist — sig præcis hvad der så IKKE kan
kontrolleres, og bed om filen.

## De fem fund-typer

Kør matchingen (beløb + dato-vindue + leverandør, jf. heuristikkerne i
`/dinero-bankafstemning`) og sortér alt i disse bunker:

1. **Ubogført udlæg:** Bilag i arkivet UDEN bankbetaling og UDEN bogført
   postering → sandsynligvis betalt privat. Skal bogføres med **mellemregning som
   modkonto** (ikke bank). Momsfradrag kun med gyldigt bilag — og bemærk om
   bilaget er udstedt til virksomheden.
2. **Fejlbogført mod bank:** Postering bogført med bank som modkonto, men ingen
   tilsvarende bankbetaling findes → betalt privat eller fra anden konto →
   foreslå ompostering af modkontoen til mellemregning (ellers stemmer banken
   aldrig).
3. **Refusion uden dokumentation:** Bankudbetaling til ejer/medarbejder (tekster
   som "udlæg", "refusion", personnavne) uden et modsvarende bilag/bogført udlæg.
   Flag skarpt: skattefri refusion ("udlæg efter regning") kræver et **eksternt
   udgiftsbilag der indgår i virksomhedens regnskabsmateriale** — uden bilag
   risikerer refusionen at være skattepligtig løn for modtageren. Henvis til
   revisor ved tvivl; sig det uden drama.
4. **Mellemregning uden bilag:** Posteringer på mellemregningskontoen der ligner
   udlæg/refusioner men mangler tilknyttet bilag → skaf dokumentationen
   (fuld kontosaldo-kontrol: `/dinero-mellemregning`).
5. **Privat-lignende udlæg:** Bilag/posteringer i udlægs-bunkerne der ligner
   private udgifter (rejser, elektronik, restaurant uden anledning) → flag til
   brugerens vurdering. Rent private udgifter kan ikke refunderes skattefrit og
   hører ikke i regnskabet som omkostning.

## Arbejdsgang

1. Afgræns perioden og bekræft organisationen.
2. Indhent de tre kilder (bed om bankfilen først — resten kan du selv hente).
3. Match og sortér i de fem bunker. Vær konservativ: usikre match er FORSLAG
   ("er det samme som …?"), ikke konklusioner.
4. Præsentér rapporten og få accept pr. handling.
5. Udfør: nye udlægs-posteringer som **kladde** mod mellemregning →
   accept → bogfør → verificér. Omposteringer ligeså.

## Rapporten

```
# Udlægstjek <periode> — <virksomhed>

## 1. Ubogførte udlæg (bogfør mod mellemregning)
| Bilag | Dato | Beløb | Leverandør | Moms mulig? |

## 2. Fejlbogført mod bank (ompostér til mellemregning)
| Postering | Dato | Beløb | Konto | Problem |

## 3. Refusioner uden dokumentation (skaf bilag / vurder med revisor)
| Bankdato | Modtager | Beløb | Fundet bilag? |

## 4. Mellemregning uden bilag
| Dato | Tekst | Beløb | Handling |

## 5. Til vurdering (privat/erhverv)
| Bilag/postering | Beløb | Hvorfor flagget |

Netto-effekt på mellemregning: <beløb> (retning: virksomheden skylder ejeren /
ejeren skylder virksomheden)
```

Slut altid med mellemregningens forventede saldo EFTER handlingerne — og flag
hvis retningen bliver "virksomheden har penge til gode hos ejeren" i et ApS
(muligt kapitalejerlån → `/dinero-mellemregning`).

## Grundregler (fælles for alle Dinero-skills)

Du arbejder i en rigtig virksomheds rigtige regnskab via Dineros officielle
MCP-server (beta). Arbejd som en omhyggelig bogholder: forstå, foreslå, få accept,
udfør, verificér.

1. **Kladde først — bogfør aldrig uden eksplicit accept.** Bogført er reelt
   permanent: via MCP kan bogførte dokumenter ikke slettes, og sletter brugeren
   dem i Dineros UI, er fakturanummeret alligevel forbrugt. Vis brugeren præcis hvad du
   har lavet (beløb, konto, momskode, dato, modpart) før der bogføres. Kladder kan
   slettes — dog kan finansbilag-kladder kun slettes i Dineros UI, ikke via MCP —
   og bogfør aldrig noget "for at prøve".
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
   I finansbilag skal momskoden sidde på linjens **hovedkonto** — en momskode på
   modkontoen bliver IKKE beregnet (kladden viser moms 0). Vend i stedet
   retningen med et negativt beløb (fx salg som minus på omsætningskontoen), og
   verificér ALTID kladdens momssplit med et frisk opslag, FØR der bogføres.
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
