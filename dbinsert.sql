INSERT INTO Pokoj VALUES (1, 2, 1000);
INSERT INTO Pokoj VALUES (2, 3, 1500);
INSERT INTO Pokoj VALUES (3, 4, 2000);

INSERT INTO Sluzba VALUES (1, 'snidane_za_den', 100);
INSERT INTO Sluzba VALUES (2, 'vecere_za_den', 200);
INSERT INTO Sluzba VALUES (3, 'fitness', 300);
INSERT INTO Sluzba VALUES (4, 'masaz', 500);

INSERT INTO Uzivatel VALUES (1, 'Jan', 'Novak', 'jannovak@seznam.cz', '777777777');
INSERT INTO Uzivatel VALUES (2, 'Petr', 'Novak', 'petrnovak@seznam.cz', '666666666');
INSERT INTO Uzivatel VALUES (3, 'John', 'Doe', 'johndoe@gmail.com', '555555555');

INSERT INTO Zakaznik VALUES (1, 1, 'ceska');
INSERT INTO Zakaznik VALUES (2, 2, 'ceska');
INSERT INTO Zakaznik VALUES (3, 3, 'anglicka');

INSERT INTO Uzivatel VALUES (4, 'Karolina', 'Rychla', 'karolina@seznam.cz', '444444444');
INSERT INTO Uzivatel VALUES (5, 'Iveta', 'Kolcakova', 'iveta@seznam.cz', '333333333');

INSERT INTO Recepcni VALUES (1, 4, 'plny', '123456/7890', 'Ulice', '12345', '1', 'Mesto', '1234567890');
INSERT INTO Recepcni VALUES (2, 5, 'castecny', '123456/7890', 'Ulice', '12345', '1', 'Mesto', '1234567890');

INSERT INTO Pobyt VALUES (1, TO_DATE('2022-05-23', 'YYYY-MM-DD'), TO_DATE('2022-05-30', 'YYYY-MM-DD'), 1, 1);
INSERT INTO Pobyt VALUES (2, TO_DATE('2023-02-04', 'YYYY-MM-DD'), TO_DATE('2023-02-07', 'YYYY-MM-DD'), 2, 1);
INSERT INTO Pobyt VALUES (3, TO_DATE('2023-02-05', 'YYYY-MM-DD'), TO_DATE('2018-02-10', 'YYYY-MM-DD'), 3, 2);

INSERT INTO PokojVPobytu VALUES (1, 1);
INSERT INTO PokojVPobytu VALUES (1, 2);
INSERT INTO PokojVPobytu VALUES (2, 3);
INSERT INTO PokojVPobytu VALUES (3, 1);

INSERT INTO PozadavekNaSluzbu VALUES (2, 1);
INSERT INTO PozadavekNaSluzbu VALUES (1, 3);
INSERT INTO PozadavekNaSluzbu VALUES (1, 2);
INSERT INTO PozadavekNaSluzbu VALUES (3, 1);

INSERT INTO Platba VALUES (1, 1000, 'hotovost', 1, 1, 1);
INSERT INTO Platba VALUES (2, 250, 'karta', 1, 1, 2);
INSERT INTO Platba VALUES (3, 1500, NULL, 0, 2, 2);
INSERT INTO Platba VALUES (4, 750, 'karta', 1, 2, 1);
INSERT INTO Platba VALUES (5, 100, 'hotovost', 1, 3, 1);