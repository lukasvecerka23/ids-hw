-- IDS - Databazove systemy FIT VUT 2022/23
-- Lukas Vecerka xvecer30
-- Veronika Nevarilova xnevar00

-- Vytvoreni tabulek databaze
CREATE TABLE Pokoj (
    pokoj_id NUMBER GENERATED ALWAYS AS IDENTITY,
    pocet_luzek INTEGER CHECK (pocet_luzek > 0),
    cena DECIMAL(10,2) CHECK (cena >= 0),
    CONSTRAINT PK_pokoj PRIMARY KEY (pokoj_id)
);

CREATE TABLE Pobyt (
    pobyt_id NUMBER GENERATED ALWAYS AS IDENTITY,
    od DATE,
    do DATE,
    zakaznik_id INTEGER,
    recepcni_id INTEGER,
    CONSTRAINT PK_pobyt PRIMARY KEY (pobyt_id)
);

CREATE TABLE Platba(
    platba_id NUMBER GENERATED ALWAYS AS IDENTITY,
    castka DECIMAL(10,2) CHECK (castka > 0),
    typ_platby VARCHAR(20) CHECK ( typ_platby IN ('hotovost', 'karta') ),
    zaplaceno NUMBER(1),
    pobyt_id INTEGER,
    recepcni_id INTEGER,
    CONSTRAINT PK_platba PRIMARY KEY (platba_id)
);

CREATE TABLE Sluzba(
    sluzba_id NUMBER GENERATED ALWAYS AS IDENTITY,
    nazev VARCHAR(20),
    cena DECIMAL(10,2) CHECK (cena > 0),
    CONSTRAINT PK_sluzba PRIMARY KEY (sluzba_id)
);

CREATE TABLE PozadavekNaSluzbu(
    pobyt_id INTEGER,
    sluzba_id INTEGER,
    CONSTRAINT PK_pozadavek_na_sluzbu PRIMARY KEY (pobyt_id, sluzba_id)
);

CREATE TABLE PokojVPobytu(
    pobyt_id INTEGER,
    pokoj_id INTEGER,
    CONSTRAINT PK_pokoj_v_pobytu PRIMARY KEY (pobyt_id, pokoj_id)
);

