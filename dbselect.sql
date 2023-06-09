SELECT * FROM Pokoj;
SELECT * FROM Pobyt;
SELECT * FROM Platba;
SELECT * FROM Sluzba;
SELECT * FROM PozadavekNaSluzbu;
SELECT * FROM PokojVPobytu;
SELECT * FROM Uzivatel;
SELECT * FROM Recepcni;
SELECT * FROM Zakaznik;

-- Z jakych zemi jsou zakaznici?
SELECT DISTINCT narodnost
FROM Zakaznik;

--ktere platby byly zaplaceny v hotovosti?
SELECT *
FROM Platba
WHERE TYP_PLATBY = 'hotovost';

-- Ve kterych pobytech byl zahrnut pokoj cislo 1?
SELECT *
FROM Pobyt
WHERE pobyt_id IN (
SELECT pobyt_id
FROM PokojVPobytu
WHERE pokoj_id = 1
);

-- Existuje pobyt, ve kterem je zahrunta sluzba se snidani?
SELECT * FROM POZADAVEKNASLUZBU;
SELECT POBYT_ID FROM Pobyt
WHERE EXISTS(
SELECT *
FROM PozadavekNaSluzbu
WHERE POBYT_ID = Pobyt.POBYT_ID AND SLUZBA_ID = 1
);

-- ktere platby jiz byly zaplaceny?
SELECT DISTINCT Pl.*
From PLATBA Pl, POBYT P
WHERE Pl.POBYT_ID=P.POBYT_ID AND ZAPLACENO = 1;

-- Kolik kazdy zakaznik, ktery si objednal pobyt, zaplatil na platbach?
SELECT * FROM Platba;
SELECT  u.JMENO, u.PRIJMENI, p.POBYT_ID, COUNT(*) AS pocet, SUM(pl.castka) AS celkem
FROM pobyt p
JOIN platba pl ON p.POBYT_ID = pl.POBYT_ID
JOIN zakaznik z ON p.ZAKAZNIK_ID = z.ZAKAZNIK_ID
JOIN uzivatel u ON z.UZIVATEL_ID = u.UZIVATEL_ID
GROUP BY p.POBYT_ID, u.JMENO, u.PRIJMENI;

--Kolik bylo prumerne rezervovano pokoju na jeden pobyt?
SELECT ROUND(AVG(pocet_pokoju)) AS prumerny_pocet_pokoji_na_pobyt
FROM (
  SELECT pobyt_id, COUNT(*) AS pocet_pokoju
  FROM PokojVPobytu
  GROUP BY pobyt_id
);

-- Kolik penez bylo utraceno v pobytech s konkretnim pokojem
SELECT p.POKOJ_ID, p.POCET_LUZEK, SUM(pl.CASTKA) FROM pobyt pob
JOIN platba pl ON pob.POBYT_ID = pl.POBYT_ID
JOIN POKOJVPOBYTU Pvp on pob.POBYT_ID = Pvp.POBYT_ID
JOIN POKOJ P on Pvp.POKOJ_ID = P.POKOJ_ID
GROUP BY p.POKOJ_ID, p.POCET_LUZEK;

-- EXPLAIN PLAN a vytvoreni indexu
-- Kolik penez bylo celkove utraceno v pokojich s konkretnim poctem luzek
EXPLAIN PLAN FOR
SELECT p.POCET_LUZEK, COUNT(p.POKOJ_ID) AS pocet_pokoju, SUM(pl.CASTKA) AS celkova_castka
FROM POKOJ p
JOIN POKOJVPOBYTU rr ON p.POKOJ_ID = rr.POKOJ_ID
JOIN Pobyt res ON rr.POBYT_ID = res.POBYT_ID
JOIN PLATBA pl ON res.POBYT_ID = pl.POBYT_ID
GROUP BY p.POCET_LUZEK;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY());

CREATE INDEX idx_platba_pobyt_id ON PLATBA(POBYT_ID);

DROP INDEX idx_platba_pobyt_id;

-- Pobyty a celkovy pocet luzek
SELECT pob.POBYT_ID, SUM(p.POCET_LUZEK) AS pocet_luzek FROM pobyt pob
JOIN POKOJVPOBYTU Pvp on pob.POBYT_ID = Pvp.POBYT_ID
JOIN POKOJ P on Pvp.POKOJ_ID = P.POKOJ_ID
GROUP BY pob.POBYT_ID;

-- dotaz, ktery zaradi pobyt do kategorie podle poctu sluzeb
-- pokud mel stejne nebo vice sluzeb nez prumer -> nadprumerna
-- pokud mel mene sluzeb nez prumer -> podprumerna
WITH
  celkovy_pocet_sluzeb AS (
    SELECT pobyt_id, COUNT(*) AS pocet_sluzeb
    FROM XVECER30.PozadavekNaSluzbu
    GROUP BY pobyt_id
  ),
  prumer AS (
    SELECT AVG(pocet_sluzeb) AS prumerny_pocet_sluzeb
    FROM celkovy_pocet_sluzeb
  )
SELECT
  celkovy_pocet_sluzeb.pobyt_id, celkovy_pocet_sluzeb.pocet_sluzeb,
  CASE
    WHEN celkovy_pocet_sluzeb.pocet_sluzeb >= prumer.prumerny_pocet_sluzeb THEN 'nadprumerna'
    ELSE 'podprumerna'
  END AS kategorie
FROM celkovy_pocet_sluzeb, prumer
ORDER BY pobyt_id;