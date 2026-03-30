# DontoSphere

Lean data workspace for the HeyDonto stack.

## What Is Here

- `src/administration/db_setup.sql`: bootstrap script for the local Postgres dev database
- `src/exploration/sql/ddl/`: definitions of both supplier and pms entities
- `src/exploration/notebooks/`: exploration notebooks 
- `datasets/`: source files used during exploration, ensure that 05_SUPPLIER_DATA from the google drive is in this dataste directory.

## Dev Database

The setup script creates a local Postgres database named `heydonto_dev` by default, along with:

- `heydonto_admin`: admin user
- `heydonto_app`: normal app/dev user
- Schemas: `heydonto_core`, `heydonto_raw`, `heydonto_mdm`, `heydonto_stage`, `heydonto_silver`, `heydonto_gold`, `heydonto_analytics`, `heydonto_exploration`

Run it with a Postgres superuser or a role that can create databases and roles:

```bash
psql -U postgres -d postgres \
  -v admin_password='change_me_admin' \
  -v app_password='change_me_app' \
  -f src/exploration/sql/db_setup.sql
```

Optional overrides:

- `db_name`
- `admin_user`
- `app_user`

Example:

```bash
psql -U postgres -d postgres \
  -v db_name='heydonto_dev' \
  -v admin_user='heydonto_admin' \
  -v app_user='heydonto_app' \
  -v admin_password='change_me_admin' \
  -v app_password='change_me_app' \
  -f src/exploration/sql/db_setup.sql
```
