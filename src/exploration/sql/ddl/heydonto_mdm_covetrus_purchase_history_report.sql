-- Raw landing table for the Covetrus purchase history report.
-- Run this while connected to the `heydonto_dev` database.
--
-- Source files:
--   datasets/05_SUPPLIER_DATA/covetrus/Covetrus_Purchase_History_Report.csv

CREATE SCHEMA IF NOT EXISTS heydonto_mdm_covetrus;

CREATE TABLE IF NOT EXISTS heydonto_mdm_covetrus.covetrus_purchase_history_report (
    file_source TEXT,
    sku TEXT,
    description TEXT,
    last_order_date TEXT,
    last_order_quantity TEXT,
    sep_24 TEXT,
    oct_24 TEXT,
    nov_24 TEXT,
    dec_24 TEXT,
    jan_25 TEXT,
    feb_25 TEXT,
    mar_25 TEXT,
    apr_25 TEXT,
    may_25 TEXT,
    jun_25 TEXT,
    jul_25 TEXT,
    aug_25 TEXT,
    sep_25 TEXT,
    total TEXT
);
