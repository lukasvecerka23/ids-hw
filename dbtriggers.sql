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

--trigger, ktery vytvori ke kazdemu pobytu automaticky platbu (platba pouze za pokoje)
CREATE OR REPLACE TRIGGER vytvoreni_platby_trigger
AFTER INSERT ON Pobyt
FOR EACH ROW
BEGIN
    INSERT INTO Platba(castka, typ_platby, zaplaceno, pobyt_id, recepcni_id) VALUES (0, NULL, 0, :new.pobyt_id, NULL);
END;



