# 🏙️ Real Estate Automated Valuation Engine (MySQL & XGBoost)

An end-to-end data engineering and predictive analytics project that transitions a raw real estate transaction ledger into a validated, optimized machine learning pipeline. 

---

## 🛠️ Tech Stack & Architecture
* **Data Storage & Engineering:** MySQL (Workbench)
* **Statistical Analytics & Modeling:** Python 3 (Pandas, NumPy, Scikit-Learn, XGBoost)
* **Visualization Stack:** Seaborn, Matplotlib

---

## 🏗️ Technical Engineering Challenges & Solutions

### 1. Ingestion Protocol & Schema Architecture
* **Challenge:** Raw administrative data inputs failed standard streaming reads due to local environment file security overrides (`local_infile` flags) and character encoding mismatches (`charmap` codec faults).
* **Solution:** Bypassed file-system locks by configuring explicit client-side session parameters (`OPT_LOCAL_INFILE=1`) and establishing an open text-ingestion landing layer (`VARCHAR`).

### 2. Missing Value & Operational Data Leak Remediation
* **Challenge:** Multi-step structural audits exposed unmapped geographical information hidden as text leaks (`'Tenant'`) and blank string markers (`''`), which would have broken neighborhood aggregation models.
* **Solution:** Programmatically isolated and updated **23 hidden vacant entries** into a unified, clean categorical placeholder (`'Unknown'`) to preserve core property value dimensions.

### 3. Out-Of-Bounds Purging & Structural Logic Constraints
* **Challenge:** Identified single-row structural anomalies (a 630 sqm property claiming 0 rooms, 0 parking spots, and 0 elevators) skewing raw dataset averages.
* **Solution:** Executed strict threshold queries to remove impossible layout combinations. Later, implemented a localized **Room-to-Area logic check** using Python to ensure room distributions matched realistic property dimensions.

### 4. Mathematical Data Trimming & Sample Size Decay
* **Challenge:** After removing 208 row-level duplicates and applying global Interquartile Range (IQR) boundary cuts on outliers, certain neighborhood categories experienced sample size decay, falling to 1-2 properties and introducing statistical noise.
* **Solution:** Engineered a post-outlier grouping pipeline using a `.groupby()` filter that verified ongoing sample density, dynamically purging any neighborhood that dropped below **8 active historical listings**.

---

## 📈 Machine Learning Analytics & Insights

### 1. Predictive Performance (XGBoost Regressor)
* **Test Dataset R² Score:** `0.8153` (The model accurately explains 84.17% of unseen real estate pricing variance).
* **Train Dataset R² Score:** `0.9913` (Exposes an overfitting gap where the boosting tree system memorized training rows closely, signaling hyperparameter tuning targets).
* **Error Margin:** Average prediction boundaries track within 10-15% of actual asset valuation vectors.

### 2. Feature Importance Hierarchy
* **Area (36.6%):** Dominant linear baseline price controller.
* **Parking (22.5%):** Non-linear value multiplier. While simple correlation was low, tree-splitting algorithms revealed that a dedicated parking structure acts as a major luxury differentiator when combined with specific locations.
* **Address (17.6%):** Strong localized geographic valuation anchor.
