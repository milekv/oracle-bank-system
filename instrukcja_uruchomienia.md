# OraBank - instrukcja uruchomienia

[English README](README.md)

## Wymagania

- Oracle Database 19c lub 21c.
- SQL*Plus albo SQLcl.
- Pusty schemat developerski `ORABANK`.
- Dla jobów uprawnienie `CREATE JOB`.
- Dla opcjonalnego materialized view uprawnienie `CREATE MATERIALIZED VIEW`.

Nie zapisuj hasła w repozytorium ani w historii powłoki. Użyj interaktywnego logowania lub Oracle Wallet.

## Instalacja podstawowa

Połącz się jako właściciel pustego schematu i uruchom:

```sql
@install.sql
```

Skrypt instaluje kolejno tabele, indeksy, pakiet rachunków, procedury kredytowe, funkcje, trigger audytowy oraz joby. Na końcu sprawdza obiekty `INVALID`. Pierwszy błąd SQL zatrzymuje instalację.

## Test dymny

```sql
@tests/smoke_test.sql
```

Test:

- tworzy dwóch klientów i dwa rachunki,
- wykonuje przelew 250 jednostek,
- sprawdza oba salda,
- sprawdza dwa wpisy w `BANK_TRANSACTION`,
- wycofuje wszystkie dane testowe.

## Bezpieczeństwo

Tworzenie ról i użytkowników wymaga połączenia administracyjnego:

```sql
@08_bezpieczenstwo/orabank_security.sql
```

Skrypt prosi o trzy hasła przez ukryty prompt. Nie zawiera haseł domyślnych. Nowe konta muszą zmienić hasło przy pierwszym logowaniu.

## Moduły opcjonalne

Obiekty raportowe i statystyki:

```sql
@10_wydajnosc/orabank_performance.sql
```

Przykład interval partitioning tworzy osobne tabele laboratoryjne i nie migruje danych podstawowych:

```sql
@05_partycjonowanie/orabank_partitioning.sql
```

## Sprawdzenie stanu

Obiekty PL/SQL:

```sql
SELECT object_type, object_name, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY object_type, object_name;
```

Joby:

```sql
SELECT job_name, enabled, state, last_start_date, next_run_date
FROM user_scheduler_jobs
ORDER BY job_name;
```

Błędy kompilacji:

```sql
SELECT name, type, line, position, text
FROM user_errors
ORDER BY name, sequence;
```

## Backup i odtwarzanie

Plik `11_backup/orabank_backup.sql` zawiera szablony Data Pump bez danych logowania. Próbę odtworzenia wykonuj w odizolowanym schemacie testowym i sprawdzaj obiekty, klucze obce, pakiety oraz smoke test przed uznaniem backupu za poprawny.
