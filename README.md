# 🛒  Point of Sale (POS) System - PostgreSQL

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

**Status: In Progress**



A comprehensive PostgreSQL database design for a modern retail Point of Sale system, featuring advanced SQL techniques including triggers, stored procedures, materielized views, and strategic indexing.

## Table of Contents

* [Overview](#-overview)
* [Business Requirements](#--business-requirements)
* [Database Schema](#️-database-schema)
* [Key Features](#-key-features)
* [Technical Highlights](#-technical-highlights)
* [Installation](#-installation)
* [Sample Queries](#sample-queries)
* [Performance Optimization](#-performance-optimization)
* [Contributing](#-contributing)

## 🎯 Overview

This project demonstrates a production-ready database design for retail POS system. If showcases best practices in:

* **Data Modeling**: Normalized schema design (3NF) with proper relationships
* **Business Logic**: Triggers and stored procedures for automates operations
* **Performance**: Strategic indexing and materialized views for reporting
* **Data Integrity**: Comprehensive constraints and validation rules
* **Audit Trail**: Complete transaction history and inventory tracking

## 💼  Business requirements

The system supports the following business operations:

**Core Functionality**

* ✅ Product catalog management with categories and suppliers
* ✅ Customer information and loyalty tracking
* ✅ Sales transactions with multiple payment methods
* ✅ Real-Time inventory management
* ✅ Employee access and sales tracking
* ✅ Discount and promotion handling
* ✅ Tax calculation automation

**Reporting Capabilities**

* Daily, monthly, and yearly sales reports
* Top-selling products and categories
* Customer pruchase history and preferences
* Low stock alerts and reorder recommendations
* Revenue analysis by employee, category, and time period

## 🗄️ Database Schema

**Entity Relationship Diagram**

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Customers  │         │    Sales     │         │  Employees  │
├─────────────┤         ├──────────────┤         ├─────────────┤
│ customer_id │◄───────►│ sale_id      │◄───────►│ employee_id │
│ first_name  │         │ customer_id  │         │ first_name  │
│ last_name   │         │ employee_id  │         │ last_name   │
│ email       │         │ sale_date    │         │ position    │
│ phone       │         │ total_amount │         │ hire_date   │
│ points      │         │ payment_type │         └─────────────┘
└─────────────┘         └──────┬───────┘
                               │
                               │
                        ┌──────▼───────┐
                        │ Sale_Items   │
                        ├──────────────┤
                        │ item_id      │
                        │ sale_id      │◄────┐
                        │ product_id   │     │
                        │ quantity     │     │
                        │ unit_price   │     │
                        │ discount     │     │
                        └──────────────┘     │
                                             │
┌─────────────┐         ┌──────────────┐    │
│  Suppliers  │         │   Products   │    │
├─────────────┤         ├──────────────┤    │
│ supplier_id │◄───────►│ product_id   │────┘
│ name        │         │ name         │
│ contact     │         │ category_id  │
│ email       │         │ supplier_id  │
└─────────────┘         │ price        │
                        │ stock        │
                        │ min_stock    │
                        └──────┬───────┘
                               │
                        ┌──────▼───────┐
                        │  Categories  │
                        ├──────────────┤
                        │ category_id  │
                        │ name         │
                        │ description  │
                        └──────────────┘
```

**Core Tables**

|Table|Purpose|Key Feature|
|-|-|-|
|customers|Store customer information|Loyalty point, purchase history|
|employees|Manage staff access|Role-based permissions, sales tracking|
|suppliers|Track product suppliers|Contact info, product relationship|
|categories|Organize products|Hierachical categorization|
|products|Product catalog|Pricing, inventory levels, min stock alerts|
|sales|Transaction records|Payment methods, timestamps, totals|
|sale_items|Line items pers sale|Quatities, discounts, pricing snapshot|
|inventory_logs|Audit trail|Stock movements, reasons, timestamps|

## ⚡ Key Features

1. Automated Inventory Management
```sql
-- Trigger: Automatically update stock when a sale is made
-- Prevents overselling and maintains accurate inventory
CREATE TRIGGER trg_update_stock_after_sale
AFTER INSERT ON sale_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();
```

2. Sales Total Calculation

```sql
-- Stored Procedure: Calculate sale total with taxes and discounts
-- Ensures consistent pricing logic across the application
CREATE OR REPLACE FUNCTION calculate_sale_total(sale_id_param INT)
RETURNS DECIMAL(10,2);
```

3. Low Stock Alerts

```sql
-- View: Products below minimum stock level
-- Enables proactive inventory replenishment
CREATE VIEW low_stock_products AS
SELECT product_id, name, stock, min_stock
FROM products
WHERE stock <= min_stock;
```


4. Customer Loyalty System

```sql
-- Trigger: Award points based on purchase amount
-- 1 point per $10 spent
CREATE TRIGGER trg_award_loyalty_points
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION award_customer_points();
```


## 🔧 Technical Highlights

**Performance Optimization**

Strategic Indexes

**Materialized Views Reporting**

**Data Integrity**

Check Constraints

**Foreign Key Cascades**

## 🚀 Installation

**Prerequisites**
* PostgreSQL 12 or higher
* psql command-line tool or pgAdmin

**Setup Steps**

1. Clone the repository
2. Create the database
3. Run the schema scripts
4. Load sample data
5. Verify installation

## Sample Queries

**Top 10 Best-Selling Products**

**Customer Purchase History**

**Daily Sales Report with Running Total**

**Inventory Value by Category**

## 🎯 Performance Optimization

**Query Optimization Examples

Before Optimization (slow)

After Optimization (Fast)

**EXPLAIN ANALYZE Results**

### 📚 Learning Resources

This project demonstrates the following SQL concpets:

* **Normalization**: 3NF schema design
* **Transaction**: ACID properties
* **Triggers**: Automated busines logic
* **Stored Procedures**: Reusable functions
* **Indexes**: B-tree and composite indexes
* **Views**: Regular and materialized views
* **Window Functions**:Analytics and rankings
* **CTEs**: Common Table Expressions
* **Constraints**: Data Validation and integrity

## 🤝 Contributing 

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

* GitHub: @r3card0
* LinkedIn: [Ricardo](https://www.linkedin.com/in/ricardordzsaldivar/)