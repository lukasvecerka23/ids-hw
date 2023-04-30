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




