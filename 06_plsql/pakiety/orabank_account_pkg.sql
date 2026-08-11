-- Pakiet operacji na rachunkach.
-- Pakiet nie wykonuje COMMIT. Granicą transakcji zarządza wywołujący.

CREATE OR REPLACE PACKAGE ORABANK_ACCOUNT_PKG IS
    FUNCTION GET_ACCOUNT_BALANCE(p_account_id NUMBER) RETURN NUMBER;

    PROCEDURE UPDATE_BALANCE(
        p_account_id NUMBER,
        p_amount     NUMBER
    );

    PROCEDURE MAKE_TRANSFER(
        p_from_account_id NUMBER,
        p_to_account_id   NUMBER,
        p_amount          NUMBER,
        p_description     VARCHAR2
    );
END ORABANK_ACCOUNT_PKG;
/

CREATE OR REPLACE PACKAGE BODY ORABANK_ACCOUNT_PKG IS
    FUNCTION GET_ACCOUNT_BALANCE(p_account_id NUMBER) RETURN NUMBER IS
        v_balance ACCOUNT.BALANCE%TYPE;
    BEGIN
        SELECT BALANCE
          INTO v_balance
          FROM ACCOUNT
         WHERE ACCOUNT_ID = p_account_id;

        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Rachunek nie istnieje');
    END GET_ACCOUNT_BALANCE;

    PROCEDURE UPDATE_BALANCE(
        p_account_id NUMBER,
        p_amount     NUMBER
    ) IS
        v_balance ACCOUNT.BALANCE%TYPE;
    BEGIN
        IF p_amount = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Kwota zmiany nie może wynosić zero');
        END IF;

        UPDATE ACCOUNT
           SET BALANCE = BALANCE + p_amount
         WHERE ACCOUNT_ID = p_account_id
           AND BALANCE + p_amount >= 0
        RETURNING BALANCE INTO v_balance;

        IF SQL%ROWCOUNT = 0 THEN
            SELECT COUNT(*)
              INTO v_balance
              FROM ACCOUNT
             WHERE ACCOUNT_ID = p_account_id;

            IF v_balance = 0 THEN
                RAISE_APPLICATION_ERROR(-20010, 'Rachunek nie istnieje');
            END IF;

            RAISE_APPLICATION_ERROR(-20001, 'Operacja spowodowałaby ujemne saldo');
        END IF;

        INSERT INTO BALANCE_HISTORY (ACCOUNT_ID, BALANCE, CHANGE_DATE)
        VALUES (p_account_id, v_balance, SYSDATE);
    END UPDATE_BALANCE;

    PROCEDURE MAKE_TRANSFER(
        p_from_account_id NUMBER,
        p_to_account_id   NUMBER,
        p_amount          NUMBER,
        p_description     VARCHAR2
    ) IS
        v_from_balance            ACCOUNT.BALANCE%TYPE;
        v_to_balance              ACCOUNT.BALANCE%TYPE;
        v_outgoing_transaction_id BANK_TRANSACTION.TRANSACTION_ID%TYPE;
    BEGIN
        SAVEPOINT BEFORE_TRANSFER;

        IF p_amount <= 0 THEN
            RAISE_APPLICATION_ERROR(-20012, 'Kwota przelewu musi być dodatnia');
        END IF;

        IF p_from_account_id = p_to_account_id THEN
            RAISE_APPLICATION_ERROR(-20013, 'Rachunek źródłowy i docelowy muszą być różne');
        END IF;

        -- Blokowanie w stałej kolejności ogranicza ryzyko zakleszczeń.
        IF p_from_account_id < p_to_account_id THEN
            SELECT BALANCE INTO v_from_balance
              FROM ACCOUNT
             WHERE ACCOUNT_ID = p_from_account_id AND STATUS = 'AKTYWNY'
               FOR UPDATE;

            SELECT BALANCE INTO v_to_balance
              FROM ACCOUNT
             WHERE ACCOUNT_ID = p_to_account_id AND STATUS = 'AKTYWNY'
               FOR UPDATE;
        ELSE
            SELECT BALANCE INTO v_to_balance
              FROM ACCOUNT
             WHERE ACCOUNT_ID = p_to_account_id AND STATUS = 'AKTYWNY'
               FOR UPDATE;

            SELECT BALANCE INTO v_from_balance
              FROM ACCOUNT
             WHERE ACCOUNT_ID = p_from_account_id AND STATUS = 'AKTYWNY'
               FOR UPDATE;
        END IF;

        IF v_from_balance < p_amount THEN
            RAISE_APPLICATION_ERROR(-20001, 'Brak wystarczających środków');
        END IF;

        UPDATE_BALANCE(p_from_account_id, -p_amount);
        UPDATE_BALANCE(p_to_account_id, p_amount);

        INSERT INTO BANK_TRANSACTION (
            ACCOUNT_ID,
            TRANSACTION_DATE,
            AMOUNT,
            TRANSACTION_TYPE,
            DESCRIPTION,
            BALANCE_AFTER
        ) VALUES (
            p_from_account_id,
            SYSDATE,
            -p_amount,
            'TRANSFER_OUT',
            p_description,
            v_from_balance - p_amount
        ) RETURNING TRANSACTION_ID INTO v_outgoing_transaction_id;

        INSERT INTO BANK_TRANSACTION (
            ACCOUNT_ID,
            TRANSACTION_DATE,
            AMOUNT,
            TRANSACTION_TYPE,
            DESCRIPTION,
            BALANCE_AFTER
        ) VALUES (
            p_to_account_id,
            SYSDATE,
            p_amount,
            'TRANSFER_IN',
            p_description,
            v_to_balance + p_amount
        );

        INSERT INTO TRANSFER (TRANSACTION_ID, TARGET_ACCOUNT, TITLE)
        SELECT v_outgoing_transaction_id, ACCOUNT_NUMBER, p_description
          FROM ACCOUNT
         WHERE ACCOUNT_ID = p_to_account_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK TO BEFORE_TRANSFER;
            RAISE_APPLICATION_ERROR(-20010, 'Aktywny rachunek źródłowy lub docelowy nie istnieje');
        WHEN OTHERS THEN
            ROLLBACK TO BEFORE_TRANSFER;
            RAISE;
    END MAKE_TRANSFER;
END ORABANK_ACCOUNT_PKG;
/

SHOW ERRORS PACKAGE ORABANK_ACCOUNT_PKG;
SHOW ERRORS PACKAGE BODY ORABANK_ACCOUNT_PKG;
