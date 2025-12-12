# 🔒 Constraints Strategy - POS System Database

## Overview
This document defines all data validation rules (constraints) for the POS System database. It translates business rules from `BUSINESS_RULES.md` into technical SQL constraints.

**Last Updated:** 2025-12-04  
**Status:** Active  
**Version:** 1.0

**Dependencies:**
- **BUSINESS_RULES.md**: Source of business requirements (what to enforce)
- **NAMING_CONVENTIONS.md**: Standards for naming constraints (how to name them)

---

## 🎯 Constraint Philosophy

**"Garbage in, garbage out"** - We prevent bad data at the database level, not just in application code.

### Core Principles
1. **Database as Single Source of Truth**: Validation happens at DB level
2. **Fail Fast**: Reject invalid data immediately
3. **Self-Documenting**: Constraints explain business rules
4. **Defense in Depth**: App validates, DB enforces
5. **Explicit is Better**: State assumptions clearly (NOT NULL, CHECK, etc.)

---

## 📋 Constraint Types Used

| Type | Purpose | Example |
|------|---------|---------|
| NOT NULL | Field is required | `email VARCHAR(100) NOT NULL` |
| CHECK | Validate business rules | `CHECK (price > 0)` |
| UNIQUE | No duplicates allowed | `UNIQUE (email)` |
| DEFAULT | Automatic value if not provided | `DEFAULT 0` |
| PRIMARY KEY | Unique identifier (implies UNIQUE + NOT NULL) | `customer_id SERIAL PRIMARY KEY` |
| FOREIGN KEY | Relationship integrity | `REFERENCES customers(customer_id)` |

---

## 🔗 Traceability to Business Rules

Every constraint in this document implements one or more business rules from `BUSINESS_RULES.md`.

**Naming Convention:**
- **Constraint ID:** `CS-[TABLE]-[NUMBER]` (e.g., CS-CUST-001)
- **Business Rule ID:** `BR-[TABLE]-[NUMBER]` (e.g., BR-CUST-001)

**Mapping Format:**
```sql
-- CS-CUST-001: Implements BR-CUST-001, BR-CUST-002
-- Business Rule: Customer must have name; name cannot be empty
first_name VARCHAR(50) NOT NULL,
```

**Why Traceability Matters:**
1. **Auditing**: Verify all business rules are implemented
2. **Change Management**: Understand impact of rule changes
3. **Documentation**: Link technical implementation to business requirement
4. **Compliance**: Prove business policy enforcement

---

## 🗂️ Table-by-Table Constraints

---

### 1. 👥 CUSTOMERS

**Business Rules:**
- Every customer must have a name and contact method
- Email must be unique (one account per email)
- Loyalty points cannot be negative
- Customers start with 0 points by default

**Constraint ID Mapping:**
| Constraint ID | Implements Business Rule | Description |
|--------------|-------------------------|-------------|
| CS-CUST-001 | BR-CUST-001, BR-CUST-002 | Name is mandatory and non-empty |
| CS-CUST-002 | BR-CUST-003, BR-CUST-004 | Email is unique and properly formatted |
| CS-CUST-003 | BR-CUST-006 | Points cannot be negative |
| CS-CUST-004 | BR-CUST-007 | New customers start with 0 points |
| CS-CUST-005 | BR-CUST-005 | Phone is optional |

