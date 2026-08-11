-- Plik: orabank_indexes.sql
-- Cel: Tworzenie indeksów dla OraBank

-- =====================
-- BANK_CORE
-- =====================

-- Ograniczenia UNIQUE na ACCOUNT_NUMBER i PESEL tworzą własne indeksy.
-- Poniższe indeksy wspierają klucze obce i najczęstsze ścieżki dostępu.
CREATE INDEX IDX_ACCOUNT_CLIENT ON ACCOUNT(CLIENT_ID);
CREATE INDEX IDX_ACCOUNT_TYPE ON ACCOUNT(ACCOUNT_TYPE_ID);
CREATE INDEX IDX_CARD_ACCOUNT ON CARD(ACCOUNT_ID);
CREATE INDEX IDX_LOAN_ACCOUNT ON LOAN(ACCOUNT_ID);
CREATE INDEX IDX_INSTALLMENT_LOAN_DATE ON LOAN_INSTALLMENT(LOAN_ID, INSTALLMENT_DATE);

-- =====================
-- BANK_TX
-- =====================

-- Indeks dla szybkiego wyszukiwania transakcji po rachunku
CREATE INDEX IDX_BANK_TX_ACCOUNT_DATE
ON BANK_TRANSACTION(ACCOUNT_ID, TRANSACTION_DATE);

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
