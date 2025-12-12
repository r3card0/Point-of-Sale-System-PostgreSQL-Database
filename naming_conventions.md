# 📐 Naming Conventions - POS System Database

## Overview
This document defines the naming standards for all database objects in the POS System project. Consistent naming improves readability, maintainability, and team collaboration.

**Last Updated:** December 2024  
**Status:** Active  
**Applies To:** All SQL files in this project

---

## 🎯 Core Principles

1. **Consistency is King**: Follow these rules 100% of the time
2. **Readability First**: Names should be self-documenting
3. **Avoid Abbreviations**: Use `customer` not `cust`, unless industry standard (e.g., `id`, `url`)
4. **English Only**: All names in English for international compatibility
5. **Lowercase**: PostgreSQL convention, avoids quote hell

---

## 📊 Tables

### Rules
- **Format:** `plural_noun` in snake_case
- **Reasoning:** Tables contain multiple rows, plural is more intuitive
- **Examples:**
  ```sql
  customers          ✅
  products           ✅
  sale_items         ✅ (compound names use underscore)
  
  Customer           ❌ (PascalCase)
  customer           ❌ (singular)
  saleItems          ❌ (camelCase)
  sales_item         ❌ (inconsistent plural/singular mix)
  ```

### Special Cases
- **Junction Tables:** Combine both table names in alphabetical order
  ```sql
  -- If relating products and categories
  category_products  ✅ (alphabetical: c before p)
  product_categories ❌
  ```
- **Audit/Log Tables:** Add `_logs` or `_history` suffix
  ```sql
  inventory_logs     ✅
  price_history      ✅
  ```

---

## 🔑 Columns

### Rules
- **Format:** `snake_case` for all column names
- **Descriptive:** Name should indicate content
- **No table prefix:** Column names don't need table prefix (we know what table we're in)

### Primary Keys
- **Format:** `[table_singular]_id`
- **Type:** `SERIAL` or `BIGSERIAL`
- **Always:** Named explicitly as PRIMARY KEY
  ```sql
  -- In customers table
  customer_id SERIAL PRIMARY KEY    ✅
  
  id SERIAL PRIMARY KEY              ❌ (too generic)
  customers_id SERIAL PRIMARY KEY    ❌ (plural form)
  CustomerID INT PRIMARY KEY         ❌ (camelCase)
  ```

### Foreign Keys
- **Format:** Exact same name as the referenced primary key
- **Reasoning:** Makes relationships obvious
  ```sql
  -- In sales table
  customer_id INT                    ✅ (matches customers.customer_id)
  employee_id INT                    ✅ (matches employees.employee_id)
  
  customer INT                       ❌ (missing _id suffix)
  cust_id INT                        ❌ (abbreviation)
  fk_customer_id INT                 ❌ (don't prefix with fk_)
  ```

### Boolean Columns
- **Format:** Start with `is_`, `has_`, `can_`, or `should_`
  ```sql
  is_active BOOLEAN                  ✅
  has_discount BOOLEAN               ✅
  can_login BOOLEAN                  ✅
  
  active BOOLEAN                     ❌ (ambiguous)
  discounted BOOLEAN                 ❌ (past tense)
  ```

### Date/Time Columns
- **Format:** Use descriptive suffixes
  ```sql
  created_at TIMESTAMP               ✅
  updated_at TIMESTAMP               ✅
  deleted_at TIMESTAMP               ✅ (for soft deletes)
  sale_date DATE                     ✅
  hire_date DATE                     ✅
  
  created TIMESTAMP                  ❌ (missing _at)
  date DATE                          ❌ (too generic)
  timestamp TIMESTAMP                ❌ (reserved word)
  ```

### Monetary Columns
- **Format:** Use `_amount`, `_price`, or `_cost` suffix
- **Type:** Always `DECIMAL(10,2)` or appropriate precision
  ```sql
  total_amount DECIMAL(10,2)         ✅
  unit_price DECIMAL(10,2)           ✅
  product_cost DECIMAL(10,2)         ✅
  
  total DECIMAL(10,2)                ❌ (ambiguous)
  price FLOAT                        ❌ (NEVER use FLOAT for money!)
  ```

### Quantity/Count Columns
- **Format:** Use `_count` or `_quantity` suffix, or descriptive noun
  ```sql
  stock INT                          ✅ (clear in context)
  quantity INT                       ✅
  item_count INT                     ✅
  
  qty INT                            ❌ (abbreviation)
  num INT                            ❌ (too generic)
  ```

---

## 🔒 Constraints

### Primary Key Constraints
- **Format:** `pk_[table]`
  ```sql
  CONSTRAINT pk_customers PRIMARY KEY (customer_id)           ✅
  CONSTRAINT pk_sale_items PRIMARY KEY (item_id)              ✅
  
  -- Note: When using inline PRIMARY KEY, name is auto-generated
  -- Only use CONSTRAINT when creating separately or for composite keys
  ```

