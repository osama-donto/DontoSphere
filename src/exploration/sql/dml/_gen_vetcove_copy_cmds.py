#!/usr/bin/env python3
"""Generate \\copy commands for all Vetcove CSV folders.

Called by load_vetcove_mdm.sql via psql's \\! meta-command.
Outputs psql \\copy commands to stdout — one per CSV file, grouped by folder.
"""

import csv
import os
import sys

DATA_ROOT = os.path.join(
    os.path.dirname(__file__),
    os.pardir, os.pardir, os.pardir, os.pardir,
    "datasets", "05_SUPPLIER_DATA", "vetcove",
)
DATA_ROOT = os.path.normpath(DATA_ROOT)

# Fixed column lists for order_history (CSV headers don't normalise cleanly).
_OH_COLS_GL = (
    "vetcove_id, order_date, hospital, item_name, order_number, po_number, "
    "supplier, manufacturer, manufacturer_number, primary_category, "
    "secondary_category, gl_code, vetcove_item_id, cost_per_dose, units, "
    "unit_price, unit_measurement, list_price, quantity, total_price, "
    "item_status, supplier_sku"
)
_OH_COLS_NOGL = (
    "vetcove_id, order_date, hospital, item_name, order_number, po_number, "
    "supplier, manufacturer, manufacturer_number, primary_category, "
    "secondary_category, vetcove_item_id, cost_per_dose, units, "
    "unit_price, unit_measurement, list_price, quantity, total_price, "
    "item_status, supplier_sku"
)


def _normalize_header(name: str) -> str:
    """Map a CSV header token to its PostgreSQL column name."""
    c = name.strip().lower()
    c = c.replace("/", "_")
    c = "_".join(c.split())           # collapse whitespace → single _
    return "".join(ch for ch in c if ch.isalnum() or ch == "_")


def _csv_files(folder: str):
    """Yield sorted (filename, full_path) pairs for CSVs in *folder*."""
    for f in sorted(os.listdir(folder)):
        if f.lower().endswith(".csv"):
            yield f, os.path.join(folder, f)


def _copy_cmd(table: str, cols: str, path: str) -> str:
    return f"\\copy {table} ({cols}) FROM '{path}' WITH (FORMAT csv, HEADER true)"


def items_exports() -> None:
    folder = os.path.join(DATA_ROOT, "items_exports")
    for _, path in _csv_files(folder):
        with open(path, encoding="utf-8-sig", newline="") as fh:
            headers = next(csv.reader(fh))
        cols = ", ".join(_normalize_header(h) for h in headers)
        print(_copy_cmd("heydonto_mdm.vetcove_items_exports", cols, path))


def order_history_by_clinic() -> None:
    folder = os.path.join(DATA_ROOT, "order_history_by_clinic")
    for _, path in _csv_files(folder):
        print(_copy_cmd("heydonto_mdm.vetcove_order_history", _OH_COLS_GL, path))


def order_history_generic() -> None:
    folder = os.path.join(DATA_ROOT, "order_history_generic")
    for _, path in _csv_files(folder):
        with open(path, encoding="utf-8") as fh:
            header_line = fh.readline()
        cols = _OH_COLS_GL if "GL Code" in header_line else _OH_COLS_NOGL
        print(_copy_cmd("heydonto_mdm.vetcove_order_history", cols, path))


if __name__ == "__main__":
    items_exports()
    order_history_by_clinic()
    order_history_generic()
    print(f"-- generated {sum(len(list(_csv_files(os.path.join(DATA_ROOT, d)))) for d in ('items_exports','order_history_by_clinic','order_history_generic'))} \\copy commands", file=sys.stderr)
