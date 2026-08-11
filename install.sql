-- Uruchom po połączeniu jako właściciel pustego schematu ORABANK.

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET ECHO ON
SET SERVEROUTPUT ON

PROMPT [1/7] Tabele
@03_tabele/orabank_tables.sql

PROMPT [2/7] Indeksy
@04_indeksy/orabank_indexes.sql

PROMPT [3/7] Pakiet rachunków
@06_plsql/pakiety/orabank_account_pkg.sql

PROMPT [4/7] Procedury kredytowe
@06_plsql/procedury/orabank_loan_proc.sql

PROMPT [5/7] Funkcje
@06_plsql/funkcje/orabank_account_func.sql

PROMPT [6/7] Triggery audytowe
@07_triggery/orabank_triggers.sql

PROMPT [7/7] Zadania Scheduler
@09_joby/orabank_jobs.sql

@tests/validate_objects.sql

PROMPT Instalacja podstawowa zakończona.
