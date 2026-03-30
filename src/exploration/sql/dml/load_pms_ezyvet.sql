\set ON_ERROR_STOP 1

-- Reset EzyVet landing table.
DROP TABLE IF EXISTS heydonto_mdm.pms_ezyvet_report;

\i /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/ddl/PMS/heydonto_mdm_pms_ezyvet_report.sql

-- The source CSV has 76 columns; we only need 35.  Filter to the desired
-- column subset via a Python helper, then \copy the result.
\! python3 /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/dml/_filter_ezyvet_csv.py

\copy heydonto_mdm.pms_ezyvet_report FROM '/tmp/_ezyvet_filtered.csv' WITH (FORMAT csv, HEADER true)
\! rm -f /tmp/_ezyvet_filtered.csv
