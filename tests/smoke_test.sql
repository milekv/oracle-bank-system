-- Test uruchamiaj w pustym schemacie testowym po install.sql.
-- Wszystkie dane testowe są wycofywane.

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET SERVEROUTPUT ON

DECLARE
    v_client_from CLIENT.CLIENT_ID%TYPE;
    v_client_to   CLIENT.CLIENT_ID%TYPE;
    v_type_id     ACCOUNT_TYPE.ACCOUNT_TYPE_ID%TYPE;
    v_account_from ACCOUNT.ACCOUNT_ID%TYPE;
    v_account_to   ACCOUNT.ACCOUNT_ID%TYPE;
    v_balance_from ACCOUNT.BALANCE%TYPE;
    v_balance_to   ACCOUNT.BALANCE%TYPE;
    v_tx_count     NUMBER;
    v_history_count NUMBER;
BEGIN
    INSERT INTO ACCOUNT_TYPE (NAME, DESCRIPTION)
    VALUES ('TEST_CURRENT', 'Typ używany przez smoke test')
    RETURNING ACCOUNT_TYPE_ID INTO v_type_id;

    INSERT INTO CURRENCY (CURRENCY_CODE, NAME, SYMBOL)
    VALUES ('TST', 'Test currency', 'T');

    INSERT INTO CLIENT (FIRST_NAME, LAST_NAME, PESEL, DATE_OF_BIRTH)
    VALUES ('Test', 'Sender', '90010100001', DATE '1990-01-01')
    RETURNING CLIENT_ID INTO v_client_from;

    INSERT INTO CLIENT (FIRST_NAME, LAST_NAME, PESEL, DATE_OF_BIRTH)
    VALUES ('Test', 'Receiver', '90010100002', DATE '1990-01-01')
    RETURNING CLIENT_ID INTO v_client_to;

    INSERT INTO ACCOUNT (
        CLIENT_ID, ACCOUNT_TYPE_ID, CURRENCY_CODE, ACCOUNT_NUMBER, BALANCE
    ) VALUES (
        v_client_from, v_type_id, 'TST', 'TEST0000000000000001', 1000
    ) RETURNING ACCOUNT_ID INTO v_account_from;

    INSERT INTO ACCOUNT (
        CLIENT_ID, ACCOUNT_TYPE_ID, CURRENCY_CODE, ACCOUNT_NUMBER, BALANCE
    ) VALUES (
        v_client_to, v_type_id, 'TST', 'TEST0000000000000002', 100
    ) RETURNING ACCOUNT_ID INTO v_account_to;

    ORABANK_ACCOUNT_PKG.MAKE_TRANSFER(
        v_account_from,
        v_account_to,
        250,
        'Smoke test transfer'
    );

    SELECT BALANCE INTO v_balance_from FROM ACCOUNT WHERE ACCOUNT_ID = v_account_from;
    SELECT BALANCE INTO v_balance_to FROM ACCOUNT WHERE ACCOUNT_ID = v_account_to;

    SELECT COUNT(*)
      INTO v_tx_count
      FROM BANK_TRANSACTION
     WHERE ACCOUNT_ID IN (v_account_from, v_account_to);

    SELECT COUNT(*)
      INTO v_history_count
      FROM BALANCE_HISTORY
     WHERE ACCOUNT_ID IN (v_account_from, v_account_to);

    IF v_balance_from <> 750 OR v_balance_to <> 350 OR v_tx_count <> 2 OR v_history_count <> 2 THEN
        RAISE_APPLICATION_ERROR(-20991, 'Smoke test zwrócił nieprawidłowy stan');
    END IF;

    DBMS_OUTPUT.PUT_LINE('OK: przelew, salda, historia i wpisy transakcyjne');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