```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    
    -- CS-CUST-001: Implements BR-CUST-001, BR-CUST-002
    -- Business Rule: Customer must have name; name cannot be empty
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    
    -- CS-CUST-002: Implements BR-CUST-003, BR-CUST-004
    -- Business Rule: Email must be unique and properly formatted
    email VARCHAR(100) NOT NULL UNIQUE,
    
    -- CS-CUST-005: Implements BR-CUST-005
    -- Business Rule: Phone number is optional
    phone VARCHAR(15),
    
    address TEXT,
    
    -- CS-CUST-003: Implements BR-CUST-006
    -- Business Rule: Loyalty points cannot be negative
    -- CS-CUST-004: Implements BR-CUST-007
    -- Business Rule: New customers start with 0 points
    points INT NOT NULL DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints with BR traceability
    
    -- CS-CUST-001a: Enforces BR-CUST-002
    CONSTRAINT chk_customers_first_name_not_empty 
        CHECK (LENGTH(TRIM(first_name)) > 0),
    
    -- CS-CUST-001b: Enforces BR-CUST-002
    CONSTRAINT chk_customers_last_name_not_empty 
        CHECK (LENGTH(TRIM(last_name)) > 0),
    
    -- CS-CUST-002a: Enforces BR-CUST-004
    CONSTRAINT chk_customers_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `first_name NOT NULL` | Business requirement: must know customer name |
| `last_name NOT NULL` | Business requirement: must know customer name |
| `email UNIQUE` | One account per email address |
| `email NOT NULL` | Primary contact method |
| `phone` (nullable) | Optional: Some customers don't provide phone |
| `address` (nullable) | Optional: Not required for in-store purchases |
| `points >= 0` | Cannot have negative loyalty points |
| `points DEFAULT 0` | New customers start with zero points |
| `email format check` | Basic email validation |
| `name not empty` | Prevents whitespace-only names |

---

### 2. 👔 EMPLOYEES

**Business Rules:**
- Every employee must have name, email, position
- Email must be unique (one account per employee)
- Hire date cannot be in the future
- Salary must be positive
- Employees are active by default

```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_employees_first_name_not_empty 
        CHECK (LENGTH(TRIM(first_name)) > 0),
    
    CONSTRAINT chk_employees_last_name_not_empty 
        CHECK (LENGTH(TRIM(last_name)) > 0),
    
    CONSTRAINT chk_employees_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    CONSTRAINT chk_employees_position_not_empty 
        CHECK (LENGTH(TRIM(position)) > 0),
    
    CONSTRAINT chk_employees_hire_date_not_future 
        CHECK (hire_date <= CURRENT_DATE),
    
    CONSTRAINT chk_employees_salary_positive 
        CHECK (salary > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `salary > 0` | Employees must be paid (cannot be 0 or negative) |
| `hire_date <= CURRENT_DATE` | Cannot hire someone in the future |
| `is_active DEFAULT TRUE` | New employees start as active |
| `position NOT NULL` | Must know employee role |

---

### 3. 🏷️ CATEGORIES

**Business Rules:**
- Category name must be unique
- Name cannot be empty
- Description is optional

```sql
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_categories_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `name UNIQUE` | No duplicate category names |
| `description` (nullable) | Optional: Some categories don't need description |

---

### 4. 🏢 SUPPLIERS

**Business Rules:**
- Supplier name must be unique
- Must have contact name and email
- Phone is optional

```sql
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_suppliers_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_suppliers_contact_name_not_empty 
        CHECK (LENGTH(TRIM(contact_name)) > 0),
    
    CONSTRAINT chk_suppliers_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);
```

---

### 5. 📦 PRODUCTS

**Business Rules:**
- Product name and SKU must be unique
- Price and cost must be positive
- Price should be greater than cost (basic profit check)
- Stock cannot be negative
- Minimum stock level for reorder alerts

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    min_stock INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_products_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_products_sku_format 
        CHECK (sku ~ '^[A-Z0-9-]+$'),
    
    CONSTRAINT chk_products_price_positive 
        CHECK (price > 0),
    
    CONSTRAINT chk_products_cost_positive 
        CHECK (cost > 0),
    
    CONSTRAINT chk_products_price_greater_than_cost 
        CHECK (price > cost),
    
    CONSTRAINT chk_products_stock_non_negative 
        CHECK (stock >= 0),
    
    CONSTRAINT chk_products_min_stock_positive 
        CHECK (min_stock > 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_products_categories 
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_products_suppliers 
        FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `sku UNIQUE` | Each product has unique identifier |
| `price > cost` | Prevent selling at loss (business rule) |
| `stock >= 0` | Cannot have negative inventory |
| `ON DELETE RESTRICT` | Cannot delete category/supplier if products exist |
| `sku format` | Must be uppercase alphanumeric with hyphens |

**⚠️ Important Note:** The `price > cost` constraint is a business rule. In real scenarios, you might want to allow sales/clearance items below cost temporarily. Consider this in production.

---

### 6. 🛒 SALES

**Business Rules:**
- Every sale must have a customer and employee
- Sale date defaults to now but can be backdated (for manual entries)
- Amounts must be non-negative
- Total must equal subtotal + tax
- Payment method must be valid
- Status must be valid

```sql
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_sales_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sales_tax_non_negative 
        CHECK (tax >= 0),
    
    CONSTRAINT chk_sales_total_non_negative 
        CHECK (total_amount >= 0),
    
    CONSTRAINT chk_sales_total_equals_subtotal_plus_tax 
        CHECK (total_amount = subtotal + tax),
    
    CONSTRAINT chk_sales_payment_method_valid 
        CHECK (payment_method IN ('cash', 'card', 'transfer', 'other')),
    
    CONSTRAINT chk_sales_status_valid 
        CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
    
    CONSTRAINT chk_sales_date_not_future 
        CHECK (sale_date <= CURRENT_TIMESTAMP),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sales_customers 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_sales_employees 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `total = subtotal + tax` | Mathematical integrity |
