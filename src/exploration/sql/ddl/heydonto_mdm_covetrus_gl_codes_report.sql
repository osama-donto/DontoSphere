-- Raw landing table for the Covetrus GL Codes report.
-- Run this while connected to the `heydonto_dev` database.
--
-- Source files:
--   datasets/05_SUPPLIER_DATA/covetrus/Covetrus_GL_Codes_Report.csv

CREATE SCHEMA IF NOT EXISTS heydonto_mdm_covetrus;

CREATE TABLE IF NOT EXISTS heydonto_mdm_covetrus.covetrus_gl_codes_report (
    file_source TEXT,
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
