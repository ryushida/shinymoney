-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

CREATE TABLE IF NOT EXISTS account_type (
	account_type_id SERIAL PRIMARY KEY,
	account_type varchar(40) UNIQUE
);


CREATE TABLE IF NOT EXISTS account (
	account_id SERIAL PRIMARY KEY,
	account_name varchar(40) UNIQUE,
	account_type_id integer REFERENCES account_type (account_type_id)
);

CREATE TABLE IF NOT EXISTS expense_category (
	category_id SERIAL PRIMARY KEY,
	category_name varchar(40) UNIQUE
);

CREATE TABLE IF NOT EXISTS expense (
	expense_id SERIAL PRIMARY KEY,
	date date,
	account_id integer REFERENCES account (account_id),
	amount numeric,
	category_id integer REFERENCES expense_category (category_id),
	note varchar(140)
);

CREATE TABLE IF NOT EXISTS subscription (
  subscription_id SERIAL PRIMARY KEY,
  subscription_name varchar(50) UNIQUE,
  category_id integer REFERENCES expense_category (category_id),
  subscription_price numeric
);

CREATE TABLE IF NOT EXISTS account_value (
  account_id integer REFERENCES account(account_id) UNIQUE,
  account_value numeric
);
