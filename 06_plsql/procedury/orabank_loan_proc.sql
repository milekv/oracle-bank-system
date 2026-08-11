-- Procedury obsługi kredytów.

CREATE OR REPLACE PROCEDURE GRANT_LOAN(
    p_account_id   NUMBER,
    p_amount       NUMBER,
    p_interest_rate NUMBER,
    p_start_date   DATE,
    p_end_date     DATE
) IS
    v_loan_id LOAN.LOAN_ID%TYPE;
BEGIN
    IF p_amount <= 0 OR p_interest_rate < 0 OR p_end_date <= p_start_date THEN
        RAISE_APPLICATION_ERROR(-20020, 'Nieprawidłowe parametry kredytu');
    END IF;

    INSERT INTO LOAN (ACCOUNT_ID, AMOUNT, INTEREST_RATE, START_DATE, END_DATE, STATUS)
    VALUES (p_account_id, p_amount, p_interest_rate, p_start_date, p_end_date, 'AKTYWNY')
    RETURNING LOAN_ID INTO v_loan_id;

    INSERT INTO LOAN_INSTALLMENT (LOAN_ID, INSTALLMENT_DATE, AMOUNT, PAID_FLAG)
    VALUES (v_loan_id, ADD_MONTHS(p_start_date, 1), ROUND(p_amount / 12, 2), 'N');
END GRANT_LOAN;
/

CREATE OR REPLACE PROCEDURE PAY_INSTALLMENT(
    p_installment_id NUMBER,
    p_amount         NUMBER
) IS
    v_account_id LOAN.ACCOUNT_ID%TYPE;
    v_due_amount  LOAN_INSTALLMENT.AMOUNT%TYPE;
    v_paid_flag   LOAN_INSTALLMENT.PAID_FLAG%TYPE;
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Kwota spłaty musi być dodatnia');
    END IF;

    SELECT l.ACCOUNT_ID, li.AMOUNT, li.PAID_FLAG
      INTO v_account_id, v_due_amount, v_paid_flag
      FROM LOAN_INSTALLMENT li
      JOIN LOAN l ON l.LOAN_ID = li.LOAN_ID
     WHERE li.INSTALLMENT_ID = p_installment_id
       FOR UPDATE OF li.PAID_FLAG;

    IF v_paid_flag = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20022, 'Rata została już spłacona');
    END IF;

    IF p_amount <> v_due_amount THEN
        RAISE_APPLICATION_ERROR(-20023, 'Kwota spłaty musi odpowiadać kwocie raty');
    END IF;

    ORABANK_ACCOUNT_PKG.UPDATE_BALANCE(v_account_id, -p_amount);

    UPDATE LOAN_INSTALLMENT
       SET PAID_FLAG = 'Y'
     WHERE INSTALLMENT_ID = p_installment_id;
END PAY_INSTALLMENT;
/

SHOW ERRORS PROCEDURE GRANT_LOAN;
SHOW ERRORS PROCEDURE PAY_INSTALLMENT;
