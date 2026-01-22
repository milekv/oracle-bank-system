-- Plik: orabank_account_func.sql
-- Cel: Funkcje kont i kredytów w OraBank

-- Funkcja pobrania historii transakcji dla konta
CREATE OR REPLACE FUNCTION GET_ACCOUNT_TRANSACTIONS(
    p_account_id NUMBER
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT TRANSACTION_ID, TRANSACTION_DATE, AMOUNT, TRANSACTION_TYPE, DESCRIPTION, BALANCE_AFTER
        FROM TRANSACTION
        WHERE ACCOUNT_ID = p_account_id
        ORDER BY TRANSACTION_DATE DESC;

    RETURN v_cursor;
END GET_ACCOUNT_TRANSACTIONS;
/

-- Funkcja wyliczenia odsetek kredytu
CREATE OR REPLACE FUNCTION CALCULATE_LOAN_INTEREST(
    p_loan_id NUMBER
) RETURN NUMBER IS
    v_interest NUMBER(15,2);
    v_amount NUMBER(15,2);
    v_rate NUMBER(5,2);
BEGIN
    SELECT AMOUNT, INTEREST_RATE INTO v_amount, v_rate
    FROM LOAN
    WHERE LOAN_ID = p_loan_id;

    v_interest := v_amount * v_rate / 100;
    RETURN v_interest;
END CALCULATE_LOAN_INTEREST;
/
