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
    castka DECIMAL(10,2) CHECK (castka >= 0),
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

