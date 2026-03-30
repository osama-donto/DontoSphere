\set ON_ERROR_STOP 1

-- -----------------------------------------------------------------------------
-- HeyDonto development database bootstrap
--
-- Usage:
--   psql -U postgres -d postgres \
--     -v admin_password='change_me_admin' \
--     -v app_password='change_me_app' \
--     -f src/exploration/sql/db_setup.sql
--
-- Optional overrides:
--   -v db_name='heydonto_dev'
--   -v admin_user='heydonto_admin'
--   -v app_user='heydonto_app'
--
-- Notes:
--   * Run this script with a superuser or a role that can create roles/databases.
--   * The script is safe to re-run. Existing roles/databases/schemas are updated
--     rather than recreated.
-- -----------------------------------------------------------------------------

\if :{?db_name}
\else
  \set db_name 'heydonto_dev'
\endif

\if :{?admin_user}
\else
  \set admin_user 'heydonto_admin'
\endif

\if :{?app_user}
\else
  \set app_user 'heydonto_app'
\endif

\if :{?admin_password}
\else
  \set admin_password 'heydonto_admin_dev'
\endif

\if :{?app_password}
\else
  \set app_password 'heydonto_app_dev'
\endif

\echo === Bootstrapping roles in postgres ===
\connect postgres

SELECT format(
  $sql$
  DO $do$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = %L) THEN
      CREATE ROLE %I
        LOGIN
        NOSUPERUSER
        INHERIT
        CREATEDB
        CREATEROLE
        PASSWORD %L;
    ELSE
      ALTER ROLE %I
        WITH LOGIN
        NOSUPERUSER
        INHERIT
        CREATEDB
        CREATEROLE
        PASSWORD %L;
    END IF;
  END
  $do$;
  $sql$,
  :'admin_user',
  :'admin_user',
  :'admin_password',
  :'admin_user',
  :'admin_password'
)
\gexec

SELECT format(
  $sql$
  DO $do$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = %L) THEN
      CREATE ROLE %I
        LOGIN
        NOSUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        PASSWORD %L;
    ELSE
      ALTER ROLE %I
        WITH LOGIN
        NOSUPERUSER
        INHERIT
        NOCREATEDB
        NOCREATEROLE
        PASSWORD %L;
    END IF;
  END
  $do$;
  $sql$,
  :'app_user',
  :'app_user',
  :'app_password',
  :'app_user',
  :'app_password'
)
\gexec

\echo === Creating database if needed ===
SELECT format(
  'CREATE DATABASE %I OWNER %I ENCODING ''UTF8'' TEMPLATE template0',
  :'db_name',
  :'admin_user'
)
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_database
  WHERE datname = :'db_name'
)
\gexec

SELECT format(
  'ALTER DATABASE %I OWNER TO %I',
  :'db_name',
  :'admin_user'
)
\gexec

SELECT format(
  'COMMENT ON DATABASE %I IS %L',
  :'db_name',
  'Development database for the HeyDonto stack'
)
\gexec

SELECT format(
  'REVOKE ALL ON DATABASE %I FROM PUBLIC',
  :'db_name'
)
\gexec

SELECT format(
  'GRANT CONNECT, TEMP ON DATABASE %I TO %I',
  :'db_name',
  :'admin_user'
)
\gexec

SELECT format(
  'GRANT CONNECT, TEMP ON DATABASE %I TO %I',
  :'db_name',
  :'app_user'
)
\gexec

SELECT format(
  'ALTER DATABASE %I SET search_path = heydonto_core, heydonto_raw, heydonto_mdm, heydonto_stage, heydonto_silver, heydonto_gold, heydonto_analytics, heydonto_exploration, public',
  :'db_name'
)
\gexec

\echo === Configuring schemas inside :db_name ===
\connect :db_name

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO :"admin_user";
GRANT USAGE ON SCHEMA public TO :"app_user";

CREATE SCHEMA IF NOT EXISTS heydonto_core;
CREATE SCHEMA IF NOT EXISTS heydonto_raw;
CREATE SCHEMA IF NOT EXISTS heydonto_mdm;
CREATE SCHEMA IF NOT EXISTS heydonto_stage;
CREATE SCHEMA IF NOT EXISTS heydonto_silver;
CREATE SCHEMA IF NOT EXISTS heydonto_gold;
CREATE SCHEMA IF NOT EXISTS heydonto_analytics;
CREATE SCHEMA IF NOT EXISTS heydonto_exploration;

