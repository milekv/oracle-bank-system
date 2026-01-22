-- Plik: orabank_account_pkg.sql
-- Cel: Pakiet PL/SQL do obsługi kont i przelewów w OraBank

CREATE OR REPLACE PACKAGE ORABANK_ACCOUNT_PKG IS

    -- Funkcja: Pobranie salda konta
    FUNCTION GET_ACCOUNT_BALANCE(p_account_id NUMBER) RETURN NUMBER;

    -- Procedura: Aktualizacja salda konta
    PROCEDURE UPDATE_BALANCE(p_account_id NUMBER, p_amount NUMBER);

    -- Procedura: Wykonanie przelewu
    PROCEDURE MAKE_TRANSFER(
        p_from_account_id NUMBER,
        p_to_account_id   NUMBER,
        p_amount          NUMBER,
        p_description     VARCHAR2
    );

END ORABANK_ACCOUNT_PKG;
/
-- =====================================================

CREATE OR REPLACE PACKAGE BODY ORABANK_ACCOUNT_PKG IS

    -- Funkcja: Pobranie salda konta
    FUNCTION GET_ACCOUNT_BALANCE(p_account_id NUMBER) RETURN NUMBER IS
        v_balance NUMBER;
    BEGIN
        SELECT BALANCE INTO v_balance
        FROM ACCOUNT
        WHERE ACCOUNT_ID = p_account_id;
        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GET_ACCOUNT_BALANCE;

    -- Procedura: Aktualizacja salda konta
    PROCEDURE UPDATE_BALANCE(p_account_id NUMBER, p_amount NUMBER) IS
    BEGIN
        UPDATE ACCOUNT
        SET BALANCE = BALANCE + p_amount
        WHERE ACCOUNT_ID = p_account_id;

        -- Dodanie wpisu do historii salda
        INSERT INTO BALANCE_HISTORY (ACCOUNT_ID, BALANCE, CHANGE_DATE)
        VALUES (p_account_id, GET_ACCOUNT_BALANCE(p_account_id), SYSDATE);
    END UPDATE_BALANCE;

    -- Procedura: Wykonanie przelewu
    PROCEDURE MAKE_TRANSFER(
        p_from_account_id NUMBER,
        p_to_account_id   NUMBER,
        p_amount          NUMBER,
        p_description     VARCHAR2
    ) IS
    BEGIN
        -- Sprawdzenie środków
        IF GET_ACCOUNT_BALANCE(p_from_account_id) < p_amount THEN
            RAISE_APPLICATION_ERROR(-20001, 'Brak wystarczających środków na koncie');
        END IF;

        -- Zmniejszenie salda nadawcy
        UPDATE_BALANCE(p_from_account_id, -p_amount);

        -- Zwiększenie salda odbiorcy
        UPDATE_BALANCE(p_to_account_id, p_amount);

        -- Dodanie wpisu do TRANSACTION dla nadawcy
        INSERT INTO TRANSACTION (ACCOUNT_ID, TRANSACTION_DATE, AMOUNT, TRANSACTION_TYPE, DESCRIPTION, BALANCE_AFTER)
        VALUES (p_from_account_id, SYSDATE, -p_amount, 'TRANSFER', p_description, GET_ACCOUNT_BALANCE(p_from_account_id));

        -- Dodanie wpisu do TRANSACTION dla odbiorcy
        INSERT INTO TRANSACTION (ACCOUNT_ID, TRANSACTION_DATE, AMOUNT, TRANSACTION_TYPE, DESCRIPTION, BALANCE_AFTER)
        VALUES (p_to_account_id, SYSDATE, p_amount, 'TRANSFER', p_description, GET_ACCOUNT_BALANCE(p_to_account_id));

        -- Opcjonalnie dodanie do tabeli TRANSFER
        INSERT INTO TRANSFER (TRANSACTION_ID, TARGET_ACCOUNT, TITLE)
        VALUES (
            TRANSACTION_SEQ.CURRVAL, -- jeśli używasz sekwencji zamiast IDENTITY
            (SELECT ACCOUNT_NUMBER FROM ACCOUNT WHERE ACCOUNT_ID = p_to_account_id),
            p_description
        );

    END MAKE_TRANSFER;

END ORABANK_ACCOUNT_PKG;
/
