-- Zadania Oracle Scheduler.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_DAILY_BALANCE_HISTORY',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[
            BEGIN
                INSERT INTO BALANCE_HISTORY (ACCOUNT_ID, BALANCE, CHANGE_DATE)
                SELECT ACCOUNT_ID, BALANCE, SYSDATE
                  FROM ACCOUNT
                 WHERE STATUS = 'AKTYWNY';
            END;
        ]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;BYHOUR=0;BYMINUTE=5;BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Dzienny snapshot sald aktywnych rachunków'
    );

    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_CLOSE_EXPIRED_LOANS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[
            BEGIN
                UPDATE LOAN
                   SET STATUS = 'ZAKOŃCZONY'
                 WHERE STATUS = 'AKTYWNY'
                   AND END_DATE < TRUNC(SYSDATE)
                   AND NOT EXISTS (
                       SELECT 1
                         FROM LOAN_INSTALLMENT li
                        WHERE li.LOAN_ID = LOAN.LOAN_ID
                          AND li.PAID_FLAG = 'N'
                   );
            END;
        ]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Zamyka wygasłe kredyty bez niespłaconych rat'
    );
END;
/
