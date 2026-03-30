### Supplier Data Pipeline

- Supplier-to-PMS Pairing : Supplier datasets are scoped per customer site. Items are only enriched by supplier data explicitly bound to that site's account identifiers (e.g., Vetcove ID, distributor number).
- Data Cleaning Filters : Exclude rows with quantity ≤ 0 or total cost ≤ 0.
- Deduplication Logic : Group by composite keys (e.g., Vetcove ID + Mfr No. + Units). Aggregate quantities and use the most recent cost for duplicates.
- Compliance Inheritance : Attributes inherit from: (1) Matched PIMS/Catalog items; (2) Customer-defined default profiles (e.g., "non-controlled" sets witness flags to 0); or (3) Manual override.

### Product Classification

- TYPE Mapping (PIMS) : ezyVet: "Standard" + med group → TYPE=2; "Procedure/Fee" → TYPE=1.
- Strong Exclusions : Always exclude items where: (1) Product Type is Fee, Service, or Lab; (2) Description matches service patterns (e.g., "exam", "x-ray"); (3) UOM is zero or null.
- Inclusion Criteria : Item must have (TYPE=1 OR TYPE=2) AND a tangible UOM (e.g., TAB, ML, EA) AND not be on the exclusion list.