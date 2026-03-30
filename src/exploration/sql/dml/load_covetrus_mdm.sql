\set ON_ERROR_STOP 1

-- Reset the Covetrus raw landing area to the current schema model.
CREATE SCHEMA IF NOT EXISTS heydonto_mdm_covetrus;
DROP TABLE IF EXISTS heydonto_mdm_covetrus.covetrus_gl_codes_report;
DROP TABLE IF EXISTS heydonto_mdm_covetrus.covetrus_purchase_history_report;

-- Apply raw landing DDLs for Covetrus supplier extracts.
\i /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/ddl/heydonto_mdm_covetrus_gl_codes_report.sql
\i /Users/osama/workspace/personal/DontoSphere/src/exploration/sql/ddl/heydonto_mdm_covetrus_purchase_history_report.sql

CREATE TEMP TABLE stg_covetrus_gl_codes_report (
    customer_nbr TEXT,
    delivery_seq_nbr TEXT,
    dvm TEXT,
    clinic TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    invoice_nbr TEXT,
    invoice_date TEXT,
    order_nbr TEXT,
    vendor TEXT,
    line_nbr TEXT,
    cona_product_nbr TEXT,
    product_desc TEXT,
    gl_code TEXT,
    quantity TEXT,
    uom TEXT,
    line_value TEXT,
    line_tax TEXT,
    category TEXT,
    po_nbr TEXT
);

\copy stg_covetrus_gl_codes_report (customer_nbr, delivery_seq_nbr, dvm, clinic, address, city, state, zip, invoice_nbr, invoice_date, order_nbr, vendor, line_nbr, cona_product_nbr, product_desc, gl_code, quantity, uom, line_value, line_tax, category, po_nbr) FROM '/Users/osama/workspace/personal/DontoSphere/datasets/05_SUPPLIER_DATA/covetrus/Covetrus_GL_Codes_Report.csv' WITH (FORMAT csv, HEADER true);
INSERT INTO heydonto_mdm_covetrus.covetrus_gl_codes_report
SELECT '/Users/osama/workspace/personal/DontoSphere/datasets/05_SUPPLIER_DATA/covetrus/Covetrus_GL_Codes_Report.csv', s.*
FROM stg_covetrus_gl_codes_report AS s;

CREATE TEMP TABLE stg_covetrus_purchase_history_report (
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

\copy stg_covetrus_purchase_history_report (sku, description, last_order_date, last_order_quantity, sep_24, oct_24, nov_24, dec_24, jan_25, feb_25, mar_25, apr_25, may_25, jun_25, jul_25, aug_25, sep_25, total) FROM '/Users/osama/workspace/personal/DontoSphere/datasets/05_SUPPLIER_DATA/covetrus/Covetrus_Purchase_History_Report.csv' WITH (FORMAT csv, HEADER true);
INSERT INTO heydonto_mdm_covetrus.covetrus_purchase_history_report
SELECT '/Users/osama/workspace/personal/DontoSphere/datasets/05_SUPPLIER_DATA/covetrus/Covetrus_Purchase_History_Report.csv', s.*
FROM stg_covetrus_purchase_history_report AS s;
