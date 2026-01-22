-- Plik: orabank_security.sql
-- Cel: Role, uprawnienia i widoki bezpieczeństwa w OraBank

-- =====================
-- Tworzenie ról
-- =====================
CREATE ROLE BANK_ADMIN;
CREATE ROLE BANK_TELLER;
CREATE ROLE BANK_AUDITOR;

-- =====================
-- Uprawnienia dla BANK_ADMIN
-- =====================
GRANT ALL PRIVILEGES TO BANK_ADMIN;

-- =====================
-- Uprawnienia dla BANK_TELLER
-- =====================
-- Odczyt i zapis kont, przelewów, kart
GRANT SELECT, INSERT, UPDATE ON ACCOUNT TO BANK_TELLER;
GRANT SELECT, INSERT, UPDATE ON TRANSACTION TO BANK_TELLER;
GRANT SELECT, INSERT, UPDATE ON TRANSFER TO BANK_TELLER;
GRANT SELECT ON CLIENT TO BANK_TELLER;
GRANT SELECT ON CARD TO BANK_TELLER;

-- =====================
-- Uprawnienia dla BANK_AUDITOR
-- =====================
-- Tylko odczyt transakcji, sald, logów
GRANT SELECT ON ACCOUNT TO BANK_AUDITOR;
GRANT SELECT ON TRANSACTION TO BANK_AUDITOR;
GRANT SELECT ON TRANSFER TO BANK_AUDITOR;
GRANT SELECT ON BALANCE_HISTORY TO BANK_AUDITOR;
GRANT SELECT ON AUDIT_LOG TO BANK_AUDITOR;

-- =====================
-- Tworzenie widoków raportowych
-- =====================

-- Widok dziennych transakcji
CREATE OR REPLACE VIEW VW_DAILY_TRANSACTIONS AS
SELECT ACCOUNT_ID, TRANSACTION_DATE, AMOUNT, TRANSACTION_TYPE, DESCRIPTION
FROM TRANSACTION
WHERE TRUNC(TRANSACTION_DATE) = TRUNC(SYSDATE);

-- Widok sald klientów
CREATE OR REPLACE VIEW VW_CLIENT_BALANCE AS
SELECT a.ACCOUNT_ID, a.CLIENT_ID, a.BALANCE
FROM ACCOUNT a;

-- Widok top klientów (przykładowo wg sumy transakcji)
CREATE OR REPLACE VIEW VW_TOP_CLIENTS AS
SELECT CLIENT_ID, SUM(AMOUNT) AS TOTAL_AMOUNT
FROM TRANSACTION
GROUP BY CLIENT_ID
ORDER BY TOTAL_AMOUNT DESC;

-- =====================
-- Przykład tworzenia użytkowników i przypisania ról
-- =====================
CREATE USER admin_user IDENTIFIED BY admin123;
CREATE USER teller_user IDENTIFIED BY teller123;
CREATE USER auditor_user IDENTIFIED BY auditor123;

-- Przypisanie ról
GRANT BANK_ADMIN TO admin_user;
GRANT BANK_TELLER TO teller_user;
GRANT BANK_AUDITOR TO auditor_user;

-- =====================
-- Zabezpieczenie widoków: dostęp tylko dla audytorów
-- =====================
GRANT SELECT ON VW_DAILY_TRANSACTIONS TO BANK_AUDITOR;
GRANT SELECT ON VW_CLIENT_BALANCE TO BANK_AUDITOR;
GRANT SELECT ON VW_TOP_CLIENTS TO BANK_AUDITOR;
