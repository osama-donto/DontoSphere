-- Raw landing table for all Vetcove item export shapes.
-- Run this while connected to the `heydonto_dev` database.
--
-- Source files:
--   datasets/05_SUPPLIER_DATA/vetcove/items_exports/vetcove_items_export_10_14_2025_2.csv
--   datasets/05_SUPPLIER_DATA/vetcove/items_exports/vetcove_items_export_10_14_2025_3.csv
--   datasets/05_SUPPLIER_DATA/vetcove/items_exports/vetcove_items_export_10_14_2025_1.csv
--
-- This table uses the superset of the observed item-export columns.
-- Every column is nullable by default so narrower extracts can load into the
-- same table when you provide a column list in COPY or \copy.

CREATE SCHEMA IF NOT EXISTS heydonto_mdm;

CREATE TABLE IF NOT EXISTS heydonto_mdm.vetcove_items_exports (
    vetcove_id TEXT,
    item_name TEXT,
    manufacturer_name TEXT,
    manufacturer_no TEXT,
    category TEXT,
    units TEXT,
    last_purchase TEXT,
    last_purchase_list_price TEXT,
    number_of_orders TEXT,
    percentage_of_total_volume TEXT,
    quantity TEXT,
    total TEXT,
    covetrus_sku TEXT,
    mwi_sku TEXT,
    patterson_sku TEXT,
    midwest_sku TEXT,
    first_vet_sku TEXT,
    wedgewood_pharmacy_sku TEXT,
    penn_vet_sku TEXT,
    amatheon_sku TEXT,
    idexx_sku TEXT,
    victor_sku TEXT,
    american_regent_sku TEXT,
    vetcove_sku TEXT,
    miller_vet_sku TEXT,
    boehringer_ingelheim_sku TEXT,
    zoetis_sku TEXT,
    pharmsource_ah_sku TEXT,
    ne_animal_health_sku TEXT,
    dechra_sku TEXT,
    medline_sku TEXT,
    ivet_sku TEXT,
    epicur_stokes_sku TEXT,
    elanco_sku TEXT,
    merck_sku TEXT
);
