# Kontering og moms — danske regler for Dineros standardkontoplan

Reglerne her er udgangspunktet for virksomheder på Dineros standardkontoplan.
**Virksomhedens egen historik vægter altid højere:** har den konsekvent brugt en
bestemt konto til en leverandør, så følg det. Slå altid den faktiske kontoplan op
først — mange virksomheder har egne konti eller afvigende numre.

## Momskoder

Koderne er verificeret mod Dineros standardkontoplan (`standardkontoplan.md`):

| Situation | Momskode |
|---|---|
| Dansk køb med moms (25 %) og bilag | `I25` |
| Dansk salg med moms | `U25` |
| EU-varekøb (rubrik A-varer) | `IEUV` |
| EU-ydelseskøb (rubrik A-ydelser) | `IEUY` |
| Vare-/ydelseskøb uden for EU | `IVV` / `IVY` |
| EU-varesalg (rubrik B-varer) | `UEUV` (indberettes) / `UEUV2` (indberettes ikke) |
| EU-ydelsessalg (rubrik B-ydelser) | `UEUY` |
| Salg af varer/ydelser til verden (rubrik C) | `UVV` / `UVY` |
| Repræsentation, restaurant | `REP` (kvartmoms) |
| Dansk køb med omvendt betalingspligt | `OBPK` |
| Momsfrit: forsikring, bøder, løn, skat, mellemregning, gebyrer, parkering u. moms | ingen momskode |
| Køb UDEN bilag | ingen momskode — momsfradrag kræver dokumentation; flag det manglende bilag |

Momskoden afgør Dineros automatiske momssplit. Forkert kode = forkert
momsindberetning, så vælg hellere ingen moms + et spørgsmål end et gæt.

## Fortegn i bankdata

I typiske bankudtræk/kassekladder er **positivt beløb = penge ud (udgift)** og
negativt = penge ind. Indbetalinger skal normalt ikke konteres som udgifter, men
afstemmes mod fakturaer (betalingsregistrering) — bland ikke de to flows sammen.

## Typiske konteringer (Dineros standardkontoplan)

Mest specifikke mønster først. Nøgleord matches mod banktekst/leverandørnavn i små
bogstaver. Strip betalings-præfikser ("DBT.", "Til ", "To ", "Mob.Pay*") før matchning.

| Type | Typisk konto | Kendetegn / eksempler |
|---|---|---|
| Skattekonto (A-skat, AM-bidrag, moms) | 63300 | "skattestyrelsen", "moms", faste træk til SKAT — 63300 spejler SKATs skattekonto |
| Løn (AM-indkomst) | 3000 | lønkørsler; nettoløn udbetales mod bank/65100 (skyldig løn) |
| ATP (arbejdsgiver/medarbejder) | 3020 / 3040 | ATP fra lønkørslen; skyldig ATP = 65040 |
| AER/AES/ATP-finansieringsbidrag | 3180 | "samlet betaling", lille kvartalsbeløb |
| Mellemregning ejer ("Udlæg ansatte og ejer") | 63100 | "udlæg", "lån", "aconto" til/fra ejeren |
| Brændstof (gulpladebil) | 6020 | Circle K, Uno-X, Q8, Shell, OK |
| Parkering (uden moms) | 6085 | EasyPark, parkering |
| Vægt-/periodeafgift bil | 6060 | "vægtafgift", "periodeafgift", Motorregistret |
| Vedligehold bil | 6040 | værksted, bilsyn |
| Telefoni | 7240 | teleselskaber |
| Internet/web/hosting | 7300 | internetudbyder, webhotel, domæner |
| Erhvervsforsikring (momsfri) | 7160 | forsikringsselskaber |
| Bankgebyrer | 7220 | "fee", "gebyr" fra banken |
| Software/regnskabsprogram | 7280 | Dinero, SaaS-abonnementer |
| Revisor/bogholder | 7020 | regnskabskontor, revisor |
| Fragt/levering | 7180 | fragtfirmaer |
| Fremmed arbejde/underleverandører | 2800 | fakturaer fra håndværker-underleverandører |
| Vareforbrug/materialer | 2000 | byggemarkeder, grossister, varekøb |
| Husleje | 5010/5000 | fast tilbagevendende overførsel til udlejer |
| Repræsentation, restaurant | 4120/4140 | **REP-kvartmoms**; personale fuldt fradrag (4120), forretningsforbindelser delvist (4140) |
| Repræsentation, gaver/blomster | 4180 | delvist fradrag — flag |
| Offentlige bøder | 7360 | politi, p-afgift fra det offentlige — **intet fradrag, ingen moms** |
| Betalingsløsning / indløser-gebyrer | 7400 / 7420 | Stripe/Nets/MobilePay-gebyrer |
| Småanskaffelser (straksafskrivning) | 8040 | under småaktiv-grænsen; m. omvendt betalingspligt: 8050 |
| Konstateret tab på debitorer | 7340 | OBS: momskode U25 — salgsmomsen tilbageføres ved konstateret tab |
| Bankrenter (udgift) | 9200 | renter fra banken |
| Rykkergebyrer (indtægt) | 1400 | momsfri indtægt |

