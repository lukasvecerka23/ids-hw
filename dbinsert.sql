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