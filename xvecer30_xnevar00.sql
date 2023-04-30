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
    is_free NUMBER(1),
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

-- Pridani prav pro druheho uzivatele
GRANT SELECT, INSERT, UPDATE, DELETE ON Pokoj TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Pobyt TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Platba TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Sluzba TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON PozadavekNaSluzbu TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON PokojVPobytu TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Uzivatel TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Recepcni TO xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Zakaznik TO xnevar00;

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

-- trigger, ktery oznaci kazdy treti pobyt zakaznika za pobyt, ktery je zadarmo
CREATE OR REPLACE TRIGGER treti_pobyt_trigger
BEFORE INSERT ON Pobyt
FOR EACH ROW
DECLARE
pocet_pobytu INTEGER;
BEGIN
SELECT COUNT(*) INTO pocet_pobytu FROM Pobyt WHERE zakaznik_id = :new.zakaznik_id;
IF MOD(pocet_pobytu, 3) = 2 THEN
:new.is_free := 1;
ELSE
:new.is_free := 0;
END IF;
END;

-- trigger, ktery kontroluje, zda je pokoj volny pro novou rezervaci
-- pokud neni, tak vyhodi chybu, zaroven trigger vytvari novou platbu za pokoj
CREATE OR REPLACE TRIGGER check_room_availability
    BEFORE INSERT ON PokojVPobytu
    FOR EACH ROW
DECLARE
    v_overlapping_reservations NUMBER;
    v_is_free NUMBER;
    v_pokoj_cena NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_overlapping_reservations
    FROM PokojVPobytu
    JOIN Pobyt ON PokojVPobytu.pobyt_id = Pobyt.pobyt_id
    -- kontrola dostupnosti pokoje pro novou rezervaci
    WHERE PokojVPobytu.pokoj_id = :NEW.pokoj_id
        AND (
            (Pobyt.od BETWEEN (SELECT od FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id) AND (SELECT do FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id))
            OR (Pobyt.do BETWEEN (SELECT od FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id) AND (SELECT do FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id))
            OR ((SELECT od FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id) BETWEEN Pobyt.od AND Pobyt.do)
            OR ((SELECT do FROM Pobyt WHERE pobyt_id = :NEW.pobyt_id) BETWEEN Pobyt.od AND Pobyt.do)
        );

    IF v_overlapping_reservations > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Room with ID ' || :NEW.pokoj_id || ' is not available for the specified date range.');
    END IF;

    SELECT COUNT(*)
    INTO v_is_free
    FROM Pobyt
    WHERE POBYT.POBYT_ID = :NEW.POBYT_ID AND POBYT.IS_FREE = 1;

    SELECT cena INTO v_pokoj_cena FROM Pokoj WHERE pokoj_id = :NEW.pokoj_id;

    -- pokud na pobyt neni uplatnena zadna sleva, vytvori se platba za pobyt
    IF v_is_free = 0 THEN
        INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (v_pokoj_cena, NULL, 0, :new.pobyt_id, NULL);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END check_room_availability;


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
INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (1500, NULL, 0, 2, NULL);
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

-- DEKLARACE PROCEDUR

-- Procedura ktera vraci kurzor s rezervacemi zakaznika
-- Vyhodi podminku pokud zakaznik neexistuje
CREATE OR REPLACE PROCEDURE get_customer_reservations(
    p_customer_id IN Zakaznik.Zakaznik_id%TYPE,
    p_reservations OUT SYS_REFCURSOR)
IS
    v_customer_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_customer_exists
    FROM Zakaznik
    WHERE ZAKAZNIK_ID = p_customer_id;

    IF v_customer_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer with ID ' || p_customer_id || ' does not exist.');
    END IF;

    OPEN p_reservations FOR
        SELECT *
        FROM Pobyt p
        WHERE p.ZAKAZNIK_ID = p_customer_id;
END get_customer_reservations;

-- Priklad volani procedury get_customer_reservations
DECLARE
    l_reservations SYS_REFCURSOR;
    l_reservation_row Pobyt%ROWTYPE;
BEGIN
    get_customer_reservations(1, l_reservations);
    LOOP
        FETCH l_reservations INTO l_reservation_row;
        EXIT WHEN l_reservations%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reservation ID: ' || l_reservation_row.POBYT_ID || ', Start Date: ' || l_reservation_row.OD || ', End Date: ' || l_reservation_row.DO);
    END LOOP;
    CLOSE l_reservations;
END;

-- Vyhodi vyjimku, zakaznik neexistuje
DECLARE
    l_reservations SYS_REFCURSOR;
    l_reservation_row Pobyt%ROWTYPE;
BEGIN
    get_customer_reservations(99999, l_reservations);
    LOOP
        FETCH l_reservations INTO l_reservation_row;
        EXIT WHEN l_reservations%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Reservation ID: ' || l_reservation_row.POBYT_ID || ', Start Date: ' || l_reservation_row.OD || ', End Date: ' || l_reservation_row.DO);
    END LOOP;
    CLOSE l_reservations;
END;

-- Procedura ktera oznaci platbu jako zaplacenou a prida k ni typ platby a recepcni kteri ji prijal
-- Vyhodi podminku pokud uz je platba zaplacena, platba neexistuje a nebo recepcni neexistuje
CREATE OR REPLACE PROCEDURE mark_payment_as_paid(
    p_payment_id IN PLATBA.PLATBA_ID%TYPE,
    p_payment_type IN PLATBA.TYP_PLATBY%TYPE,
    p_receptionist_id IN RECEPCNI.RECEPCNI_ID%TYPE)