-- Generalizaci jsme vyresili tak, ze jsme vytvorili tabulku Uzivatel, ktera obsahuje vsechny uzivatele systemu.
-- Nasledne potom databaze obsahuje tabulky recepcni a zakaznik pro rozdeleni uzivatelu do jednotlivych specializaci.
-- Recepni a zakaznik potom obsahuji id uzivatele, ke kteremu patri. Obsahuji take rozsirujici atributy uzivatele.
CREATE TABLE Uzivatel(
    uzivatel_id NUMBER GENERATED ALWAYS AS IDENTITY,
    jmeno VARCHAR(20) CHECK (REGEXP_LIKE(jmeno, '^[a-zA-Z\s]{2,20}$')),
    prijmeni VARCHAR(20) CHECK (REGEXP_LIKE(prijmeni, '^[a-zA-Z\s]{2,20}$')),
    email VARCHAR(40) CHECK (REGEXP_LIKE(email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
    telefon VARCHAR(20) CHECK (REGEXP_LIKE(telefon, '^\+?\d+$')),
    CONSTRAINT PK_uzivatel PRIMARY KEY (uzivatel_id)
);

CREATE TABLE Recepcni(
    recepcni_id NUMBER GENERATED ALWAYS AS IDENTITY,
    uzivatel_id INTEGER,
    uvazek VARCHAR(20) CHECK ( uvazek IN ('plny', 'castecny') ),
    rodne_cislo VARCHAR(20) CHECK (REGEXP_LIKE(rodne_cislo, '^\d{6}\/\d{3,4}$')),
    ulice VARCHAR(20),
    PSC VARCHAR(5) CHECK (REGEXP_LIKE(PSC, '^\d{5}$')),
    cislo_popisne VARCHAR(10),
    mesto VARCHAR(20),
    cislo_uctu VARCHAR(20),
    CONSTRAINT PK_recepcni PRIMARY KEY (recepcni_id)
);

CREATE TABLE Zakaznik(
    zakaznik_id NUMBER GENERATED ALWAYS AS IDENTITY,
    uzivatel_id INTEGER,
    narodnost VARCHAR(20),
    CONSTRAINT PK_zakaznik PRIMARY KEY (zakaznik_id)
);

-- Pridani vztahu mezi tabulkami
ALTER TABLE Pobyt ADD CONSTRAINT FK_zakaznik_v_pobytu FOREIGN KEY (zakaznik_id) REFERENCES Zakaznik ON DELETE CASCADE;
ALTER TABLE Pobyt ADD CONSTRAINT FK_recepcni_v_pobytu FOREIGN KEY (recepcni_id) REFERENCES Recepcni;
ALTER TABLE Platba ADD CONSTRAINT FK_platba_v_pobyt FOREIGN KEY (pobyt_id) REFERENCES Pobyt ON DELETE CASCADE;
ALTER TABLE Platba ADD CONSTRAINT FK_recepcni_v_platbe FOREIGN KEY (recepcni_id) REFERENCES Recepcni;
ALTER TABLE PozadavekNaSluzbu ADD CONSTRAINT FK_sluzba_pobytu FOREIGN KEY (pobyt_id) REFERENCES Pobyt;
ALTER TABLE PozadavekNaSluzbu ADD CONSTRAINT FK_sluzba FOREIGN KEY (sluzba_id) REFERENCES Sluzba;
ALTER TABLE PokojVPobytu ADD CONSTRAINT FK_pokoj_pobyt FOREIGN KEY (pobyt_id) REFERENCES Pobyt;
ALTER TABLE PokojVPobytu ADD CONSTRAINT FK_pokoj FOREIGN KEY (pokoj_id) REFERENCES Pokoj;
ALTER TABLE Recepcni ADD CONSTRAINT FK_recepcni_uzivatel FOREIGN KEY (uzivatel_id) REFERENCES Uzivatel ON DELETE CASCADE;
ALTER TABLE Zakaznik ADD CONSTRAINT FK_zakaznik_uzivatel FOREIGN KEY (uzivatel_id) REFERENCES Uzivatel ON DELETE CASCADE;


-- Nacteni dat do databaze
INSERT INTO Pokoj(pocet_luzek, cena) VALUES (2, 1000);
INSERT INTO Pokoj(pocet_luzek, cena) VALUES (3, 1500);
INSERT INTO Pokoj(pocet_luzek, cena) VALUES (4, 2000);

INSERT INTO Sluzba(nazev, cena) VALUES ('snidane_za_den', 100);
INSERT INTO Sluzba(nazev, cena) VALUES ('vecere_za_den', 200);
INSERT INTO Sluzba(nazev, cena) VALUES ('fitness', 300);
INSERT INTO Sluzba(nazev, cena) VALUES ('masaz', 500);

INSERT INTO Uzivatel(jmeno, prijmeni, email, telefon) VALUES ('Jan', 'Novak', 'jannovak@seznam.cz', '777777777');
INSERT INTO Uzivatel(jmeno, prijmeni, email, telefon) VALUES ('Petr', 'Novak', 'petrnovak@seznam.cz', '666666666');
INSERT INTO Uzivatel(jmeno, prijmeni, email, telefon) VALUES ('John', 'Doe', 'johndoe@gmail.com', '555555555');

INSERT INTO Zakaznik(uzivatel_id, narodnost) VALUES (1, 'ceska');
INSERT INTO Zakaznik(uzivatel_id, narodnost) VALUES (2, 'ceska');
INSERT INTO Zakaznik(uzivatel_id, narodnost) VALUES (3, 'anglicka');

INSERT INTO Uzivatel(jmeno, prijmeni, email, telefon) VALUES ('Karolina', 'Rychla', 'karolina@seznam.cz', '444444444');
INSERT INTO Uzivatel(jmeno, prijmeni, email, telefon) VALUES ('Iveta', 'Kolcakova', 'iveta@seznam.cz', '333333333');

INSERT INTO Recepcni(uzivatel_id, uvazek, rodne_cislo, ulice, psc, cislo_popisne, mesto, cislo_uctu)
    VALUES (4, 'plny', '123456/7890', 'Ulice', '12345', '1', 'Mesto', '1234567890');
INSERT INTO Recepcni(uzivatel_id, uvazek, rodne_cislo, ulice, psc, cislo_popisne, mesto, cislo_uctu)
    VALUES (5, 'castecny', '123456/7890', 'Ulice', '12345', '1', 'Mesto', '1234567890');

INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2022-05-23', 'YYYY-MM-DD'), TO_DATE('2022-05-30', 'YYYY-MM-DD'), 1, 1);
INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2023-02-04', 'YYYY-MM-DD'), TO_DATE('2023-02-07', 'YYYY-MM-DD'), 2, 1);
INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2023-02-05', 'YYYY-MM-DD'), TO_DATE('2018-02-10', 'YYYY-MM-DD'), 3, 2);

INSERT INTO PokojVPobytu VALUES (1, 1);
INSERT INTO PokojVPobytu VALUES (1, 2);
INSERT INTO PokojVPobytu VALUES (2, 3);
INSERT INTO PokojVPobytu VALUES (3, 1);

INSERT INTO PozadavekNaSluzbu VALUES (2, 1);
INSERT INTO PozadavekNaSluzbu VALUES (1, 3);
INSERT INTO PozadavekNaSluzbu VALUES (1, 2);
INSERT INTO PozadavekNaSluzbu VALUES (3, 1);

INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (1000, 'hotovost', 1, 1, 1);
INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (250, 'karta', 1, 1, 2);
INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (1500, NULL, 0, 2, 2);
INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (750, 'karta', 1, 2, 1);
INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (100, 'hotovost', 1, 3, 1);

-- Vypis vsech tabulek
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

-- Pobyty a celkovy pocet luzek
SELECT pob.POBYT_ID, SUM(p.POCET_LUZEK) AS pocet_luzek FROM pobyt pob
JOIN POKOJVPOBYTU Pvp on pob.POBYT_ID = Pvp.POBYT_ID
JOIN POKOJ P on Pvp.POKOJ_ID = P.POKOJ_ID
GROUP BY pob.POBYT_ID;

-- Smazani tabulek databaze
DROP TABLE Pokoj CASCADE CONSTRAINTS;
DROP TABLE Pobyt CASCADE CONSTRAINTS;
DROP TABLE Platba CASCADE CONSTRAINTS;
DROP TABLE Sluzba CASCADE CONSTRAINTS;
DROP TABLE PozadavekNaSluzbu CASCADE CONSTRAINTS;
DROP TABLE PokojVPobytu CASCADE CONSTRAINTS;
DROP TABLE Uzivatel CASCADE CONSTRAINTS;
DROP TABLE Recepcni CASCADE CONSTRAINTS;
DROP TABLE Zakaznik CASCADE CONSTRAINTS;