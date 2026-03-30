### Data Extraction & Sources

- Primary PIMS Sources: The primary source of truth for item IDs, descriptions, schedules, and on-hand quantities it contains Core clinical and inventory data (Description, Strength, Schedule) are extracted from systems like ezyVet, Cornerstone, Impromed, Instinct, and Shephard
- Supplier Sources: Includes Vetcove order history, MWI invoices, and Covetrus purchase records. It provides enrichment for Supplier Name, SKU, Bulk Order Unit (BOU), Bulk Order Quantity (BOQ), and cost.
- Reference Tables: Authoritative data for normalization includes the Cubex Item Catalog, FDA/DailyMed references, and a standardized Unit of Measure (UOM), strength, dosage form, and witness flags.

### Survivorship & Lineage Validation

- Survivorship Hierarchy: When data conflicts occur, the priority is: 
    (1) PIMS Data : 
    (2) Cubex Catalog : The authoritative reference for drug attributes like strength, dosage form, and witness flags.
    (3) Supplier Enrichment : It provides enrichment for Supplier Name, SKU, Bulk Order Unit (BOU), Bulk Order Quantity (BOQ), and cost, Includes Vetcove order history, MWI invoices, and Covetrus purchase records
    (4) FDA/External References
    (5) Manual Stewardship.
- Supplier-to-Site Pairing: Supplier data is scoped per customer site and must be explicitly bound to that site's account identifiers (e.g., Vetcove ID).2
- Financial Integrity: 
    - Bulk Order Quantity (BM) and Cost (CG) must both be > 0. 
    - The system validates that (CG ÷ BM) = Derived Unit Cost within a ±$0.01 tolerance
- Audit Trail: Every transformed value must carry metadata indicating its origin, rank, and confidence score for full lineage tracking
- Fuzzy Matching: Automated catalog alignment requires a match score >= 85% based on a multi-attribute weighted formula (Description, NDC, Manufacturer Number, Strength/Form). Scores between 70% and 84% are flagged for manual review


### Practice Management System (PMS) Rules 

- The PMS (or Lab Management Software/LMS) is the primary system of record for data acquisition
- Data Source Role: Serves as the primary system for fetching item catalogs, users, and doctors
- Extraction Method: Because APIs are rare, the system relies on exported reports (CSV or Excel formats)
- Scope of Data: Must provide Item Data, User Data, Supplier Data, and Price Data
- Data Gap Filling: Since PMS data is often incomplete, it must be cross-referenced with Mashura Enriched Datasets and Industry Datasets (e.g., openFDA, DailyMed) to normalize attributes
- User Integration: FUSE imports user lists from the PMS to ensure consistent name formatting and to speed up permission assignments
- Constraint Validation: All extracted data must adhere to database constraints, such as a 35-character limit for item descriptions
- Item Identification: Every record must include a unique PIMS Item Identifier (Item ID).
- TYPE Mapping: Product Type is derived from PIMS-specific fields using a decision tree:
    - ezyVet: "Standard" + medication group → TYPE 2; "Procedure/Fee/Service" → TYPE 1.
    - Cornerstone: "Pharmacy" → TYPE 2; "Service/Lab/Fee" → TYPE 1
    - Shephard: Determined by the "Is it a supply?" column.
- Category Extraction: Rules vary by system:
    - Avimark: Split on hyphen; left side is the Category.
    - Cornerstone: Uses the tab label directly as the Category
    - ezyVet: Extracted from Column G.
- Exclusion Logic: Tangible items are included, while non-tangible items (Fees, Services, Procedures) are excluded.

## Entities

- Item Data 
- User Data
- Supplier Data
- Price Data


### Supplier Data Rules

- Supplier data is used to enrich clinical item attributes with financial and logistical context
- Attribute Association: Supplier details (Vendor, SKU) must be joined to inventory items for reordering purposes
- Data Matching: When PMS data lacks supplier info, FUSE uses the Mashura Enriched Dataset to attribute specific supplier data to items
- Ordering Logic: Supplier data includes critical fields for reordering, such as Package Quantity (Bulk Order Qty) and Unit Cost
- Validation: Supplier-related fields in the final catalog must include the vendor name and specific SKU to be considered complete.

### General Enrichment & Synchronization Rules

- Survivorship: FUSE synchronizes PMS data with a Mashura enriched database to determine baseline settings based on comparable facility sizes
- High-Precision Confidence: The system uses multiple data points (PMS + Supplier + Industry Web Services) to validate item data and achieve high-precision confidence in attributes
- Out of Scope: Assigning items to specific drawers or doors within a cabinet is not handled by FUSE; this must be done at the physical inventory device.
- Site-Specific Scoping: Supplier data must be explicitly bound to a customer site's account identifiers (e.g., Vetcove account or distributor ID) to prevent cross-site enrichment.
- Data Cleaning (Trust Rules):
    - Exclude rows with quantity or total cost ≤ 0.5
    - Exclude cancelled, void, or return transactions
    - Apply a default 12 month lookback window for valid purchases.
- Deduplication: Logic groups data by composite keys (e.g., Vetcove ID + Manufacturer No. + Units). It aggregates quantities and utilizes the most recent cost when duplicates exist.
- Enrichment Role: Supplier data is Rank 3 in the hierarchy, primarily used to add packaging (Total Volume) and pricing (Cost of Bulk Order Unit) data
- Financial Validation: The calculation (Cost of Bulk Order Unit / Bulk Order Quantity) must equal the Derived Cost per Unit within a ±$0.01 tolerance.
- Compliance Restriction: Compliance attributes (e.g., witness flags) are never derived from supplier data alone; they must inherit from a matched PIMS/Catalog item or a customer default profile.

### Supplier Data Pipeline

## Association & Pairing Logic

- Site-Specific Pairing: Supplier datasets are strictly scoped per customer site. A site's canonical Item List can only be enriched by supplier data explicitly bound to that site's account identifiers (e.g., Vetcove account ID or distributor customer number).
- Three-Source Merge: The intended architecture follows a multi-source merge: PIMS Export (Rank 1) + Cubex Catalog (Rank 2) + Supplier Data (Rank 3)
- Matching Key: Supplier products are matched to PIMS items via fuzzy matching algorithms (e.g., Levenshtein, vector embeddings)

## Supplier Data Business Rules

- Survivorship Hierarchy: When data conflicts occur, the priority is: Cubex Catalog > PIMS > Supplier Data > FDA > Manual Stewardship.
- Data Cleaning & Trust:
    - Exclusions: Exclude rows with quantity ≤ 0, total cost ≤ 0, or statuses like "cancelled," "void," or "return".
    - Lookback Window: A default 12-month lookback window is applied to supplier history
- Deduplication: Supplier order history (which contains multiple rows per product) must be consolidated to one row per product (grouping by Vetcove ID + Manufacturer No. + Units) before merging
- Cost Selection: For each supplier-item pair, the most recent order's price is used, with "List Price" preferred over "Unit Price"
- BOU/BOQ Derivation:
    - BOQ: Defaults to 1 if no pack-size data is available in the supplier source.
    - BOU: Should be derived from the Cubex Catalog (if a ≥90 match exists) or supplier-side data. It must not default to the Unit of Issue (UOI) to avoid false confidence
-Compliance Flags: Attributes like witness or lot tracking are never derived from supplier data alone; they must inherit from a matched PIMS/Catalog item or customer-defined default profiles.