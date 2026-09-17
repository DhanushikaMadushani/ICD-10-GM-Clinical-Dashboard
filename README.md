# 🏥 ICD-10-GM Clinical Intelligence & Inpatient Flow Dashboard

An interactive clinical intelligence solution built in **Power BI Desktop** analyzing **17.9M inpatient hospital admissions** across Germany, based on official public health census data from the **German Federal Statistical Office (Destatis)**.

---

## 📊 Dashboard Preview

![ICD-10-GM Dashboard](dashboard.png)

---

## 📌 Project Overview & Objectives

* **Source:** German Federal Statistical Office (*Statistisches Bundesamt - Destatis*) https://www-genesis.destatis.de/datenbank/online/.
* **Scope:** 17.9M inpatient hospital census records classified under the official **ICD-10-GM** (German Modification) clinical taxonomy.
* **Goal:** Ingest unstructured hospital census records, resolve data anomalies (double-counting defects), model dimensional relationships, and engineer an executive-level operational dashboard.

---

## 🔄 Data Pipeline & ETL Workflow

* **Data Cleaning (Power Query):**
  * Filtered out pre-calculated `"Insgesamt"` (total) aggregate rows to eliminate a 100%+ double-counting defect.
  * Unpivoted nested demographic columns into normalized key-value pairs.
  * Replaced delimiter anomalies across semicolon-separated values.
* **Language Hybridization:**
  * Built an English user interface shell while preserving native German ICD-10-GM clinical classifications to maintain data integrity.
* **Chronological Sorting:**
  * Created a custom sorting index to override Power BI’s default alphabetical sorting on age brackets (e.g., *unter 1 Jahr*, *1 bis unter 5 Jahre*, etc.).

---

## 📈 Key Dashboard Metrics

* **Total Inpatient Count:** 17.9M baseline hospital admissions.
* **Geriatric Cases (65+):** 10.0M admissions (~56% of total volume).
* **Pediatric Cases (<18):** 1.8M admissions (~10% of total volume).
* **Gender Ratio:** 0.52 Female / 0.48 Male case balance.
* **Leading Department:** *Innere Medizin* (Internal Medicine) leading network utilization at **23.19%**, followed by *Chirurgie* (General Surgery) at **13.43%**.
* **Top Diagnosis:** *Krankheiten des Kreislaufsystems* (Cardiovascular Diseases) with **2.65M cases** ranked #1.

---

## 💾 Database Architecture & SQL Verification

To ensure data integrity and prevent reporting discrepancies, an upstream **PostgreSQL** layer was built to audit and reproduce the core dashboard KPIs directly against raw data before BI modeling:

* **Baseline Volume Audit:** Validated total inpatient volume (~17.9M admissions) using summary aggregations.
* **Department Capacity Share:** Calculated clinical department volume distribution (`Innere Medizin` leading at 23.19%) utilizing empty window partitions (`SUM(...) OVER ()`).
* **Clinical Diagnosis Ranking:** Extracted the Top 10 diagnoses (Cardiovascular diseases #1 at ~2.65M) using a Common Table Expression (CTE) and `DENSE_RANK() OVER (ORDER BY SUM(...) DESC)`.
* **Demographic Cohort Segmentation:** Isolated geriatric (65+) and pediatric (<18) admission volumes using conditional `CASE WHEN` aggregation.
* **Query Script:** Available in [`sql/destatis_hospital_analysis.sql`](sql/destatis_hospital_analysis.sql).

## 🛠️ Technical Stack

* **Database & Querying:** PostgreSQL, pgAdmin 4, SQL (CTEs, Window Functions, DDL)
* **Business Intelligence:** Microsoft Power BI Desktop
* **ETL & Data Transformation:** Power Query (M Language)
* **Calculations & Metrics:** Data Analysis Expressions (DAX)
* **Data Modeling:** Star-Schema Dimensional Design
* **Version Control:** Git, GitHub

