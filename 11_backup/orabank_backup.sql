-- Backupu nie uruchamia się jako blok PL/SQL w schemacie aplikacji.
-- Poniższe polecenia są szablonami dla administratora bazy.
-- Dane logowania podawaj interaktywnie lub przez bezpieczny portfel Oracle.

-- Data Pump export:
-- expdp orabank@service schemas=ORABANK directory=DATA_PUMP_DIR dumpfile=orabank_%U.dmp logfile=orabank_export.log parallel=2

-- Data Pump import do pustego schematu testowego:
-- impdp system@service directory=DATA_PUMP_DIR dumpfile=orabank_%U.dmp logfile=orabank_import.log remap_schema=ORABANK:ORABANK_TEST

-- Przed odtworzeniem wykonaj próbę na odizolowanym środowisku i sprawdź:
-- 1. liczbę obiektów oraz obiekty INVALID,
-- 2. spójność kluczy obcych,
-- 3. pakiety i procedury,
-- 4. kontrolowany test przelewu,
-- 5. politykę retencji i szyfrowania plików dump.
