CREATE ROLE admin;
GRANT admin to xnevar00;
GRANT SELECT, INSERT, UPDATE, DELETE ON Pokoj, Pobyt, Platba, Sluzba, PozadavekNaSluzbu, PokojVPobytu, Uzivatel, Recepcni, Zakaznik TO admin;
ALTER USER xnevar00 DEFAULT ROLE admin;