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
    FROM PokojVPobytu
    JOIN Pobyt ON PokojVPobytu.pobyt_id = Pobyt.pobyt_id
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
