# 🏦 Instrukcja uruchomienia projektu OraBank

Ten plik pokazuje krok po kroku, jak uruchomić system bankowy **OraBank** w Oracle Database.  
Zawiera wszystkie elementy projektu: tabele, PL/SQL, joby, bezpieczeństwo, wydajność i backup.

---

## 1️⃣ Wymagania

- Oracle Database 19c lub 21c (lokalnie, VM lub Docker)  
- SQL*Plus, SQL Developer lub inny klient Oracle  
- Uprawnienia do tworzenia schematów i użytkowników  

---

## 2️⃣ Utworzenie schematu (użytkownika ORABANK)

1. Zaloguj się jako administrator (np. SYSDBA).  
2. Wykonaj:

sql: 

    CREATE USER ORABANK IDENTIFIED BY ora123;
    GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE JOB TO ORABANK;

W SQL*Plus lub SQL Developer zaloguj się jako ORABANK.

Uruchom wszystkie tabele:

    @03_tabele/orabank_tables.sql
    @04_indeksy/orabank_indexes.sql
    @05_partycjonowanie/orabank_partitioning.sql

## 4️⃣ Wgranie PL/SQL (pakiety, procedury, funkcje)
    @06_plsql/pakiety/orabank_account_pkg.sql
    @06_plsql/procedury/orabank_loan_proc.sql
    @06_plsql/funkcje/orabank_account_func.sql


Teraz możesz wywoływać procedury i funkcje, np. przelewy lub obliczanie odsetek.

## 5️⃣ Triggery i audyt
    @07_triggery/orabank_triggers.sql


Automatyczne logowanie zmian w tabelach do AUDIT_LOG.

## 6️⃣ Role i bezpieczeństwo
    @08_bezpieczenstwo/orabank_security.sql


Tworzy role: BANK_ADMIN, BANK_TELLER, BANK_AUDITOR

Przypisuje uprawnienia i widoki raportowe

Możesz teraz testować logowanie jako różni użytkownicy:

    CONNECT teller_user/teller123
    SELECT * FROM ACCOUNT;

## 7️⃣ Joby (zadania cykliczne)
    @09_joby/orabank_jobs.sql


Oracle Scheduler automatycznie uruchamia codziennie:

odsetki dla kredytów
historię salda
raport top klientów

Sprawdzenie statusu jobów:

    SELECT JOB_NAME, ENABLED, STATE FROM USER_SCHEDULER_JOBS;

## 8️⃣ Optymalizacja wydajności
    @10_wydajnosc/orabank_performance.sql


Indeksy złożone
Materialized views
Statystyki dla optymalizatora Oracle

## 9️⃣ Backup i przywracanie
    @11_backup/orabank_backup.sql


Backup: Data Pump (EXPDP) lub RMAN

Restore: Data Pump Import (IMPDP)

🔹 Testowanie systemu

Przykładowe operacje:

-- Dodanie klienta

    INSERT INTO CLIENT (CLIENT_ID, NAME, SURNAME, PESEL, EMAIL) VALUES (1, 'Jan', 'Kowalski', '12345678901', 'jan.kowalski@example.com');

-- Dodanie konta

    INSERT INTO ACCOUNT (ACCOUNT_ID, CLIENT_ID, ACCOUNT_NUMBER, BALANCE, CREATED_DATE, STATUS)
    VALUES (1, 1, '1234567890123456', 1000, SYSDATE, 'AKTYWNE');

-- Wykonanie przelewu

    BEGIN
    ORABANK_ACCOUNT_PKG.MAKE_TRANSFER(1, 2, 200, 'Test przelewu');
    END;
    /

-- Pobranie historii transakcji

    DECLARE
    v_cursor SYS_REFCURSOR;
    BEGIN
    v_cursor := GET_ACCOUNT_TRANSACTIONS(1);
    END;
    /
