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

-- Priklad volani procedury mark_payment_as_paid
BEGIN
    mark_payment_as_paid(1, 'karta',1);
END;