Kontonumrene er verificeret mod Dineros standardkontoplan — hele planen med
momstype pr. konto ligger i `standardkontoplan.md`. Brug dem alligevel kun efter
at have bekræftet at kontoen findes i virksomhedens egen kontoplan med det
forventede navn.

## Kryptiske banktekster — kendte mønstre

| Banktekst-mønster | Betydning | Håndtering |
|---|---|---|
| "Fees according to advice", "Annual fee" | Bankgebyr/kortgebyr | Gebyr-konto, ingen moms |
| "F24" | Q8/F24 brændstofkort | Brændstof, købsmoms |
| "DBT." / "DBTS" | Betalingsservice-træk — modtageren står EFTER præfikset | Kontér efter modtageren |
| "Payment from Nets/Clearhaus" o.l. | Indløser-afregning (kortsalg, webshop) | Mellemkonto + afstem mod indløser-udtog — IKKE direkte omsætning uden afstemning |
| Klumpede MobilePay-indbetalinger | MobilePay-salg | MobilePay-mellemkonto + efterspørg MobilePay-udtog |
| "FACEBK", Google Ads, Meta | EU-annoncer med **omvendt betalingspligt** | Reklame/EU-ydelseskøb — EU-momskode, ikke I25 |
| Adobe, udenlandsk SaaS | EU-software, ofte omvendt betalingspligt | Software-konto, EU-momskode — vurder |
| "Apple.com/bill", YouTube Premium o.l. | Ofte privat | FLAG — privat eller erhverv? |
| Revolut, Lunar, Wise-overførsler | Overførsel til separat konto | FLAG — kræver den kontos eget udtog |
| Collectia, Intrum, Lowell | Inkasso | FLAG — egen gæld eller debitor-inkasso? |
| "INFO-OVF…"-overførsler | Ofte SKAT/løn-relateret | Afstem mod skattekonto/lønmønstret nedenfor |

## Skal ALTID flagges til brugeren (kontér ikke automatisk)

- MobilePay-betalinger til personer eller ukendte modtagere.
- Store enkeltbetalinger uden tydelig modtager i teksten.
- Mad, kantine, supermarked — privat eller erhverv? Fradragsreglerne afhænger af svaret.
- Repræsentation (delvist momsfradrag, delvis skattemæssig fradragsret).
- Tilbagevendende overførsler med uklart formål — men tjek først om mønstret ligner
  løn/skat (fast beløb + træk på skattekontoen samme måned = sandsynligvis
  nettoløn + A-skat).
- Alt der kan være privatudgifter i en enkeltmandsvirksomhed/ApS (hævninger, rejser,
  elektronik uden kontekst) — hører muligvis til på mellemregning.

## Løn-mønstret

Virksomheder med ansatte har typisk tre faste bevægelser hver måned: nettoløn
(fast beløb → lønudgift 3000 / skyldig løn 65100), A-skat + AM-bidrag (varierende
→ skattekonto 63300, der udligner skyldig-kontiene 65020/65000) og ATP
kvartalsvis (lille beløb → 65040/3020). Ser du det mønster, så kontér efter det — og
afstem gerne beløbene mod virksomhedens lønsystem/eIndkomst hvis brugeren kan levere
tallene.
