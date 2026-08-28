# Dineros standardkontoplan (verificeret udtræk)

Dineros standardkontoplan med momstype pr. konto. Brug den som opslagsnøgle —
men slå ALTID virksomhedens faktiske kontoplan op først: mange virksomheder har
egne konti, omdøbte konti eller afvigende numre. Findes kontoen ikke hos
virksomheden med det forventede navn, så flag i stedet for at gætte.

## Nøglekonti (de vigtigste at kende udenad)

| Konto | Navn | Rolle |
|---|---|---|
| 53000 | Debitorer, ubetalte fakturaer | Debitorsamlekonto |
| 63000 | Kreditorer, ubetalte regninger | Kreditorsamlekonto |
| 55000 | Bank | Likvid |
| 55040 | Kontanter (kasse) | Likvid |
| 63100 | Udlæg ansatte og ejer | Mellemregning |
| 63300 | Skattekonto | Spejl af SKATs skattekonto |
| 64000 | Salgsmoms (udgående) | Momskonto |
| 64020/64040 | Moms af varer/ydelser fra udlandet | Momskonto |
| 64060 | Købsmoms (indgående) | Momskonto |
| 64100 | Momsafregning | Udligning ved afregning |
| 65000 | Skyldig AM-bidrag | Løn-skyldig |
| 65020 | Skyldig A-skat | Løn-skyldig |
| 65040 | Skyldig ATP | Løn-skyldig |
| 65100 | Skyldig løn | Løn-skyldig |

## Hele planen

