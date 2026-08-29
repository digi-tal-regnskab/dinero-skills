---
name: dinero-mellemregning
description: >
  Kontrol af mellemregning med ejer/holding i Dinero via Dineros officielle
  MCP-server: gennemgå mellemregningskontoen postering for postering, kræv forklaring og
  bilag, og flag kapitalejerlån når selskabet har penge til gode hos ejeren — lånet er
  lovligt selskabsretligt, men beskattes hos ejeren allerede ved låneoptagelsen.
  Brug denne skill når brugeren nævner mellemregning, mellemregningskonto, udlæg,
  private hævninger, ejerlån, kapitalejerlån, anpartshaverlån eller "hvad står der på
  min mellemregning?" i dansk Dinero-kontekst.
license: MIT
---

# Dinero-mellemregning — ejer og holding

Mellemregningen er der hvor privatøkonomi og selskab mødes — og hvor de dyreste
fejl bor. Gennemgå den nysgerrigt og systematisk.

## Arbejdsgang

1. Find mellemregningskontoen/-kontiene i kontoplanen (standardkontoplanen:
   **63100 "Udlæg ansatte og ejer"**; holding har ofte sin egen konto) og hent
   kontospecifikationen for perioden. **Findes der ingen mellemregningskonto:**
   du kan ikke oprette den — MCP'en kan ikke røre kontoplanen. Bed brugeren
   oprette den i Dinero (Indstillinger → Kontoplan) under kortfristet gæld, og
   vent på at det er gjort, før du bogfører noget. Kontér aldrig mellemregning
   på en tilfældig eksisterende konto for at komme videre.
2. Klassificér hver postering: udlæg (ejer har lagt ud — kræver bilag), privat
   hævning, indskud, løn-relateret, overførsel til/fra holding, ukendt.
3. **Ukendte posteringer flagges** — kontér aldrig "et eller andet" på
   mellemregning for at få noget til at stemme; det er sådan mellemregninger bliver
   uforklarlige.
4. Gør saldoen og dens retning eksplicit: skylder selskabet ejeren penge, eller
   omvendt?

## Kapitalejerlån (ApS/A/S) — det skarpe flag

En saldo hvor **selskabet har penge til gode hos ejeren** (ejeren har hævet mere
end indskudt) er et kapitalejerlån. **Det er ikke ulovligt** — det selskabsretlige
forbud blev ophævet i 2017, og et kapitalselskab må yde lån til sine kapitalejere
uden specifikke lovgivningsmæssige betingelser (selskabsloven § 210). Ledelsen skal
dog sikre, at lånet er forsvarligt (§§ 115-118) og ikke i strid med § 127.

**Smerten er skattemæssig, ikke selskabsretlig** — og den overrasker de fleste:
skattereglerne blev ikke ændret i 2017. Et lån til en kapitalejer med bestemmende
indflydelse beskattes **allerede på långivningstidspunktet** som løn eller udbytte
(ligningsloven § 16 E, indført 2012), uanset at pengene skal betales tilbage. En
senere tilbagebetaling fjerner ikke beskatningen. Sig det præcist — «ulovligt» er
forkert og undergraver troværdigheden.

Regnskabsmæssigt skal lånet vises særskilt under «Tilgodehavende hos
virksomhedsdeltagere og ledelse», og der er notekrav ved lån til et ledelsesmedlem
(årsregnskabsloven § 73). Reglerne er situationsafhængige:

- Flag saldoen og de posteringer der skabte den, tydeligt og uden dramatik.
- Henvis til revisor for håndteringen — foreslå IKKE selv "løsninger" (udbytte,
  løn, tilbagebetaling) som fakta; nævn dem højst som spor revisor kan vurdere.
- I enkeltmandsvirksomheder findes problemet ikke (privatudtag er lovlige) — dér
  er fokus i stedet at holde privat og erhverv adskilt.

## Holding-mellemregning

Overførsler mellem selskab og holding skal spejle hinanden: samme beløb på
modpartens mellemregning. Har du adgang til begge organisationer i Dinero, så
afstem de to konti mod hinanden og forklar differencer (typisk timing eller
posteringer bogført som noget andet i det ene selskab).

## Rapportering

Saldo + retning, klassificeret posteringsliste, flag-liste (ukendte + evt.
kapitalejerlån) og manglende bilag. Rettelser: kladde, accept, bogfør, verificér.

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
