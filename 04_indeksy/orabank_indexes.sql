-- Plik: orabank_indexes.sql
-- Cel: Tworzenie indeksów dla OraBank

-- =====================
-- BANK_CORE
-- =====================

-- Indeks dla szybkiego wyszukiwania rachunków po numerze
CREATE UNIQUE INDEX IDX_ACCOUNT_NUMBER ON ACCOUNT(ACCOUNT_NUMBER);

-- Indeks dla wyszukiwania klientów po PESEL
CREATE UNIQUE INDEX IDX_CLIENT_PESEL ON CLIENT(PESEL);

-- =====================
-- BANK_TX
-- =====================

-- Indeks dla szybkiego wyszukiwania transakcji po rachunku
CREATE INDEX IDX_TRANSACTION_ACCOUNT_DATE
ON TRANSACTION(ACCOUNT_ID, TRANSACTION_DATE);

-- Indeks dla raportów przelewów
CREATE INDEX IDX_TRANSFER_TARGET_ACCOUNT
ON TRANSFER(TARGET_ACCOUNT);

-- Indeks dla historii salda
CREATE INDEX IDX_BALANCE_HISTORY_ACCOUNT_DATE
ON BALANCE_HISTORY(ACCOUNT_ID, CHANGE_DATE);

-- =====================
-- BANK_ADMIN
-- =====================

-- Indeks dla logów audytu po tabeli i dacie zmiany
CREATE INDEX IDX_AUDIT_TABLE_DATE
ON AUDIT_LOG(TABLE_NAME, CHANGE_DATE);

-- Indeks dla logów błędów po kodzie
CREATE INDEX IDX_ERROR_CODE
ON ERROR_LOG(ERROR_CODE);
