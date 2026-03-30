-- Raw landing table for EzyVet product report.
-- Run this while connected to the `heydonto_dev` database.
--
-- Source file:
--   datasets/04_PMS_EXPORTS/EzyVet_Input.csv
--
-- Only the 35 product/supplier columns are ingested; remaining columns
-- (desexing, death, medication, RVM, label, concentration, etc.) are excluded.


CREATE TABLE IF NOT EXISTS heydonto_mdm.pms_ezyvet_report (
    product_id TEXT,
    product_external_id TEXT,
    product_is_active TEXT,
    product_division TEXT,
    product_code TEXT,
    product_name TEXT,
    product_description TEXT,
    primary_product_group_id TEXT,
    primary_product_group TEXT,
    product_type TEXT,
    supplier_id TEXT,
    supplier_units_per_outer TEXT,
    supplier TEXT,
    product_cost_price TEXT,
    product_markup_pct TEXT,
    product_price TEXT,
    product_tax TEXT,
    product_price_based_on TEXT,
    product_tracking_level TEXT,
    product_warning_text TEXT,
    product_minimum_inventory TEXT,
    product_minimum_reorder TEXT,
    product_minimum_order_type TEXT,
    product_has_direct_cost TEXT,
    product_available_on_web TEXT,
    product_tax_code TEXT,
    product_rrp TEXT,
    product_notes TEXT,
    product_is_purchased TEXT,
    product_is_sold TEXT,
    product_purchases_account TEXT,
    product_sales_account TEXT,
    product_inventory_account TEXT,
    product_barcode TEXT,
    product_is_controlled_drug TEXT
);