### Foreign Key Constraints
- **Format:** `fk_[table]_[referenced_table]`
  ```sql
  CONSTRAINT fk_sales_customers                               ✅
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
  
  CONSTRAINT fk_products_categories                           ✅
      FOREIGN KEY (category_id) REFERENCES categories(category_id)
  
  CONSTRAINT fk_customer                                      ❌ (missing table name)
  CONSTRAINT sales_customer_fk                                ❌ (wrong order)
  ```

### Unique Constraints
- **Format:** `uq_[table]_[column(s)]`
  ```sql
  CONSTRAINT uq_customers_email                               ✅
      UNIQUE (email)
  
  CONSTRAINT uq_products_sku                                  ✅
      UNIQUE (sku)
  
  CONSTRAINT uq_employees_email_phone                         ✅
      UNIQUE (email, phone)
  
  CONSTRAINT unique_email                                     ❌ (missing table name)
  ```

### Check Constraints
- **Format:** `chk_[table]_[column]_[rule_description]`
  ```sql
  CONSTRAINT chk_products_price_positive                      ✅
      CHECK (price > 0)
  
  CONSTRAINT chk_products_stock_non_negative                  ✅
      CHECK (stock >= 0)
  
  CONSTRAINT chk_sale_items_discount_valid                    ✅
      CHECK (discount_percent >= 0 AND discount_percent <= 100)
  
  CONSTRAINT chk_price                                        ❌ (missing table, too vague)
  CONSTRAINT check_price_positive                             ❌ (verbose prefix)
  ```

### Default Constraints
- **Format:** `df_[table]_[column]`
  ```sql
  -- Usually defined inline, but if named:
  CONSTRAINT df_customers_points                              ✅
      DEFAULT 0
  
  CONSTRAINT df_sales_status                                  ✅
      DEFAULT 'completed'
  ```

---

## 📇 Indexes

### Single Column Indexes
- **Format:** `idx_[table]_[column]`
  ```sql
  CREATE INDEX idx_products_category ON products(category_id);     ✅
  CREATE INDEX idx_sales_date ON sales(sale_date);                 ✅
  
  CREATE INDEX products_category_idx ON products(category_id);     ❌ (wrong order)
  CREATE INDEX idx_category ON products(category_id);              ❌ (missing table)
  ```

### Multi-Column (Composite) Indexes
- **Format:** `idx_[table]_[col1]_[col2]`
  ```sql
  CREATE INDEX idx_sale_items_sale_product                         ✅
      ON sale_items(sale_id, product_id);
  
  CREATE INDEX idx_sales_customer_date                             ✅
      ON sales(customer_id, sale_date);
  
  CREATE INDEX idx_sale_items ON sale_items(sale_id, product_id);  ❌ (not descriptive)
  ```

### Unique Indexes
- **Format:** Same as regular indexes with `idx_` prefix
- **Note:** Prefer UNIQUE constraints over unique indexes for clarity
  ```sql
  -- Prefer this:
  ALTER TABLE customers ADD CONSTRAINT uq_customers_email UNIQUE (email);  ✅
  
  -- Over this:
  CREATE UNIQUE INDEX idx_customers_email ON customers(email);             ⚠️ (works, but constraint is clearer)
  ```

### Partial Indexes
- **Format:** `idx_[table]_[column]_[condition]`
  ```sql
  CREATE INDEX idx_sales_pending                                   ✅
      ON sales(sale_date) 
      WHERE status = 'pending';
  
  CREATE INDEX idx_products_low_stock                              ✅
      ON products(stock) 
      WHERE stock <= min_stock;
  ```

---

## 👁️ Views

### Regular Views
- **Format:** `v_[descriptive_name]`
  ```sql
  CREATE VIEW v_customer_purchase_summary AS ...               ✅
  CREATE VIEW v_low_stock_products AS ...                      ✅
  CREATE VIEW v_monthly_sales AS ...                           ✅
  
  CREATE VIEW customer_summary AS ...                          ❌ (missing v_ prefix)
  CREATE VIEW vw_customers AS ...                              ❌ (use v_ not vw_)
  ```

### Materialized Views
- **Format:** `mv_[descriptive_name]`
  ```sql
  CREATE MATERIALIZED VIEW mv_monthly_revenue AS ...           ✅
  CREATE MATERIALIZED VIEW mv_top_products AS ...              ✅
  
  CREATE MATERIALIZED VIEW monthly_revenue AS ...              ❌ (missing mv_ prefix)
  CREATE MATERIALIZED VIEW mat_revenue AS ...                  ❌ (use mv_ not mat_)
  ```

---

## ⚡ Functions and Stored Procedures

### Functions
- **Format:** `fn_[action]_[object]` or `[verb]_[noun]`
  ```sql
  CREATE FUNCTION calculate_sale_total(...) RETURNS DECIMAL     ✅
  CREATE FUNCTION get_customer_points(...) RETURNS INT          ✅
  CREATE FUNCTION fn_validate_email(...) RETURNS BOOLEAN        ✅
  
  CREATE FUNCTION CustomerPoints(...) RETURNS INT               ❌ (PascalCase)
  CREATE FUNCTION calc_total(...) RETURNS DECIMAL               ❌ (abbreviation)
  ```

