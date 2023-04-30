-- Pohled pro zobrazeni celkovych cen vsech pobytu s prijmenim cloveka, ktery k pobytu patril
CREATE MATERIALIZED VIEW celkova_cena_pobytu
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT pob.pobyt_id, SUM(pl.castka) AS celkova_cena, uziv.prijmeni
FROM XVECER30.pobyt pob
JOIN XVECER30.platba pl ON pob.pobyt_id = pl.pobyt_id
JOIN XVECER30.zakaznik zak ON pob.zakaznik_id = zak.zakaznik_id
JOIN XVECER30.uzivatel uziv ON zak.uzivatel_id = uziv.uzivatel_id
GROUP BY pob.pobyt_id, uziv.prijmeni
ORDER BY pob.pobyt_id;

SELECT * FROM celkova_cena_pobytu;

DROP MATERIALIZED VIEW celkova_cena_pobytu;

-- Pohled pro zobrazeni prehledu poctu rezervaci podle mesicu
CREATE MATERIALIZED VIEW pocet_rezervaci_mesicne
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS SELECT TO_CHAR(pob.od, 'MM/YYYY') AS mesic, COUNT(*) AS pocet_rezervaci
FROM XVECER30.pobyt pob
GROUP BY TO_CHAR(pob.od, 'MM/YYYY')
ORDER BY TO_DATE(TO_CHAR(pob.od, 'MM/YYYY'), 'MM/YYYY') DESC;

SELECT * FROM pocet_rezervaci_mesicne;

DROP MATERIALIZED VIEW pocet_rezervaci_mesicne;