\set ON_ERROR_STOP 1

-- Reset Vetcove landing tables.
DROP TABLE IF EXISTS heydonto_mdm.vetcove_order_history;
DROP TABLE IF EXISTS heydonto_mdm.vetcove_items_exports;

\i /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/ddl/heydonto_mdm_vetcove_items_exports.sql
\i /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/ddl/heydonto_mdm_vetcove_order_history.sql

-- Generate and execute \copy commands for all Vetcove CSV folders.
-- The helper script iterates each folder, detects header shapes, and emits
-- one \copy per file directly into the landing tables (no temp tables).
--
-- Folder groups:
--   items_exports/          – varying column subsets, normalised from header
--   order_history_by_clinic – uniform shape, all include GL Code
--   order_history_generic   – mixed: header sniffed for GL Code presence
\! python3 /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/dml/_gen_vetcove_copy_cmds.py > /tmp/_vetcove_loads.sql
\i /tmp/_vetcove_loads.sql
\! rm -f /tmp/_vetcove_loads.sql