| Nummer | Navn | Type | Momstype |
|---|---|---|---|
| 1000 | Salg af varer/ydelser m/moms | Indtægt | U25 |
| 1050 | Salg af varer/ydelser u/moms | Indtægt | — |
| 1100 | EU-leverancer varer - Indberettes (rubrik B-varer) | Indtægt | UEUV |
| 1150 | EU-leverancer varer - Indberettes ikke (rubrik B-varer) | Indtægt | UEUV2 |
| 1200 | EU-leverancer ydelser (rubrik B-ydelser) | Indtægt | UEUY |
| 1255 | Salg af varer til udlandet (rubrik C) | Indtægt | UVV |
| 1260 | Salg af ydelser til udlandet (rubrik C) | Indtægt | UVY |
| 1300 | Salg af fragt - momsfrie | Indtægt | — |
| 1350 | Salg af fragt - momspligtig | Indtægt | U25 |
| 1400 | Rykkergebyrer, administrationsgebyr mv. | Indtægt | — |
| 1445 | Valutakursdifferencer, eksport | Indtægt | — |
| 1500 | Gevinst ved salg af materielle anlægsaktiver | Indtægt | — |
| 1550 | Gevinst ved salg af immaterielle anlægsaktiver | Indtægt | — |
| 2000 | Vareforbrug | Udgift | I25 |
| 2050 | EU-erhvervelser varer (rubrik A-varer) | Udgift | IEUV |
| 2100 | EU-erhvervelser ydelser (rubrik A-ydelser) | Udgift | IEUY |
| 2150 | Varekøb verden | Udgift | IVV |
| 2200 | Ydelseskøb verden | Udgift | IVY |
| 2250 | Fragt med moms | Udgift | I25 |
| 2300 | Fragt uden moms | Udgift | — |
| 2350 | Fragt - EU | Udgift | IEUV |
| 2400 | Valutakursdifferencer, import | Udgift | — |
| 2450 | Varelagerregulering | Udgift | — |
| 2800 | Fremmed arbejde | Udgift | I25 |
| 3000 | AM-indkomst | Udgift | — |
| 3020 | Arbejdsgiver ATP | Udgift | — |
| 3040 | Medarbejder ATP | Udgift | — |
| 3060 | Sygepenge mv. | Udgift | — |
| 3070 | Personalegoder, herunder fri telefon | Udgift | — |
| 3080 | B-honorar | Udgift | — |
| 3090 | Barsel | Udgift | — |
| 3100 | Feriepenge og SH | Udgift | — |
| 3120 | Pension | Udgift | — |
| 3140 | Diæter/rejsegodtgørelse | Udgift | — |
| 3160 | Kørsel i egen bil (kilometergodtgørelse) | Udgift | — |
| 3180 | AER/AES/ATP-finansieringsbidrag | Udgift | — |
| 3200 | Arbejdstøj | Udgift | I25 |
| 3220 | Personaleforsikringer | Udgift | — |
| 3240 | Mad under kursus/møder mv., fuldt fradrag | Udgift | I25 |
| 3260 | Gaver til personalet, fuldt fradrag | Udgift | — |
| 3280 | Uddannelsesudgifter | Udgift | I25 |
| 3300 | Diverse vedr. ansatte med moms | Udgift | I25 |
| 3320 | Diverse vedr. ansatte uden moms | Udgift | — |
| 3340 | Regulering feriepenge | Udgift | — |
| 3355 | Frokostordning til ansatte | Udgift | — |
| 4000 | Annoncer og reklame | Udgift | I25 |
| 4020 | Udsmykning i forbindelse med arrangementer/events | Udgift | I25 |
| 4040 | Hotel, personale, fuldt fradrag | Udgift | I25 |
| 4060 | Hotel, forretningsforbindelser, delvis fradrag | Udgift | I25 |
| 4080 | Konferencer | Udgift | — |
| 4100 | Messer | Udgift | I25 |
| 4120 | Repræsentation, restaurant, personale, fuldt fradrag | Udgift | REP |
| 4140 | Repræsentation, restaurant, forretningsforbindelser, delvis fradrag | Udgift | REP |
| 4160 | Mad i virksomheden til forretningsforbindelser, delvis fradrag | Udgift | I25 |
| 4180 | Repræsentation, gaver og blomster, delvis fradrag | Udgift | — |
| 4200 | Anden fradragsberettiget repræsentation med moms | Udgift | I25 |
| 4220 | Repræsentation, diverse | Udgift | — |
| 4240 | Øvrige personaleomkostninger | Udgift | I25 |
| 4260 | Ej fradragsberettiget andel | Udgift | — |
| 4280 | Rejseomkostninger | Udgift | — |
| 5000 | Husleje | Udgift | I25 |
| 5010 | Husleje uden moms | Udgift | — |
| 5025 | El | Udgift | I25 |
| 5030 | Vand | Udgift | I25 |
| 5035 | Varme | Udgift | I25 |
| 5040 | Elafgift | Udgift | — |
| 5045 | Naturgas- og bygasafgift | Udgift | — |
| 5050 | Vandafgift | Udgift | — |
| 5060 | Rengøring og affaldshåndtering | Udgift | I25 |
| 5080 | Reparation og vedligeholdelse | Udgift | I25 |
| 5100 | Ejendomsskat | Udgift | — |
| 5120 | Ejendomsforsikring | Udgift | — |
| 5140 | Mødelokaler | Udgift | I25 |
| 5160 | Dekoration | Udgift | I25 |
| 6000 | Billeje (gulplade) | Udgift | I25 |
| 6020 | Brændstof (gulplade) | Udgift | I25 |
| 6040 | Vedligeholdelse af bil (gulplade) | Udgift | I25 |
| 6060 | Vægtafgift og forsikringer | Udgift | — |
| 6080 | Parkering (gulplade) | Udgift | I25 |
| 6085 | Parkering uden moms | Udgift | — |
| 6100 | Broafgift | Udgift | I25 |
| 6120 | Taxa | Udgift | — |
| 6140 | Tog | Udgift | — |
| 6160 | Fly | Udgift | — |
| 6180 | Bus | Udgift | — |
| 6200 | Færge | Udgift | I25 |
| 6400 | Diverse transportomkostninger uden moms | Udgift | — |
| 7005 | Revision og regnskabsmæssig assistance | Udgift | I25 |
| 7010 | Advokat | Udgift | I25 |
| 7020 | Bogføringsassistance | Udgift | I25 |
| 7040 | Konsulentbistand | Udgift | I25 |
| 7060 | Kontingenter inkl. moms | Udgift | I25 |
| 7080 | Kontingenter ekskl. moms | Udgift | — |
| 7100 | Aviser | Udgift | — |
| 7120 | Faglitteratur | Udgift | I25 |
| 7140 | Anden litteratur | Udgift | I25 |
| 7160 | Erhvervsforsikringer | Udgift | — |
| 7180 | Fragt og kørsel | Udgift | I25 |
| 7200 | Kontorartikler og tryksager | Udgift | I25 |
| 7220 | Porto og gebyrer | Udgift | — |
| 7240 | Telefoni | Udgift | I25 |
| 7260 | Beskatning af fri telefoni | Udgift | — |
| 7280 | Regnskabsprogram | Udgift | I25 |
| 7300 | Internet og webhotel | Udgift | I25 |
| 7320 | Køb af software | Udgift | I25 |
| 7340 | Konstateret tab på debitorer | Udgift | U25 |
| 7360 | Offentlige bøder og gebyrer | Udgift | — |
| 7380 | Registrerede kassedifferencer | Udgift | — |
| 7400 | Betalingsløsning | Udgift | I25 |
| 7420 | Indløsere | Udgift | — |
| 7440 | Licens | Udgift | — |
| 7460 | Diverse inkl. moms | Udgift | I25 |
| 7480 | Diverse ekskl. moms | Udgift | — |
| 7500 | Generalforsamling, bestyrelsesmøder ude i byen, fuld fradrag | Udgift | REP |
| 7520 | Generalforsamling i virksomhedens lokaler | Udgift | — |
| 7540 | Bestyrelsesmøder i virksomhedens lokaler | Udgift | I25 |
| 7560 | Bestyrelsesmøder ude i byen | Udgift | REP |
| 8000 | Immaterielle anlægsaktiver, afskrivninger | Udgift | — |
| 8020 | Materielle anlægsaktiver, afskrivninger | Udgift | — |
| 8040 | Småanskaffelser (straksafskrivning) | Udgift | I25 |
| 8050 | Småanskaffelser med omvendt betalingspligt | Udgift | OBPK |
| 8065 | Tab ved salg af materielle anlægsaktiver | Udgift | — |
| 8070 | Tab ved salg af immaterielle anlægsaktiver | Udgift | — |
| 9000 | Bankrenter | Indtægt | — |
| 9010 | Renteindtægter diverse | Indtægt | — |
| 9200 | Bankrenter | Udgift | — |
| 9210 | Leverandører mv. | Udgift | — |
| 9220 | Ikke-fradragsberettigede renter | Udgift | — |
| 9400 | Skat af årets resultat | Udgift | — |
| 9410 | Skat af tidligere år | Udgift | — |
| 9420 | Regulering af udskudt skat | Udgift | — |
| 50000 | Immaterielle anlægsaktiver primo | Aktiv | — |
| 50020 | Immaterielle, tilgang i året | Aktiv | I25 |
| 50040 | Immaterielle, afgang i året | Aktiv | — |
| 50060 | Immaterielle, årets afskrivninger | Aktiv | — |
| 51000 | Driftsmiddel saldo primo | Aktiv | — |
| 51020 | Driftsmiddel, tilgang i året | Aktiv | I25 |
| 51040 | Driftsmiddel, afgang i året | Aktiv | — |
| 51060 | Driftsmiddel, årets afskrivninger | Aktiv | — |
| 51500 | Værdipapirer og kapitalandele | Aktiv | — |
| 52000 | Varebeholdning | Aktiv | — |
| 52020 | Nedskrivning | Aktiv | — |
| 53000 | Debitorer, ubetalte fakturaer | Aktiv | — |
| 53020 | Hensat til tab på debitorer | Aktiv | — |
| 54000 | Deposita | Aktiv | — |
| 54020 | Igangværende arbejder | Aktiv | — |
| 54040 | Øvrige tilgodehavender | Aktiv | — |
| 54060 | Periodeafgrænsningsposter | Aktiv | — |
| 55000 | Bank | Aktiv | — |
| 55040 | Kontanter (kasse) | Aktiv | — |
| 60000 | Registreret kapital mv. | Passiv | — |
| 60020 | Overført resultat fra tidligere år | Passiv | — |
| 60040 | Udbytte | Passiv | — |
| 61000 | Hensat til erstatninger | Passiv | — |
| 61020 | Hensat til udskudt skat | Passiv | — |
| 61040 | Hensat feriepengeforpligtelse | Passiv | — |
| 62000 | Banklån | Passiv | — |
| 63000 | Kreditorer, ubetalte regninger | Passiv | — |
| 63010 | Øvrige skyldige omkostninger | Passiv | — |
| 63020 | Kreditorer, efterposteringer | Passiv | — |
| 63040 | Afsat revisor | Passiv | — |
| 63060 | Skyldig selskabsskat | Passiv | — |
| 63080 | Gavekort | Passiv | — |
| 63100 | Udlæg ansatte og ejer | Passiv | — |
| 63300 | Skattekonto | Passiv | — |
| 64000 | Salgsmoms (udgående moms) | Passiv | — |
| 64020 | Moms af varer fra udlandet | Passiv | — |
| 64040 | Moms af ydelser fra udlandet | Passiv | — |
| 64060 | Købsmoms (indgående moms) | Passiv | — |
| 64080 | Elafgift | Passiv | — |
| 64085 | Vandafgift | Passiv | — |
| 64090 | Naturgas- og bygasafgift | Passiv | — |
| 64100 | Momsafregning | Passiv | — |
| 65000 | Skyldig AM-bidrag | Passiv | — |
| 65020 | Skyldig A-skat | Passiv | — |
| 65040 | Skyldig ATP | Passiv | — |
| 65060 | Skyldige feriepenge | Passiv | — |
| 65080 | Skyldig pension | Passiv | — |
| 65100 | Skyldig løn | Passiv | — |
| 65120 | Andre skyldige lønposter | Passiv | — |
| 99999 | Analysekonto | Passiv | — |
