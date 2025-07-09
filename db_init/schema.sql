CREATE TABLE companies (
  id TEXT PRIMARY KEY,
  company_name TEXT
);

CREATE TABLE payments (
  id SERIAL PRIMARY KEY,
  company_id TEXT,
  employee_id TEXT,
  bank_bsb TEXT,
  bank_account TEXT,
  amount_cents INTEGER,
  currency TEXT,
  pay_date DATE,
  status TEXT DEFAULT 'pending',
  exported_at TIMESTAMP,
  export_file TEXT
);

INSERT INTO companies VALUES
  ('com001', 'Company A'),
  ('com002', 'Company B'),
  ('com003', 'Company C');

INSERT INTO payments (company_id, employee_id, bank_bsb, bank_account, amount_cents, currency, pay_date) VALUES
  ('com001', 'emp001', '062000', '12345678', 250000, 'AUD', '2025-07-09'),
  ('com002', 'emp002', '082003', '98765432', 300000, 'AUD', '2025-07-09'),
  ('com003', 'emp003', '032000', '45612378', 150000, 'AUD', '2025-07-10');