| `payment_method IN (...)` | Only allow valid payment types |
| `status IN (...)` | Enumerated values for status |
| `ON DELETE RESTRICT` | Cannot delete customer/employee with sales history |
| `sale_date <= now` | Cannot record future sales |

---

### 7. 📝 SALE_ITEMS

**Business Rules:**
- Every item must belong to a sale and reference a product
- Quantity must be positive
- Unit price must be positive (snapshot of price at sale time)
- Discount must be between 0-100%
- Subtotal must be calculated correctly

```sql
CREATE TABLE sale_items (
    item_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- CHECK Constraints
    CONSTRAINT chk_sale_items_quantity_positive 
        CHECK (quantity > 0),
    
    CONSTRAINT chk_sale_items_unit_price_positive 
        CHECK (unit_price > 0),
    
    CONSTRAINT chk_sale_items_discount_valid 
        CHECK (discount_percent >= 0 AND discount_percent <= 100),
    
    CONSTRAINT chk_sale_items_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sale_items_subtotal_calculated 
        CHECK (subtotal = (quantity * unit_price * (1 - discount_percent / 100))),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sale_items_sales 
        FOREIGN KEY (sale_id) 
        REFERENCES sales(sale_id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_sale_items_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `unit_price` (not from products) | Price snapshot at sale time (products.price may change later) |
| `discount 0-100` | Percentage must be valid |
| `ON DELETE CASCADE` (sale) | If sale is deleted, delete its items |
| `ON DELETE RESTRICT` (product) | Cannot delete product with sales history |
| `subtotal calculation` | Ensures math is correct |

**💡 Design Decision:** We store `unit_price` instead of referencing `products.price` because product prices change over time. This preserves historical accuracy.

---

### 8. 📊 INVENTORY_LOGS

**Business Rules:**
- Every log must reference a product
- Must record what changed and why
- Timestamps are automatic

```sql
CREATE TABLE inventory_logs (
    log_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    quantity_change INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_inventory_logs_change_type_valid 
        CHECK (change_type IN ('sale', 'restock', 'adjustment', 'damage', 'return')),
    
    CONSTRAINT chk_inventory_logs_stock_calculation 
        CHECK (new_stock = previous_stock + quantity_change),
    
    CONSTRAINT chk_inventory_logs_previous_stock_non_negative 
        CHECK (previous_stock >= 0),
    
    CONSTRAINT chk_inventory_logs_new_stock_non_negative 
        CHECK (new_stock >= 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_inventory_logs_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `new_stock = previous + change` | Mathematical integrity for audit trail |
| `change_type IN (...)` | Only allow valid change types |
| `ON DELETE RESTRICT` | Cannot delete product with inventory history |
| `reason` (nullable) | Optional explanation for changes |

---

## 📊 Constraint Summary by Type

### NOT NULL Fields by Table

| Table | NOT NULL Fields | Optional Fields |
|-------|----------------|-----------------|
| customers | first_name, last_name, email, points, created_at | phone, address |
| employees | first_name, last_name, email, position, hire_date, salary, is_active | - |
| categories | name, created_at | description |
| suppliers | name, contact_name, email, created_at | phone, address |
| products | name, sku, category_id, supplier_id, price, cost, stock, min_stock | description |
| sales | customer_id, employee_id, sale_date, subtotal, total_amount, payment_method, status | - |
| sale_items | sale_id, product_id, quantity, unit_price, subtotal | - |
| inventory_logs | product_id, change_type, quantity_change, previous_stock, new_stock, created_at | reason |

### Foreign Key Actions

| From Table | To Table | ON DELETE Action | Reasoning |
|------------|----------|------------------|-----------|
| products → categories | categories | RESTRICT | Cannot delete category with products |
| products → suppliers | suppliers | RESTRICT | Cannot delete supplier with products |
| sales → customers | customers | RESTRICT | Preserve sales history |
| sales → employees | employees | RESTRICT | Preserve sales history |
| sale_items → sales | sales | CASCADE | Delete items when sale is deleted |
| sale_items → products | products | RESTRICT | Cannot delete product with sales |
| inventory_logs → products | products | RESTRICT | Cannot delete product with history |

**🔒 Security Note:** All RESTRICT policies prevent accidental data loss. In production, consider implementing soft deletes (is_deleted flag) instead of hard deletes.

---

## 🎯 Implementation Checklist

When creating tables, verify:

- [ ] All NOT NULL constraints defined
- [ ] All CHECK constraints have descriptive names
- [ ] All UNIQUE constraints identified
- [ ] All DEFAULT values specified
- [ ] All FOREIGN KEY relationships established
- [ ] ON DELETE actions explicitly stated
- [ ] Mathematical constraints validated (e.g., total = subtotal + tax)
- [ ] Enum values defined (status, payment_method, etc.)
- [ ] Date/time constraints prevent future dates where needed
- [ ] Email format validation included
- [ ] Numeric ranges validated (prices > 0, discounts 0-100, etc.)

---

## 🧪 Testing Strategy

For each constraint, we should test:

1. **Happy Path:** Valid data is accepted
2. **Boundary Values:** Edge cases (0, 100, NULL)
3. **Invalid Data:** Constraint violations are rejected
4. **Foreign Key Cascades:** ON DELETE behavior works correctly

Example test cases will be in `tests/test_constraints.sql`.

---

## 🔄 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-04 | [Your Name] | Initial constraints strategy |

---

## 📚 References

- PostgreSQL CHECK Constraints: https://www.postgresql.org/docs/current/ddl-constraints.html
- Naming Conventions: See NAMING_CONVENTIONS.md
- ER Diagram: See docs/ER_diagram.png

---

**Next Step:** Implement these constraints in `schema/01_tables.sql`),
    
    -- CS-CUST-003a: Enforces BR-CUST-006
    CONSTRAINT chk_customers_points_non_negative 
        CHECK (points >= 0),
    
    CONSTRAINT chk_customers_phone_format
        CHECK (phone IS NULL OR phone ~ '^[0-9+() -]{10,15}

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `first_name NOT NULL` | Business requirement: must know customer name |
| `last_name NOT NULL` | Business requirement: must know customer name |
| `email UNIQUE` | One account per email address |
| `email NOT NULL` | Primary contact method |
| `phone` (nullable) | Optional: Some customers don't provide phone |
| `address` (nullable) | Optional: Not required for in-store purchases |
| `points >= 0` | Cannot have negative loyalty points |
| `points DEFAULT 0` | New customers start with zero points |
| `email format check` | Basic email validation |
| `name not empty` | Prevents whitespace-only names |

---

### 2. 👔 EMPLOYEES

**Business Rules:**
- Every employee must have name, email, position
- Email must be unique (one account per employee)
- Hire date cannot be in the future
- Salary must be positive
- Employees are active by default

```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_employees_first_name_not_empty 
        CHECK (LENGTH(TRIM(first_name)) > 0),
    
    CONSTRAINT chk_employees_last_name_not_empty 
        CHECK (LENGTH(TRIM(last_name)) > 0),
    
    CONSTRAINT chk_employees_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    CONSTRAINT chk_employees_position_not_empty 
        CHECK (LENGTH(TRIM(position)) > 0),
    
    CONSTRAINT chk_employees_hire_date_not_future 
        CHECK (hire_date <= CURRENT_DATE),
    
    CONSTRAINT chk_employees_salary_positive 
        CHECK (salary > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `salary > 0` | Employees must be paid (cannot be 0 or negative) |
| `hire_date <= CURRENT_DATE` | Cannot hire someone in the future |
| `is_active DEFAULT TRUE` | New employees start as active |
| `position NOT NULL` | Must know employee role |

---

### 3. 🏷️ CATEGORIES

**Business Rules:**
- Category name must be unique
- Name cannot be empty
- Description is optional

```sql
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_categories_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `name UNIQUE` | No duplicate category names |
| `description` (nullable) | Optional: Some categories don't need description |

---

### 4. 🏢 SUPPLIERS

**Business Rules:**
- Supplier name must be unique
- Must have contact name and email
- Phone is optional

```sql
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_suppliers_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_suppliers_contact_name_not_empty 
        CHECK (LENGTH(TRIM(contact_name)) > 0),
    
    CONSTRAINT chk_suppliers_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);
```

---

### 5. 📦 PRODUCTS

**Business Rules:**
- Product name and SKU must be unique
- Price and cost must be positive
- Price should be greater than cost (basic profit check)
- Stock cannot be negative
- Minimum stock level for reorder alerts

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    min_stock INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_products_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_products_sku_format 
        CHECK (sku ~ '^[A-Z0-9-]+$'),
    
    CONSTRAINT chk_products_price_positive 
        CHECK (price > 0),
    
    CONSTRAINT chk_products_cost_positive 
        CHECK (cost > 0),
    
    CONSTRAINT chk_products_price_greater_than_cost 
        CHECK (price > cost),
    
    CONSTRAINT chk_products_stock_non_negative 
        CHECK (stock >= 0),
    
    CONSTRAINT chk_products_min_stock_positive 
        CHECK (min_stock > 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_products_categories 
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_products_suppliers 
        FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `sku UNIQUE` | Each product has unique identifier |
| `price > cost` | Prevent selling at loss (business rule) |
| `stock >= 0` | Cannot have negative inventory |
| `ON DELETE RESTRICT` | Cannot delete category/supplier if products exist |
| `sku format` | Must be uppercase alphanumeric with hyphens |

**⚠️ Important Note:** The `price > cost` constraint is a business rule. In real scenarios, you might want to allow sales/clearance items below cost temporarily. Consider this in production.

---

### 6. 🛒 SALES

**Business Rules:**
- Every sale must have a customer and employee
- Sale date defaults to now but can be backdated (for manual entries)
- Amounts must be non-negative
- Total must equal subtotal + tax
- Payment method must be valid
- Status must be valid

```sql
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_sales_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sales_tax_non_negative 
        CHECK (tax >= 0),
    
    CONSTRAINT chk_sales_total_non_negative 
        CHECK (total_amount >= 0),
    
    CONSTRAINT chk_sales_total_equals_subtotal_plus_tax 
        CHECK (total_amount = subtotal + tax),
    
    CONSTRAINT chk_sales_payment_method_valid 
        CHECK (payment_method IN ('cash', 'card', 'transfer', 'other')),
    
    CONSTRAINT chk_sales_status_valid 
        CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
    
    CONSTRAINT chk_sales_date_not_future 
        CHECK (sale_date <= CURRENT_TIMESTAMP),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sales_customers 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_sales_employees 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `total = subtotal + tax` | Mathematical integrity |
| `payment_method IN (...)` | Only allow valid payment types |
| `status IN (...)` | Enumerated values for status |
| `ON DELETE RESTRICT` | Cannot delete customer/employee with sales history |
| `sale_date <= now` | Cannot record future sales |

---

### 7. 📝 SALE_ITEMS

**Business Rules:**
- Every item must belong to a sale and reference a product
- Quantity must be positive
- Unit price must be positive (snapshot of price at sale time)
- Discount must be between 0-100%
- Subtotal must be calculated correctly

```sql
CREATE TABLE sale_items (
    item_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- CHECK Constraints
    CONSTRAINT chk_sale_items_quantity_positive 
        CHECK (quantity > 0),
    
    CONSTRAINT chk_sale_items_unit_price_positive 
        CHECK (unit_price > 0),
    
    CONSTRAINT chk_sale_items_discount_valid 
        CHECK (discount_percent >= 0 AND discount_percent <= 100),
    
    CONSTRAINT chk_sale_items_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sale_items_subtotal_calculated 
        CHECK (subtotal = (quantity * unit_price * (1 - discount_percent / 100))),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sale_items_sales 
        FOREIGN KEY (sale_id) 
        REFERENCES sales(sale_id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_sale_items_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `unit_price` (not from products) | Price snapshot at sale time (products.price may change later) |
| `discount 0-100` | Percentage must be valid |
| `ON DELETE CASCADE` (sale) | If sale is deleted, delete its items |
| `ON DELETE RESTRICT` (product) | Cannot delete product with sales history |
| `subtotal calculation` | Ensures math is correct |

**💡 Design Decision:** We store `unit_price` instead of referencing `products.price` because product prices change over time. This preserves historical accuracy.

---

### 8. 📊 INVENTORY_LOGS

**Business Rules:**
- Every log must reference a product
- Must record what changed and why
- Timestamps are automatic

```sql
CREATE TABLE inventory_logs (
    log_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    quantity_change INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_inventory_logs_change_type_valid 
        CHECK (change_type IN ('sale', 'restock', 'adjustment', 'damage', 'return')),
    
    CONSTRAINT chk_inventory_logs_stock_calculation 
        CHECK (new_stock = previous_stock + quantity_change),
    
    CONSTRAINT chk_inventory_logs_previous_stock_non_negative 
        CHECK (previous_stock >= 0),
    
    CONSTRAINT chk_inventory_logs_new_stock_non_negative 
        CHECK (new_stock >= 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_inventory_logs_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `new_stock = previous + change` | Mathematical integrity for audit trail |
| `change_type IN (...)` | Only allow valid change types |
| `ON DELETE RESTRICT` | Cannot delete product with inventory history |
| `reason` (nullable) | Optional explanation for changes |

---

## 📊 Constraint Summary by Type

### NOT NULL Fields by Table

| Table | NOT NULL Fields | Optional Fields |
|-------|----------------|-----------------|
| customers | first_name, last_name, email, points, created_at | phone, address |
| employees | first_name, last_name, email, position, hire_date, salary, is_active | - |
| categories | name, created_at | description |
| suppliers | name, contact_name, email, created_at | phone, address |
| products | name, sku, category_id, supplier_id, price, cost, stock, min_stock | description |
| sales | customer_id, employee_id, sale_date, subtotal, total_amount, payment_method, status | - |
| sale_items | sale_id, product_id, quantity, unit_price, subtotal | - |
| inventory_logs | product_id, change_type, quantity_change, previous_stock, new_stock, created_at | reason |

### Foreign Key Actions

| From Table | To Table | ON DELETE Action | Reasoning |
|------------|----------|------------------|-----------|
| products → categories | categories | RESTRICT | Cannot delete category with products |
| products → suppliers | suppliers | RESTRICT | Cannot delete supplier with products |
| sales → customers | customers | RESTRICT | Preserve sales history |
| sales → employees | employees | RESTRICT | Preserve sales history |
| sale_items → sales | sales | CASCADE | Delete items when sale is deleted |
| sale_items → products | products | RESTRICT | Cannot delete product with sales |
| inventory_logs → products | products | RESTRICT | Cannot delete product with history |

**🔒 Security Note:** All RESTRICT policies prevent accidental data loss. In production, consider implementing soft deletes (is_deleted flag) instead of hard deletes.

---

## 🎯 Implementation Checklist

When creating tables, verify:

- [ ] All NOT NULL constraints defined
- [ ] All CHECK constraints have descriptive names
- [ ] All UNIQUE constraints identified
- [ ] All DEFAULT values specified
- [ ] All FOREIGN KEY relationships established
- [ ] ON DELETE actions explicitly stated
- [ ] Mathematical constraints validated (e.g., total = subtotal + tax)
- [ ] Enum values defined (status, payment_method, etc.)
- [ ] Date/time constraints prevent future dates where needed
- [ ] Email format validation included
- [ ] Numeric ranges validated (prices > 0, discounts 0-100, etc.)

---

## 🧪 Testing Strategy

For each constraint, we should test:

1. **Happy Path:** Valid data is accepted
2. **Boundary Values:** Edge cases (0, 100, NULL)
3. **Invalid Data:** Constraint violations are rejected
4. **Foreign Key Cascades:** ON DELETE behavior works correctly

Example test cases will be in `tests/test_constraints.sql`.

---

## 🔄 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-04 | [Your Name] | Initial constraints strategy |

---

## 📚 References

- PostgreSQL CHECK Constraints: https://www.postgresql.org/docs/current/ddl-constraints.html
- Naming Conventions: See NAMING_CONVENTIONS.md
- ER Diagram: See docs/ER_diagram.png

---

**Next Step:** Implement these constraints in `schema/01_tables.sql`)
);

COMMENT ON TABLE customers IS 'Stores customer information - Implements BR-CUST-* rules';
COMMENT ON COLUMN customers.first_name IS 'Implements BR-CUST-001: Customer must have first name';
COMMENT ON COLUMN customers.email IS 'Implements BR-CUST-003: Email must be unique identifier';
COMMENT ON COLUMN customers.points IS 'Implements BR-CUST-006, BR-CUST-007: Loyalty points system';
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `first_name NOT NULL` | Business requirement: must know customer name |
| `last_name NOT NULL` | Business requirement: must know customer name |
| `email UNIQUE` | One account per email address |
| `email NOT NULL` | Primary contact method |
| `phone` (nullable) | Optional: Some customers don't provide phone |
| `address` (nullable) | Optional: Not required for in-store purchases |
| `points >= 0` | Cannot have negative loyalty points |
| `points DEFAULT 0` | New customers start with zero points |
| `email format check` | Basic email validation |
| `name not empty` | Prevents whitespace-only names |

---

### 2. 👔 EMPLOYEES

**Business Rules:**
- Every employee must have name, email, position
- Email must be unique (one account per employee)
- Hire date cannot be in the future
- Salary must be positive
- Employees are active by default

```sql
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_employees_first_name_not_empty 
        CHECK (LENGTH(TRIM(first_name)) > 0),
    
    CONSTRAINT chk_employees_last_name_not_empty 
        CHECK (LENGTH(TRIM(last_name)) > 0),
    
    CONSTRAINT chk_employees_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    CONSTRAINT chk_employees_position_not_empty 
        CHECK (LENGTH(TRIM(position)) > 0),
    
    CONSTRAINT chk_employees_hire_date_not_future 
        CHECK (hire_date <= CURRENT_DATE),
    
    CONSTRAINT chk_employees_salary_positive 
        CHECK (salary > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `salary > 0` | Employees must be paid (cannot be 0 or negative) |
| `hire_date <= CURRENT_DATE` | Cannot hire someone in the future |
| `is_active DEFAULT TRUE` | New employees start as active |
| `position NOT NULL` | Must know employee role |

---

### 3. 🏷️ CATEGORIES

**Business Rules:**
- Category name must be unique
- Name cannot be empty
- Description is optional

```sql
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_categories_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0)
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `name UNIQUE` | No duplicate category names |
| `description` (nullable) | Optional: Some categories don't need description |

---

### 4. 🏢 SUPPLIERS

**Business Rules:**
- Supplier name must be unique
- Must have contact name and email
- Phone is optional

```sql
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_suppliers_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_suppliers_contact_name_not_empty 
        CHECK (LENGTH(TRIM(contact_name)) > 0),
    
    CONSTRAINT chk_suppliers_email_format 
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);
```

---

### 5. 📦 PRODUCTS

**Business Rules:**
- Product name and SKU must be unique
- Price and cost must be positive
- Price should be greater than cost (basic profit check)
- Stock cannot be negative
- Minimum stock level for reorder alerts

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    min_stock INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_products_name_not_empty 
        CHECK (LENGTH(TRIM(name)) > 0),
    
    CONSTRAINT chk_products_sku_format 
        CHECK (sku ~ '^[A-Z0-9-]+$'),
    
    CONSTRAINT chk_products_price_positive 
        CHECK (price > 0),
    
    CONSTRAINT chk_products_cost_positive 
        CHECK (cost > 0),
    
    CONSTRAINT chk_products_price_greater_than_cost 
        CHECK (price > cost),
    
    CONSTRAINT chk_products_stock_non_negative 
        CHECK (stock >= 0),
    
    CONSTRAINT chk_products_min_stock_positive 
        CHECK (min_stock > 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_products_categories 
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_products_suppliers 
        FOREIGN KEY (supplier_id) 
        REFERENCES suppliers(supplier_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `sku UNIQUE` | Each product has unique identifier |
| `price > cost` | Prevent selling at loss (business rule) |
| `stock >= 0` | Cannot have negative inventory |
| `ON DELETE RESTRICT` | Cannot delete category/supplier if products exist |
| `sku format` | Must be uppercase alphanumeric with hyphens |

**⚠️ Important Note:** The `price > cost` constraint is a business rule. In real scenarios, you might want to allow sales/clearance items below cost temporarily. Consider this in production.

---

### 6. 🛒 SALES

**Business Rules:**
- Every sale must have a customer and employee
- Sale date defaults to now but can be backdated (for manual entries)
- Amounts must be non-negative
- Total must equal subtotal + tax
- Payment method must be valid
- Status must be valid

```sql
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_sales_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sales_tax_non_negative 
        CHECK (tax >= 0),
    
    CONSTRAINT chk_sales_total_non_negative 
        CHECK (total_amount >= 0),
    
    CONSTRAINT chk_sales_total_equals_subtotal_plus_tax 
        CHECK (total_amount = subtotal + tax),
    
    CONSTRAINT chk_sales_payment_method_valid 
        CHECK (payment_method IN ('cash', 'card', 'transfer', 'other')),
    
    CONSTRAINT chk_sales_status_valid 
        CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
    
    CONSTRAINT chk_sales_date_not_future 
        CHECK (sale_date <= CURRENT_TIMESTAMP),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sales_customers 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_sales_employees 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `total = subtotal + tax` | Mathematical integrity |
| `payment_method IN (...)` | Only allow valid payment types |
| `status IN (...)` | Enumerated values for status |
| `ON DELETE RESTRICT` | Cannot delete customer/employee with sales history |
| `sale_date <= now` | Cannot record future sales |

---

### 7. 📝 SALE_ITEMS

**Business Rules:**
- Every item must belong to a sale and reference a product
- Quantity must be positive
- Unit price must be positive (snapshot of price at sale time)
- Discount must be between 0-100%
- Subtotal must be calculated correctly

```sql
CREATE TABLE sale_items (
    item_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- CHECK Constraints
    CONSTRAINT chk_sale_items_quantity_positive 
        CHECK (quantity > 0),
    
    CONSTRAINT chk_sale_items_unit_price_positive 
        CHECK (unit_price > 0),
    
    CONSTRAINT chk_sale_items_discount_valid 
        CHECK (discount_percent >= 0 AND discount_percent <= 100),
    
    CONSTRAINT chk_sale_items_subtotal_non_negative 
        CHECK (subtotal >= 0),
    
    CONSTRAINT chk_sale_items_subtotal_calculated 
        CHECK (subtotal = (quantity * unit_price * (1 - discount_percent / 100))),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_sale_items_sales 
        FOREIGN KEY (sale_id) 
        REFERENCES sales(sale_id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_sale_items_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `unit_price` (not from products) | Price snapshot at sale time (products.price may change later) |
| `discount 0-100` | Percentage must be valid |
| `ON DELETE CASCADE` (sale) | If sale is deleted, delete its items |
| `ON DELETE RESTRICT` (product) | Cannot delete product with sales history |
| `subtotal calculation` | Ensures math is correct |

**💡 Design Decision:** We store `unit_price` instead of referencing `products.price` because product prices change over time. This preserves historical accuracy.

---

### 8. 📊 INVENTORY_LOGS

**Business Rules:**
- Every log must reference a product
- Must record what changed and why
- Timestamps are automatic

```sql
CREATE TABLE inventory_logs (
    log_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    quantity_change INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- CHECK Constraints
    CONSTRAINT chk_inventory_logs_change_type_valid 
        CHECK (change_type IN ('sale', 'restock', 'adjustment', 'damage', 'return')),
    
    CONSTRAINT chk_inventory_logs_stock_calculation 
        CHECK (new_stock = previous_stock + quantity_change),
    
    CONSTRAINT chk_inventory_logs_previous_stock_non_negative 
        CHECK (previous_stock >= 0),
    
    CONSTRAINT chk_inventory_logs_new_stock_non_negative 
        CHECK (new_stock >= 0),
    
    -- FOREIGN KEY Constraints
    CONSTRAINT fk_inventory_logs_products 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Constraint Rationale:**

| Constraint | Reasoning |
|------------|-----------|
| `new_stock = previous + change` | Mathematical integrity for audit trail |
| `change_type IN (...)` | Only allow valid change types |
| `ON DELETE RESTRICT` | Cannot delete product with inventory history |
| `reason` (nullable) | Optional explanation for changes |

---

## 📊 Constraint Summary by Type

### NOT NULL Fields by Table

| Table | NOT NULL Fields | Optional Fields |
|-------|----------------|-----------------|
| customers | first_name, last_name, email, points, created_at | phone, address |
| employees | first_name, last_name, email, position, hire_date, salary, is_active | - |
| categories | name, created_at | description |
| suppliers | name, contact_name, email, created_at | phone, address |
| products | name, sku, category_id, supplier_id, price, cost, stock, min_stock | description |
| sales | customer_id, employee_id, sale_date, subtotal, total_amount, payment_method, status | - |
| sale_items | sale_id, product_id, quantity, unit_price, subtotal | - |
| inventory_logs | product_id, change_type, quantity_change, previous_stock, new_stock, created_at | reason |

### Foreign Key Actions

| From Table | To Table | ON DELETE Action | Reasoning |
|------------|----------|------------------|-----------|
| products → categories | categories | RESTRICT | Cannot delete category with products |
| products → suppliers | suppliers | RESTRICT | Cannot delete supplier with products |
| sales → customers | customers | RESTRICT | Preserve sales history |
| sales → employees | employees | RESTRICT | Preserve sales history |
| sale_items → sales | sales | CASCADE | Delete items when sale is deleted |
| sale_items → products | products | RESTRICT | Cannot delete product with sales |
| inventory_logs → products | products | RESTRICT | Cannot delete product with history |

**🔒 Security Note:** All RESTRICT policies prevent accidental data loss. In production, consider implementing soft deletes (is_deleted flag) instead of hard deletes.

---

## 🎯 Implementation Checklist

When creating tables, verify:

- [ ] All NOT NULL constraints defined
- [ ] All CHECK constraints have descriptive names
- [ ] All UNIQUE constraints identified
- [ ] All DEFAULT values specified
- [ ] All FOREIGN KEY relationships established
- [ ] ON DELETE actions explicitly stated
- [ ] Mathematical constraints validated (e.g., total = subtotal + tax)
- [ ] Enum values defined (status, payment_method, etc.)
- [ ] Date/time constraints prevent future dates where needed
- [ ] Email format validation included
- [ ] Numeric ranges validated (prices > 0, discounts 0-100, etc.)

---

## 🧪 Testing Strategy

For each constraint, we should test:

1. **Happy Path:** Valid data is accepted
2. **Boundary Values:** Edge cases (0, 100, NULL)
3. **Invalid Data:** Constraint violations are rejected
4. **Foreign Key Cascades:** ON DELETE behavior works correctly

Example test cases will be in `tests/test_constraints.sql`.

---

## 🔄 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-04 | [Your Name] | Initial constraints strategy |

---

## 📚 References

- PostgreSQL CHECK Constraints: https://www.postgresql.org/docs/current/ddl-constraints.html
- Naming Conventions: See NAMING_CONVENTIONS.md
- ER Diagram: See docs/ER_diagram.png

---

**Next Step:** Implement these constraints in `schema/01_tables.sql`