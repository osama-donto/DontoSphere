-- Raw landing table for all Vetcove order history shapes.
-- Run this while connected to the `heydonto_dev` database.
--
-- Source files:
--   datasets/05_SUPPLIER_DATA/vetcove/order_history_by_clinic/*.csv
--   datasets/05_SUPPLIER_DATA/vetcove/order_history_generic/*.csv
--
-- This table uses the superset of the observed order-history columns.
-- `gl_code` is nullable because some generic extracts do not include it.

CREATE SCHEMA IF NOT EXISTS heydonto_mdm;

CREATE TABLE IF NOT EXISTS heydonto_mdm.vetcove_order_history (
    vetcove_id TEXT,
    order_date TEXT,
    hospital TEXT,
    item_name TEXT,
    order_number TEXT,
    po_number TEXT,
    supplier TEXT,
    manufacturer TEXT,
    manufacturer_number TEXT,
    primary_category TEXT,
    secondary_category TEXT,
    gl_code TEXT,
    vetcove_item_id TEXT,
    cost_per_dose TEXT,
    units TEXT,
    unit_price TEXT,
    unit_measurement TEXT,
    list_price TEXT,
    quantity TEXT,
    total_price TEXT,
    item_status TEXT,
    supplier_sku TEXT
);
