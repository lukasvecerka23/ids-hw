SELECT * FROM Pokoj;
SELECT * FROM Pobyt;
SELECT * FROM Platba;
SELECT * FROM Sluzba;
SELECT * FROM PozadavekNaSluzbu;
SELECT * FROM PokojVPobytu;
SELECT * FROM Uzivatel;
SELECT * FROM Recepcni;
SELECT * FROM Zakaznik;

SELECT *
FROM Zakaznik;

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
)