IS
    v_receptionist_exists NUMBER;
    v_payment_exists NUMBER;
    v_current_is_paid NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_receptionist_exists
    FROM RECEPCNI
    WHERE RECEPCNI_ID = p_receptionist_id;

    IF v_receptionist_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Receptionist with ID ' || p_receptionist_id || ' does not exist.');
    END IF;

    SELECT COUNT(*)
    INTO v_payment_exists
    FROM PLATBA
    WHERE PLATBA_ID = p_payment_id;

    IF v_payment_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Receptionist with ID ' || p_payment_id || ' does not exist.');
    END IF;

    SELECT zaplaceno
    INTO v_current_is_paid
    FROM PLATBA
    WHERE PLATBA_ID = p_payment_id;

    IF v_current_is_paid = 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Payment with ID ' || p_payment_id || ' has already been paid.');
    END IF;

    UPDATE PLATBA
    SET PLATBA.ZAPLACENO = 1, PLATBA.RECEPCNI_ID = p_receptionist_id, PLATBA.TYP_PLATBY = p_payment_type
    WHERE PLATBA_ID = p_payment_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Payment with ID ' || p_payment_id || ' has been updated successfully.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END mark_payment_as_paid;

SELECT * FROM Platba;
-- Priklad volani procedury mark_payment_as_paid
BEGIN
    mark_payment_as_paid(1, 'karta',1);
END;

SELECT * FROM Platba;

-- Vyhodi vyjimku protoze platba neexistuje
BEGIN
    mark_payment_as_paid(99999, 'karta',1);
END;

-- Vyhodi vyjimku protoze recepcni neexistuje
BEGIN
    mark_payment_as_paid(1, 'karta',9999999);
END;

-- Vyhodi vyjimku protoze platba uz je zaplacena
BEGIN
    mark_payment_as_paid(1, 'karta', 1);
END;

-- Vyhodi vyjimku protoze byla dana spatna hodnota typu platby
BEGIN
    mark_payment_as_paid(2, 'mincemi', 2);
END;

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

-- VYTVORENI MATERIALIZOVANEHO POHLEDU A POUZITI

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

-- UKAZKA FUNKCNOSTI TRIGGERU
SELECT * FROM Pobyt;

INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2023-04-20', 'YYYY-MM-DD'), TO_DATE('2023-04-23', 'YYYY-MM-DD'), 1, 1);
INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2023-04-25', 'YYYY-MM-DD'), TO_DATE('2023-04-28', 'YYYY-MM-DD'), 1, 1);

-- muzeme videt ze 3. pobyt ma is_free nastaveno na 1
SELECT * FROM Pobyt;

INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2018-06-12', 'YYYY-MM-DD'), TO_DATE('2018-06-19', 'YYYY-MM-DD'), 1, 1);
INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2018-12-18', 'YYYY-MM-DD'), TO_DATE('2018-12-24', 'YYYY-MM-DD'), 1, 1);
INSERT INTO Pobyt(od, do, zakaznik_id, recepcni_id) VALUES (TO_DATE('2021-12-10', 'YYYY-MM-DD'), TO_DATE('2021-12-17', 'YYYY-MM-DD'), 1, 1);
-- Po vlozeni dalsich pobytu se is_free nastavil na po 3. pobytu na 1
SELECT * FROM Pobyt;

SELECT * FROM Pobyt JOIN POKOJVPOBYTU ON Pobyt.pobyt_id = PokojVPobytu.pobyt_id JOIN Pokoj ON PokojVPobytu.pokoj_id = Pokoj.pokoj_id;
-- Vyhodi vyjimku protoze je pokoj obsazen
INSERT INTO PokojVPobytu VALUES (3, 3);

-- Neprida platbu protoze pobyt ma nastaveno is_free na 1
SELECT * FROM Platba WHERE pobyt_id = 8;
INSERT INTO PokojVPobytu VALUES (8, 1);
SELECT * FROM Platba WHERE pobyt_id = 8;

-- Prida platbu 1000 a 1500 Kc
INSERT INTO PokojVPobytu VALUES (7, 1);
INSERT INTO PokojVPobytu VALUES (7, 2);
SELECT * FROM Platba WHERE pobyt_id = 7;

-- UKAZKA EXPLAIN PLAN

-- EXPLAIN PLAN a vytvoreni indexu
-- Kolik penez bylo celkove utraceno v pokojich s konkretnim poctem luzek
-- Pred vytvorenim indexu
EXPLAIN PLAN FOR
SELECT p.POCET_LUZEK, COUNT(p.POKOJ_ID) AS pocet_pokoju, SUM(pl.CASTKA) AS celkova_castka
FROM POKOJ p
JOIN POKOJVPOBYTU rr ON p.POKOJ_ID = rr.POKOJ_ID
JOIN Pobyt res ON rr.POBYT_ID = res.POBYT_ID
JOIN PLATBA pl ON res.POBYT_ID = pl.POBYT_ID
GROUP BY p.POCET_LUZEK;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY());

-- Vytvoreni indexu na sloupec platba.pobyt_id
CREATE INDEX idx_platba_pobyt_id ON PLATBA(POBYT_ID);

-- Po vytvoreni indexu
EXPLAIN PLAN FOR
SELECT p.POCET_LUZEK, COUNT(p.POKOJ_ID) AS pocet_pokoju, SUM(pl.CASTKA) AS celkova_castka
FROM POKOJ p
JOIN POKOJVPOBYTU rr ON p.POKOJ_ID = rr.POKOJ_ID
JOIN Pobyt res ON rr.POBYT_ID = res.POBYT_ID
JOIN PLATBA pl ON res.POBYT_ID = pl.POBYT_ID
GROUP BY p.POCET_LUZEK;

-- muzeme videt ze se pouziva index misto table access full pri PLATBA a tim doslo k snizeni cost
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY());

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