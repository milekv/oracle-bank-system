import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, extname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const requiredFiles = [
  "03_tabele/orabank_tables.sql",
  "04_indeksy/orabank_indexes.sql",
  "06_plsql/pakiety/orabank_account_pkg.sql",
  "06_plsql/procedury/orabank_loan_proc.sql",
  "06_plsql/funkcje/orabank_account_func.sql",
  "07_triggery/orabank_triggers.sql",
  "09_joby/orabank_jobs.sql",
  "tests/validate_objects.sql",
  "tests/smoke_test.sql",
];

const errors = [];
for (const path of requiredFiles) {
  if (!existsSync(join(root, path))) {
    errors.push(`missing required file: ${path}`);
  }
}

const collectFiles = (directory) =>
  readdirSync(directory).flatMap((name) => {
    const path = join(directory, name);
    if (name === ".git") return [];
    return statSync(path).isDirectory() ? collectFiles(path) : [path];
  });

const textFiles = collectFiles(root).filter((path) => [".sql", ".md"].includes(extname(path).toLowerCase()));
const forbiddenPatterns = [
  [/\b(?:admin|teller|auditor|ora)123\b/i, "example password"],
  [/TRANSACTION_SEQ/i, "sequence incompatible with identity columns"],
  [/\b(?:FROM|INTO|ON|REFERENCES)\s+TRANSACTION\b/i, "legacy TRANSACTION table reference"],
  [/UPDATE_ACCOUNT_BALANCE\s*:=/i, "invalid PL/SQL assignment"],
  [/[–—]/, "long dash character"],
];

for (const path of textFiles) {
  const text = readFileSync(path, "utf8");
  for (const [pattern, label] of forbiddenPatterns) {
    if (pattern.test(text)) {
      errors.push(`${relative(root, path)}: ${label}`);
    }
  }
}

if (errors.length) {
  console.error("Static checks failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`Static checks passed for ${textFiles.length} SQL and documentation files.`);