### Triggers
- **Format:** `trg_[table]_[event]_[action]`
  ```sql
  CREATE TRIGGER trg_products_after_sale                        ✅
      AFTER INSERT ON sale_items ...
  
  CREATE TRIGGER trg_sales_before_insert                        ✅
      BEFORE INSERT ON sales ...
  
  CREATE TRIGGER update_stock                                   ❌ (missing prefix and context)
  CREATE TRIGGER tr_products_update                             ❌ (use trg_ not tr_)
  ```

### Trigger Functions
- **Format:** `[action]_[context]` (no special prefix, used only by triggers)
  ```sql
  CREATE FUNCTION update_product_stock() RETURNS TRIGGER        ✅
  CREATE FUNCTION award_loyalty_points() RETURNS TRIGGER        ✅
  CREATE FUNCTION log_inventory_change() RETURNS TRIGGER        ✅
  ```

---

## 📋 Sequences

### Format
- **Format:** `seq_[table]_[column]`
- **Note:** Usually auto-created by SERIAL, but if manual:
  ```sql
  CREATE SEQUENCE seq_customers_customer_id;                    ✅
  CREATE SEQUENCE seq_custom_invoice_number;                    ✅
  
  CREATE SEQUENCE customer_seq;                                 ❌ (missing context)
  ```

---

## 🏷️ Reserved Words to Avoid

Never use these as table or column names (PostgreSQL reserved words):

```
user, order, group, table, select, insert, update, delete,
values, date, time, timestamp, year, month, day, interval,
primary, foreign, key, constraint, index, view, function,
trigger, sequence, schema, database, role, grant, revoke
```

If you must use a reserved word, use a suffix:
```sql
order_date     ✅ (instead of just "order")
user_name      ✅ (instead of just "user")
group_name     ✅ (instead of just "group")
```

---

## ✅ Quick Reference Table

| Object Type | Format | Example |
|-------------|--------|---------|
| Table | `plural_noun` | `customers`, `sale_items` |
| Column | `snake_case` | `first_name`, `total_amount` |
| Primary Key | `[table_singular]_id` | `customer_id`, `product_id` |
| Foreign Key | Same as referenced PK | `customer_id` references `customers(customer_id)` |
| PK Constraint | `pk_[table]` | `pk_customers` |
| FK Constraint | `fk_[table]_[ref_table]` | `fk_sales_customers` |
| Unique Constraint | `uq_[table]_[column]` | `uq_customers_email` |
| Check Constraint | `chk_[table]_[column]_[rule]` | `chk_products_price_positive` |
| Index | `idx_[table]_[column(s)]` | `idx_sales_date` |
| View | `v_[name]` | `v_customer_summary` |
| Materialized View | `mv_[name]` | `mv_monthly_sales` |
| Function | `[verb]_[noun]` | `calculate_total`, `get_customer` |
| Trigger | `trg_[table]_[event]_[action]` | `trg_products_after_sale` |

---

## 📚 Additional Guidelines

### Comments
Always add comments to complex objects:
```sql
COMMENT ON TABLE customers IS 
    'Stores customer information including contact details and loyalty points';

COMMENT ON COLUMN products.min_stock IS 
    'Minimum stock level that triggers reorder alert';
```

### Schema Prefixes
If using multiple schemas (not in this project), prefix is optional:
```sql
-- Within schema, no prefix needed
SELECT * FROM customers;

-- Cross-schema, use schema prefix
SELECT * FROM inventory.products;
```

### Case Sensitivity
PostgreSQL folds unquoted identifiers to lowercase:
```sql
CREATE TABLE Customers (...);  -- Becomes "customers"
SELECT * FROM CUSTOMERS;       -- Works (becomes "customers")
SELECT * FROM "Customers";     -- Error! Case-sensitive
```

**Rule:** Never use quotes unless absolutely necessary. Stick to lowercase.

---

## 🎓 Why These Conventions Matter

1. **Readability:** Anyone can understand your code instantly
2. **Maintainability:** Easy to modify and extend
3. **Team Collaboration:** No confusion in multi-developer teams
4. **Tool Compatibility:** ORMs and tools expect consistent naming
5. **Professionalism:** Shows attention to detail in your portfolio
6. **Debugging:** Descriptive names make errors easier to trace
7. **Documentation:** Names serve as inline documentation

---

## 📝 Enforcement

- All SQL files in this project MUST follow these conventions
- Code reviews should verify naming compliance
- Use linters/formatters when possible (e.g., SQLFluff)
- Update this document if conventions evolve

---

## 🔄 Revision History

| Version | Date | Author|Changes |
|-|-|-|-|
| 1.0 | 2025-12-04 | [Ricardo](https://r3card0.github.io/portfolio/) |Initial naming conventions established |

---

**Remember:** Consistency > Personal Preference

When in doubt, refer to this document. If a case isn't covered, follow the spirit of these conventions and add it here for future reference.

---

*This document is part of the POS System portfolio project and serves as the single source of truth for all naming decisions.*