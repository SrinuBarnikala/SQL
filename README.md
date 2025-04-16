# SQL Project Repository

## Overview

This repository contains a collection of SQL queries and scripts for data analysis and database operations. The project demonstrates various SQL techniques for data manipulation, aggregation, and reporting

## 🚀 Project 1: Sales Insights & Reporting


## Project Structure

```
project1/
├── EDA.sql                    # [Basic exploration of Data]
├── DataAnalytics.sql          # [Exploring advanced analytics]
├── customer_report.sql        # [Creating customer report view for further easy analysis]
├── product_report.sql         # [Creating product report view for further advanced analysis]
└── dataset/            # Contains all data files used in queries
    └── [dataset files]
```

### 🔍 Overview
This project is centered around understanding sales and customer behavior through SQL. It includes customer segmentation, product performance evaluation, year-over-year sales analysis, and creation of reporting views.

## 📊 Dataset

All datasets used for these queries are located inside the `datasets/` folder:
### Prerequisites

- SQL database system (MySQL, PostgreSQL, SQL Server, SQLite, etc.)
- Database client or query tool

## Key SQL Techniques Demonstrated

- Data filtering and sorting
- Joins (Inner, Left, Right, Full)
- Aggregation functions
- Subqueries
- Window functions
- CTES
- Views

Make sure to load them into your SQL database before running the scripts.

---
# Project 2: India General Elections 2024 Analysis

## 📌 Overview

This project presents an analytical deep dive into the **2024 Indian General Election results**. The aim is to understand voting patterns, party-wise performance, constituency-level statistics, and overall vote share across the nation. The analysis focuses on deriving insights from raw election data to reveal trends, dominance regions, and participation metrics.

## 📂 Dataset

- **Source**: Datasets provided in csv format.
- **Contents**:
  - Total votes casted whole .
  - Constituency wise analysis.
  - State wise analysis
  - Votes % of winning party
  - Classifying parties according to the alliance
  - Other key analysis

> Note: The dataset was cleaned, transformed, and loaded into MS SQL for structured querying and efficient analysis.

## 🛠️ Key Things Used in MS SQL

- **CTEs (Common Table Expressions)** for simplifying complex queries  
- **Window Functions** (`RANK()`, `ROW_NUMBER()`, `SUM() OVER(...)`) to perform ranking and aggregations  
- **JOINs** to combine constituency data with party and region information  
- **GROUP BY with aggregations** to calculate total vote share and turnout  
- **CASE WHEN** logic to categorize vote margins and winning parties  
- **Views** to create reusable summary tables for dashboards and reports

---



## 🛠️ Tech Stack

- SQL (ANSI SQL / T-SQL compatible)
- Microsoft SQL Server / PostgreSQL / MySQL
- Optional: Power BI / Tableau (for visualization on top of views)

---

## 📝 How to Run

1. Clone the repository.
2. Import the datasets into your SQL environment.
3. Execute the SQL scripts in the provided order.
4. Review the results and use them for analysis or dashboards.

---

## 💡 Future Enhancements

- Add stored procedures for dynamic segmentation
- Integrate with Power BI / Tableau dashboards
- Perform RFM (Recency, Frequency, Monetary) analysis

---

## 📬 Contact

Feel free to reach out if you'd like to collaborate or learn more:

- 📧 Email: srinubarnikala222@gmail.com


---

⭐️ If you found this project useful, consider giving it a star!

