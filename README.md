
R Shiny Application for visualizing expenses and net worth.

# Features

- Enter expenses

- Visualize Spending by Date

- Visualize Spending by Category

- Manage categories, accounts, and account types

- Enter value of each account

- Visualize accounts


# Usage

1. Start PostgreSQL server

2. Create database and tables

```shell
psql postgresuser
CREATE DATABASE databasename;
\c databasename postgresuser
\i init.sql

\l
\dt
```

3. Create `config.yml`

```yml
default:
  database_name: 'databasename'
  database_host: '127.0.0.1'
  database_port: 5432
  database_user: 'postgresuser'
  database_password: 'password'
```

4. Start Application
