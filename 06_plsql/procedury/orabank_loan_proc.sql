-- Plik: orabank_loan_proc.sql
-- Cel: Procedury obsługi kredytów w OraBank

-- Procedura przyznania kredytu
CREATE OR REPLACE PROCEDURE GRANT_LOAN(
    p_account_id NUMBER,
    p_amount NUMBER,
    p_interest_rate NUMBER,
    p_start_date DATE,
    p_end_date DATE
) IS
    v_loan_id NUMBER;
BEGIN
    -- Utworzenie nowego kredytu
    INSERT INTO LOAN (ACCOUNT_ID, AMOUNT, INTEREST_RATE, START_DATE, END_DATE, STATUS)
    VALUES (p_account_id, p_amount, p_interest_rate, p_start_date, p_end_date, 'AKTYWNY')
    RETURNING LOAN_ID INTO v_loan_id;

    -- Dodanie pierwszej raty (dla uproszczenia)
    INSERT INTO LOAN_INSTALLMENT (LOAN_ID, INSTALLMENT_DATE, AMOUNT, PAID_FLAG)
    VALUES (v_loan_id, p_start_date + 30, p_amount / 12, 'N');

END GRANT_LOAN;
/

-- Procedura spłaty raty kredytu
CREATE OR REPLACE PROCEDURE PAY_INSTALLMENT(
    p_installment_id NUMBER,
    p_amount NUMBER
) IS
    v_loan_id NUMBER;
    v_account_id NUMBER;
BEGIN
    -- Pobranie powiązanego kredytu i konta
    SELECT LOAN_ID, ACCOUNT_ID INTO v_loan_id, v_account_id
    FROM LOAN_INSTALLMENT
    JOIN LOAN USING (LOAN_ID)
    WHERE INSTALLMENT_ID = p_installment_id;

    -- Aktualizacja raty
    UPDATE LOAN_INSTALLMENT
    SET PAID_FLAG = 'Y', AMOUNT = p_amount
    WHERE INSTALLMENT_ID = p_installment_id;

    -- Aktualizacja salda konta
    UPDATE_ACCOUNT_BALANCE := p_amount * -1;
    EXECUTE IMMEDIATE 'BEGIN ORABANK_ACCOUNT_PKG.UPDATE_BALANCE(:1, :2); END;' USING v_account_id, -p_amount;

END PAY_INSTALLMENT;
/
