-- Kończy sesję błędem, jeśli po instalacji istnieją obiekty INVALID.

SET SERVEROUTPUT ON

DECLARE
    v_invalid_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_invalid_count
      FROM USER_OBJECTS
     WHERE STATUS = 'INVALID'
       AND OBJECT_TYPE IN ('FUNCTION', 'PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'TRIGGER', 'VIEW');

    IF v_invalid_count > 0 THEN
        FOR rec IN (
            SELECT OBJECT_TYPE, OBJECT_NAME
              FROM USER_OBJECTS
             WHERE STATUS = 'INVALID'
             ORDER BY OBJECT_TYPE, OBJECT_NAME
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('INVALID: ' || rec.OBJECT_TYPE || ' ' || rec.OBJECT_NAME);
        END LOOP;

        RAISE_APPLICATION_ERROR(-20990, 'Instalacja pozostawiła niepoprawne obiekty');
    END IF;

    DBMS_OUTPUT.PUT_LINE('OK: wszystkie obiekty PL/SQL są poprawne');
END;
/
