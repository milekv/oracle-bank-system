-- Plik: orabank_backup.sql
-- Cel: Backup i przywracanie bazy OraBank

-- 1️⃣ Procedura eksportu danych (Data Pump)
-- (uruchamiane w SQL*Plus lub RMAN)
BEGIN
    DBMS_DATAPUMP.OPEN('EXPORT','SCHEMA','ORABANK');
    DBMS_OUTPUT.PUT_LINE('Backup schematu OraBank został rozpoczęty');
END;
/

-- 2️⃣ Procedura importu danych (przywracanie)
-- (uruchamiane w SQL*Plus lub RMAN)
BEGIN
    DBMS_DATAPUMP.OPEN('IMPORT','SCHEMA','ORABANK');
    DBMS_OUTPUT.PUT_LINE('Przywracanie schematu OraBank zostało rozpoczęte');
END;
/
