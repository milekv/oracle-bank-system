-- Plik: orabank_jobs.sql
-- Cel: Zadania cykliczne (Oracle Scheduler) w OraBank

BEGIN
    -- Job: codzienna aktualizacja odsetek dla kredytów
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_DAILY_INTEREST',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            BEGIN
                FOR rec IN (SELECT LOAN_ID, AMOUNT, INTEREST_RATE FROM LOAN WHERE STATUS = ''AKTYWNY'') LOOP
                    UPDATE LOAN
                    SET AMOUNT = rec.AMOUNT + (rec.AMOUNT * rec.INTEREST_RATE / 100 / 30)
                    WHERE LOAN_ID = rec.LOAN_ID;
                END LOOP;
            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );

    -- Job: codzienna aktualizacja historii sald
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_DAILY_BALANCE_HISTORY',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            BEGIN
                FOR rec IN (SELECT ACCOUNT_ID, BALANCE FROM ACCOUNT) LOOP
                    INSERT INTO BALANCE_HISTORY(ACCOUNT_ID, BALANCE, CHANGE_DATE)
                    VALUES(rec.ACCOUNT_ID, rec.BALANCE, SYSDATE);
                END LOOP;
            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );

    -- Job: tygodniowe generowanie raportu top klientów
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_WEEKLY_TOP_CLIENTS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            BEGIN
                DELETE FROM VW_TOP_CLIENTS;
                INSERT INTO VW_TOP_CLIENTS(CLIENT_ID, TOTAL_AMOUNT)
                SELECT CLIENT_ID, SUM(AMOUNT)
                FROM TRANSACTION
                GROUP BY CLIENT_ID;
            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=1; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );

END;
/
