CREATE TABLE Pokoj (
    pokoj_id INTEGER PRIMARY KEY ,
    pocet_luzek INTEGER,
    cena DECIMAL(10,2)
);

CREATE TABLE Pobyt (
    pobyt_id INTEGER PRIMARY KEY,
    od DATE,
    do DATE,
    zakaznik_id INTEGER,
    recepcni_id INTEGER
);

CREATE TABLE Platba(
    platba_id INTEGER PRIMARY KEY,
    castka DECIMAL(10,2),
    typ_platby VARCHAR(20) CHECK ( typ_platby IN ('hotovost', 'karta') ),
    zaplaceno NUMBER(1),
    pobyt_id INTEGER,
    recepcni_id INTEGER
);

CREATE TABLE Sluzba(
  sluzba_id INTEGER PRIMARY KEY,
  nazev VARCHAR(20),
  cena DECIMAL(10,2)
);

CREATE TABLE PozadavekNaSluzbu(
    pobyt_id INTEGER,
    sluzba_id INTEGER
);

CREATE TABLE PokojVPobytu(
  pobyt_id INTEGER,
  pokoj_id INTEGER
);

CREATE TABLE Uzivatel(
    uzivatel_id INTEGER PRIMARY KEY,
    jmeno VARCHAR(20),
    prijmeni VARCHAR(20),
    email VARCHAR(20),
    telefon VARCHAR(20)
);

CREATE TABLE Recepcni(
    recepcni_id INTEGER PRIMARY KEY,
    uzivatel_id INTEGER,
    uvazek VARCHAR(20) CHECK ( uvazek IN ('plny', 'castecny') ),
    rodne_cislo VARCHAR(20),
    ulice VARCHAR(20),
    PSC VARCHAR(5),
    cislo_popisne VARCHAR(10),
    mesto VARCHAR(20),
    cislo_uctu VARCHAR(20)
);

CREATE TABLE Zakaznik(
    zakaznik_id INTEGER PRIMARY KEY,
    uzivatel_id INTEGER,
    narodnost VARCHAR(20)
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