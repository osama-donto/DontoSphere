#!/usr/bin/env python3
"""Filter EzyVet_Input.csv to the 35 selected columns.

Called by load_pms_ezyvet.sql via psql's \\! meta-command.
Writes the filtered CSV to /tmp/_ezyvet_filtered.csv.
"""

import csv
import os

SRC = os.path.join(
    os.path.dirname(__file__),
    os.pardir, os.pardir, os.pardir, os.pardir,
    "datasets", "04_PMS_EXPORTS", "EzyVet_Input.csv",
)
SRC = os.path.normpath(SRC)
DST = "/tmp/_ezyvet_filtered.csv"

# Indices 0-10, 12-35  (skips index 11 = "Supplier Code")
KEEP = list(range(0, 11)) + list(range(12, 36))

with open(SRC, encoding="utf-8-sig", newline="") as fin, \
     open(DST, "w", newline="") as fout:
    reader = csv.reader(fin)
    writer = csv.writer(fout)
    for row in reader:
        writer.writerow([row[i] for i in KEEP])

print(f"Filtered {SRC} -> {DST} ({len(KEEP)} columns)")