ALTER SCHEMA heydonto_core OWNER TO :"admin_user";
ALTER SCHEMA heydonto_raw OWNER TO :"admin_user";
ALTER SCHEMA heydonto_mdm OWNER TO :"admin_user";
ALTER SCHEMA heydonto_stage OWNER TO :"admin_user";
ALTER SCHEMA heydonto_silver OWNER TO :"admin_user";
ALTER SCHEMA heydonto_gold OWNER TO :"admin_user";
ALTER SCHEMA heydonto_analytics OWNER TO :"admin_user";
ALTER SCHEMA heydonto_exploration OWNER TO :"admin_user";

COMMENT ON SCHEMA heydonto_core IS 'Canonical application tables, shared dimensions, and reference data.';
COMMENT ON SCHEMA heydonto_raw IS 'Raw landed data from suppliers and external systems.';
COMMENT ON SCHEMA heydonto_mdm IS 'Directly landed external data files such as CSV, Parquet, and JSON before downstream transformation.';
COMMENT ON SCHEMA heydonto_stage IS 'Cleaned and conformed staging tables.';
COMMENT ON SCHEMA heydonto_silver IS 'Validated and standardized intermediate datasets for downstream modeling.';
COMMENT ON SCHEMA heydonto_gold IS 'Business-ready curated models, aggregates, and consumption-layer objects.';
COMMENT ON SCHEMA heydonto_analytics IS 'Reporting, marts, and analytics-facing objects.';
COMMENT ON SCHEMA heydonto_exploration IS 'Scratch space for notebooks, profiling, and exploratory work.';

GRANT ALL PRIVILEGES ON SCHEMA heydonto_core TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_raw TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_mdm TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_stage TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_silver TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_gold TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_analytics TO :"admin_user";
GRANT ALL PRIVILEGES ON SCHEMA heydonto_exploration TO :"admin_user";

GRANT USAGE, CREATE ON SCHEMA heydonto_core TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_raw TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_mdm TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_stage TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_silver TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_gold TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_analytics TO :"app_user";
GRANT USAGE, CREATE ON SCHEMA heydonto_exploration TO :"app_user";

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_core TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_raw TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_mdm TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_stage TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_silver TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_gold TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_analytics TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON ALL TABLES IN SCHEMA heydonto_exploration TO :"app_user";

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_core TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_raw TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_mdm TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_stage TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_silver TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_gold TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_analytics TO :"app_user";
GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA heydonto_exploration TO :"app_user";

GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_core TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_raw TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_mdm TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_stage TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_silver TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_gold TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_analytics TO :"app_user";
GRANT EXECUTE
ON ALL FUNCTIONS IN SCHEMA heydonto_exploration TO :"app_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_core
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_raw
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_mdm
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_stage
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_silver
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_gold
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_analytics
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_exploration
  GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
  ON TABLES TO :"app_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_core
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_raw
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_mdm
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_stage
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_silver
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_gold
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_analytics
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_exploration
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO :"app_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_core
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_raw
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_mdm
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_stage
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_silver
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_gold
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_analytics
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"admin_user" IN SCHEMA heydonto_exploration
  GRANT EXECUTE ON FUNCTIONS TO :"app_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_core
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_raw
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_mdm
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_stage
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_silver
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_gold
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_analytics
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_exploration
  GRANT ALL PRIVILEGES ON TABLES TO :"admin_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_core
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_raw
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_mdm
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_stage
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_silver
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_gold
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_analytics
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_exploration
  GRANT ALL PRIVILEGES ON SEQUENCES TO :"admin_user";

ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_core
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_raw
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_mdm
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_stage
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_silver
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_gold
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_analytics
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";
ALTER DEFAULT PRIVILEGES FOR ROLE :"app_user" IN SCHEMA heydonto_exploration
  GRANT EXECUTE ON FUNCTIONS TO :"admin_user";

ALTER ROLE :"admin_user" IN DATABASE :"db_name"
  SET search_path = heydonto_core, heydonto_raw, heydonto_mdm, heydonto_stage, heydonto_silver, heydonto_gold, heydonto_analytics, heydonto_exploration, public;
ALTER ROLE :"app_user" IN DATABASE :"db_name"
  SET search_path = heydonto_core, heydonto_raw, heydonto_mdm, heydonto_stage, heydonto_silver, heydonto_gold, heydonto_analytics, heydonto_exploration, public;

\echo === Bootstrap complete ===
\echo Database  : :db_name
\echo Admin user: :admin_user
\echo App user  : :app_user
