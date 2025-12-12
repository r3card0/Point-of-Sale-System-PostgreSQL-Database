# 📜 Business Rules Document - POS System

## Document Information

| Field | Value |
|-------|-------|
| **Project Name** | Point of Sale (POS) System |
| **Document Version** | 1.0 |
| **Date Created** | 2025-12-04 |
| **Last Updated** | 2025-12-04 |
| **Author** | [Your Name] |
| **Status** | Active |
| **Review Date** | 2026-01-04 |

---

## 📋 Table of Contents

- [Purpose](#purpose)
- [Scope](#scope)
- [Business Context](#business-context)
- [Rule Categories](#rule-categories)
- [Field-Specific Rules](#field-specific-rules)
- [Relationship Rules](#relationship-rules)
- [Business Process Rules](#business-process-rules)
- [Calculation Rules](#calculation-rules)
- [Security & Access Rules](#security--access-rules)
- [Rule Traceability Matrix](#rule-traceability-matrix)
- [Approval & Sign-off](#approval--sign-off)

---

## 🎯 Purpose

Business rules describe the policies, constraints, and operational guidelines that govern how an organization manages its data. This document captures all business rules for the POS System database in plain language, before technical implementation.

**Key Objectives:**
- Define what data can be stored and how
- Establish constraints needed to maintain accuracy and integrity
- Document business policies that must be enforced by the database
- Provide a single source of truth for stakeholders

---

## 🔍 Scope

This document covers business rules for:
- ✅ Data validation and integrity
- ✅ Business process constraints
- ✅ Relationship constraints between entities
- ✅ Calculation and derivation rules
- ✅ Security and access policies

**Out of Scope:**
- ❌ User interface design
- ❌ Application business logic (handled outside database)
- ❌ Integration with external systems
- ❌ Performance optimization strategies

---

## 🏢 Business Context

### Organization Profile
- **Business Type:** Retail store with physical location
- **Size:** Small to medium business
- **Daily Transactions:** 50-200 sales per day
- **Product Catalog:** 500-2000 products
- **Customer Base:** Walk-in and registered customers

### Key Stakeholders
- **Store Manager:** Oversees operations, reviews reports
- **Cashiers:** Process sales, handle customer transactions
- **Inventory Manager:** Manages stock levels, orders products
- **Accountant:** Reviews financial reports, audits sales
- **IT Administrator:** Maintains system, manages users

---

## 📂 Rule Categories

Business rules can be categorized into field-specific rules and relationship-specific rules. We extend this to include:

| Category | Description | Example |
|----------|-------------|---------|
| **Mandatory Data** | Fields that must have a value | Customer must have email |
| **Data Format** | Structure/pattern requirements | Email must contain @ symbol |
| **Range/Domain** | Valid values or ranges | Discount: 0-100% |
| **Uniqueness** | No duplicate values allowed | Email must be unique |
| **Referential Integrity** | Relationships between entities | Sale must reference valid customer |
| **Calculation** | How values are computed | Total = Subtotal + Tax |
| **Business Logic** | Process-driven rules | Points earned per dollar spent |
| **Security** | Access and permission rules | Only managers can void sales |

---

## 📝 Field-Specific Rules

### Rule Template Format

```
BR-[TABLE]-[NUMBER]: [Rule Statement]
│
├─ Category: [Type of rule]
├─ Affected Entity: [Table name]
├─ Affected Field(s): [Column names]
├─ Business Justification: [Why this rule exists]
├─ Enforcement Level: Database / Application / Both
├─ Implementation: [Reference to Constraints Strategy]
└─ Maps to: CS-[TABLE]-[NUMBER]
```

**Example:**
```
BR-CUST-001: Customer Must Have Name
├─ Category: Mandatory Data
├─ Affected Fields: first_name, last_name
├─ Business Justification: Required for identification
├─ Enforcement: Database (NOT NULL)
└─ Maps to: CS-CUST-001
```

---

### 👥 CUSTOMERS Rules

#### BR-CUST-001: Customer Must Have Name
- **Rule Statement:** Every customer must provide both first name and last name
- **Category:** Mandatory Data
- **Affected Fields:** `first_name`, `last_name`
- **Business Justification:** Required for identification and communication
- **Enforcement:** Database (NOT NULL constraint)
- **Maps to:** CS-CUST-001
- **Test Case:** Try to create customer without name → Should fail

#### BR-CUST-002: Name Cannot Be Empty
- **Rule Statement:** Customer names must contain at least one non-whitespace character
- **Category:** Data Format
- **Affected Fields:** `first_name`, `last_name`
- **Business Justification:** Prevents accidental empty entries (spaces only)
- **Enforcement:** Database (CHECK constraint)
- **Maps to:** CS-CUST-001a, CS-CUST-001b
- **Test Case:** Try to insert "   " (spaces) as name → Should fail

#### BR-CUST-003: Email Must Be Unique
- **Rule Statement:** No two customers can have the same email address
- **Category:** Uniqueness
- **Affected Fields:** `email`
- **Business Justification:** Email is primary identifier for customer account
- **Enforcement:** Database (UNIQUE constraint)
- **Maps to:** CS-CUST-002
- **Test Case:** Try to register second customer with existing email → Should fail

#### BR-CUST-004: Email Format Validation
- **Rule Statement:** Customer email must follow standard format (user@domain.ext)
- **Category:** Data Format
- **Affected Fields:** `email`
- **Business Justification:** Ensures we can contact customers via email
- **Enforcement:** Database (CHECK with regex)
- **Maps to:** CS-CUST-002a
- **Test Case:** Try to insert "notanemail" → Should fail

#### BR-CUST-005: Phone Number is Optional
- **Rule Statement:** Customer may choose not to provide phone number
- **Category:** Optional Data
- **Affected Fields:** `phone`
- **Business Justification:** Not all customers want to share phone; email suffices
- **Enforcement:** Database (nullable field)
- **Maps to:** CS-CUST-005
- **Test Case:** Create customer without phone → Should succeed

#### BR-CUST-006: Loyalty Points Cannot Be Negative
- **Rule Statement:** Customer loyalty points must be zero or positive
- **Category:** Range/Domain
- **Affected Fields:** `points`
- **Business Justification:** Points represent value earned, cannot be negative debt
- **Enforcement:** Database (CHECK constraint)
- **Maps to:** CS-CUST-003, CS-CUST-003a
- **Test Case:** Try to set points to -100 → Should fail

#### BR-CUST-007: New Customers Start With Zero Points
- **Rule Statement:** When a customer registers, they start with 0 loyalty points
- **Category:** Default Value
- **Affected Fields:** `points`
- **Business Justification:** Points must be earned through purchases
- **Enforcement:** Database (DEFAULT 0)
- **Maps to:** CS-CUST-004
- **Test Case:** Create customer without specifying points → Should default to 0

---

### 👔 EMPLOYEES Rules

#### BR-EMP-001: Employee Must Have Contact Information
- **Rule Statement:** Every employee must have email for system communications
- **Category:** Mandatory Data
- **Affected Fields:** `email`
- **Business Justification:** Required for system login and notifications
- **Enforcement:** Database (NOT NULL)

#### BR-EMP-002: Employee Email Must Be Unique
- **Rule Statement:** No two employees can have the same email address
- **Category:** Uniqueness
- **Affected Fields:** `email`
- **Business Justification:** Email used as login identifier
- **Enforcement:** Database (UNIQUE constraint)

#### BR-EMP-003: Hire Date Cannot Be Future
- **Rule Statement:** Employee hire date must be today or in the past
- **Category:** Range/Domain
- **Affected Fields:** `hire_date`
- **Business Justification:** Cannot hire someone who hasn't started yet
- **Enforcement:** Database (CHECK constraint)
- **Test Case:** Try to set hire_date to tomorrow → Should fail

#### BR-EMP-004: Salary Must Be Positive
- **Rule Statement:** Employee salary must be greater than zero
- **Category:** Range/Domain
- **Affected Fields:** `salary`
- **Business Justification:** Employees must be compensated for work
- **Enforcement:** Database (CHECK constraint)
- **Test Case:** Try to set salary to 0 or negative → Should fail

#### BR-EMP-005: New Employees Are Active by Default
- **Rule Statement:** When an employee is hired, they are marked as active
- **Category:** Default Value
- **Affected Fields:** `is_active`
- **Business Justification:** New hires are active unless specified otherwise
- **Enforcement:** Database (DEFAULT TRUE)

---

### 📦 PRODUCTS Rules

#### BR-PROD-001: Product Must Have Unique SKU
- **Rule Statement:** Each product must have a unique Stock Keeping Unit (SKU)
- **Category:** Uniqueness
- **Affected Fields:** `sku`
- **Business Justification:** SKU is the universal identifier for inventory tracking
- **Enforcement:** Database (UNIQUE constraint)

#### BR-PROD-002: SKU Format Must Be Standardized
- **Rule Statement:** SKU must contain only uppercase letters, numbers, and hyphens
- **Category:** Data Format
- **Affected Fields:** `sku`
- **Business Justification:** Standardization prevents confusion and scanning errors
- **Enforcement:** Database (CHECK with regex pattern)
- **Example:** "COCA-500ML-001" ✅, "coca500ml" ❌

#### BR-PROD-003: Price Must Be Positive
- **Rule Statement:** Product selling price must be greater than zero
- **Category:** Range/Domain
- **Affected Fields:** `price`
- **Business Justification:** Products must generate revenue
- **Enforcement:** Database (CHECK constraint)

#### BR-PROD-004: Cost Must Be Positive
- **Rule Statement:** Product cost (purchase price) must be greater than zero
- **Category:** Range/Domain
- **Affected Fields:** `cost`
- **Business Justification:** Products cost money to acquire
- **Enforcement:** Database (CHECK constraint)

#### BR-PROD-005: Selling Price Should Exceed Cost
- **Rule Statement:** Product selling price should be greater than cost
- **Category:** Business Logic
- **Affected Fields:** `price`, `cost`
- **Business Justification:** Goal is to make profit on sales
- **Enforcement:** Database (CHECK constraint)
- **⚠️ Note:** May need override for clearance/promotional items

#### BR-PROD-006: Stock Cannot Be Negative
- **Rule Statement:** Product stock quantity must be zero or positive
- **Category:** Range/Domain
- **Affected Fields:** `stock`
- **Business Justification:** Cannot have negative inventory (cannot sell what doesn't exist)
- **Enforcement:** Database (CHECK constraint)

#### BR-PROD-007: Minimum Stock Must Be Positive
- **Rule Statement:** Minimum stock threshold must be greater than zero
- **Category:** Range/Domain
- **Affected Fields:** `min_stock`
- **Business Justification:** Alerts needed for reordering; zero would mean no alert
- **Enforcement:** Database (CHECK constraint)

#### BR-PROD-008: Product Must Belong to Category
- **Rule Statement:** Every product must be assigned to exactly one category
- **Category:** Mandatory Data
- **Affected Fields:** `category_id`
- **Business Justification:** Required for organization and reporting
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

#### BR-PROD-009: Product Must Have Supplier
- **Rule Statement:** Every product must have an assigned supplier
- **Category:** Mandatory Data
- **Affected Fields:** `supplier_id`
- **Business Justification:** Must know where to reorder products
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

---

### 🛒 SALES Rules

#### BR-SALE-001: Sale Must Have Customer
- **Rule Statement:** Every sale must be associated with a customer
- **Category:** Referential Integrity
- **Affected Fields:** `customer_id`
- **Business Justification:** Track purchase history and loyalty points
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

#### BR-SALE-002: Sale Must Have Employee
- **Rule Statement:** Every sale must record which employee processed it
- **Category:** Referential Integrity
- **Affected Fields:** `employee_id`
- **Business Justification:** Accountability and performance tracking
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

#### BR-SALE-003: Sale Date Cannot Be Future
- **Rule Statement:** Sale date/time must be current time or in the past
- **Category:** Range/Domain
- **Affected Fields:** `sale_date`
- **Business Justification:** Cannot record sales that haven't happened yet
- **Enforcement:** Database (CHECK constraint)
- **⚠️ Note:** May allow backdating for manual entry of offline sales

#### BR-SALE-004: Amounts Must Be Non-Negative
- **Rule Statement:** Subtotal, tax, and total amounts must be zero or positive
- **Category:** Range/Domain
- **Affected Fields:** `subtotal`, `tax`, `total_amount`
- **Business Justification:** Sales generate revenue, not negative amounts
- **Enforcement:** Database (CHECK constraint)
- **⚠️ Note:** Refunds handled separately with status field

#### BR-SALE-005: Total Must Equal Subtotal Plus Tax
- **Rule Statement:** Total amount must equal subtotal plus tax
- **Category:** Calculation
- **Affected Fields:** `total_amount`, `subtotal`, `tax`
- **Business Justification:** Mathematical integrity of transaction
- **Enforcement:** Database (CHECK constraint with formula)
- **Formula:** `total_amount = subtotal + tax`

#### BR-SALE-006: Payment Method Must Be Valid
- **Rule Statement:** Payment method must be one of: cash, card, transfer, other
- **Category:** Range/Domain
- **Affected Fields:** `payment_method`
- **Business Justification:** Standardization for accounting and reporting
- **Enforcement:** Database (CHECK with IN clause)

#### BR-SALE-007: Sale Status Must Be Valid
- **Rule Statement:** Sale status must be: pending, completed, cancelled, or refunded
- **Category:** Range/Domain
- **Affected Fields:** `status`
- **Business Justification:** Track sale lifecycle accurately
- **Enforcement:** Database (CHECK with IN clause)

#### BR-SALE-008: Completed Sales Are Default
- **Rule Statement:** New sales default to 'completed' status
- **Category:** Default Value
- **Affected Fields:** `status`
- **Business Justification:** Most sales complete immediately at register
- **Enforcement:** Database (DEFAULT 'completed')

---

### 📝 SALE_ITEMS Rules

#### BR-ITEM-001: Item Must Belong to a Sale
- **Rule Statement:** Every sale item must reference a valid sale
- **Category:** Referential Integrity
- **Affected Fields:** `sale_id`
- **Business Justification:** Items cannot exist without parent sale
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

#### BR-ITEM-002: Item Must Reference Valid Product
- **Rule Statement:** Every sale item must reference an existing product
- **Category:** Referential Integrity
- **Affected Fields:** `product_id`
- **Business Justification:** Cannot sell non-existent products
- **Enforcement:** Database (NOT NULL + FOREIGN KEY)

#### BR-ITEM-003: Quantity Must Be Positive
- **Rule Statement:** Item quantity must be at least 1
- **Category:** Range/Domain
- **Affected Fields:** `quantity`
- **Business Justification:** Cannot sell zero or negative quantities
- **Enforcement:** Database (CHECK constraint)

#### BR-ITEM-004: Unit Price Must Be Positive
- **Rule Statement:** Unit price at time of sale must be greater than zero
- **Category:** Range/Domain
- **Affected Fields:** `unit_price`
- **Business Justification:** Products have value
- **Enforcement:** Database (CHECK constraint)

#### BR-ITEM-005: Store Price at Sale Time
- **Rule Statement:** Item must record unit_price at moment of sale, not reference current product price
- **Category:** Business Logic
- **Affected Fields:** `unit_price`
- **Business Justification:** Product prices change; historical sales must reflect actual price paid
- **Enforcement:** Application logic (copy price to sale_items)
- **Example:** Product costs $10 today; sold yesterday when it was $8; sale_items.unit_price = $8

#### BR-ITEM-006: Discount Must Be Valid Percentage
- **Rule Statement:** Discount percentage must be between 0 and 100
- **Category:** Range/Domain
- **Affected Fields:** `discount_percent`
- **Business Justification:** Cannot have negative discount or over 100% discount
- **Enforcement:** Database (CHECK constraint)

#### BR-ITEM-007: No Discount is Default
- **Rule Statement:** If no discount specified, default to 0%
- **Category:** Default Value
- **Affected Fields:** `discount_percent`
- **Business Justification:** Most items sold at full price
- **Enforcement:** Database (DEFAULT 0)

#### BR-ITEM-008: Subtotal Must Be Calculated Correctly
- **Rule Statement:** Item subtotal must equal quantity × unit_price × (1 - discount_percent/100)
- **Category:** Calculation
- **Affected Fields:** `subtotal`, `quantity`, `unit_price`, `discount_percent`
- **Business Justification:** Mathematical integrity
- **Enforcement:** Database (CHECK constraint with formula)
- **Formula:** `subtotal = quantity * unit_price * (1 - discount_percent / 100)`

---

## 🔗 Relationship Rules

Relationship-specific business rules define constraints on how entities can be related to each other.

### RR-001: Category Cannot Be Deleted If Products Exist
- **Rule Statement:** A category with associated products cannot be deleted
- **Affected Entities:** categories → products
- **Business Justification:** Preserve data integrity; products need categories
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)
- **Alternative Action:** Mark category as inactive instead of deleting

### RR-002: Supplier Cannot Be Deleted If Products Exist
- **Rule Statement:** A supplier with associated products cannot be deleted
- **Affected Entities:** suppliers → products
- **Business Justification:** Must maintain supplier history for existing products
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)

### RR-003: Customer Cannot Be Deleted If Sales Exist
- **Rule Statement:** A customer with purchase history cannot be deleted
- **Affected Entities:** customers → sales
- **Business Justification:** Preserve sales history for auditing and analytics
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)
- **Alternative Action:** Mark customer as inactive

### RR-004: Employee Cannot Be Deleted If Sales Exist
- **Rule Statement:** An employee who has processed sales cannot be deleted
- **Affected Entities:** employees → sales
- **Business Justification:** Accountability and audit trail
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)

### RR-005: Deleting Sale Deletes Its Items
- **Rule Statement:** When a sale is deleted, all its line items are automatically deleted
- **Affected Entities:** sales → sale_items
- **Business Justification:** Sale items cannot exist without parent sale
- **Enforcement:** Database (FOREIGN KEY with ON DELETE CASCADE)

### RR-006: Product Cannot Be Deleted If In Sales History
- **Rule Statement:** A product that has been sold cannot be deleted
- **Affected Entities:** products → sale_items
- **Business Justification:** Preserve historical sales data
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)
- **Alternative Action:** Mark product as discontinued

### RR-007: Product Cannot Be Deleted If In Inventory Logs
- **Rule Statement:** A product with inventory history cannot be deleted
- **Affected Entities:** products → inventory_logs
- **Business Justification:** Audit trail for inventory movements
- **Enforcement:** Database (FOREIGN KEY with ON DELETE RESTRICT)

---

## ⚙️ Business Process Rules

### Process Rule Template
```
PR-[NUMBER]: [Process Name]
│
├─ Trigger: [What initiates this process]
├─ Affected Entities: [Tables involved]
├─ Steps: [Sequence of actions]
└─ Expected Outcome: [Result]
```

### PR-001: Loyalty Points Calculation
- **Process:** Award points to customer after completed sale
- **Trigger:** Sale status changes to 'completed'
- **Business Rule:** Customer earns 1 point per $10 spent (rounded down)
- **Affected Entities:** customers.points, sales.total_amount
- **Formula:** `points_earned = FLOOR(total_amount / 10)`
- **Example:** $47.50 purchase = 4 points
- **Enforcement:** Application logic or database trigger

### PR-002: Inventory Deduction
- **Process:** Reduce product stock when item is sold
- **Trigger:** New record inserted into sale_items
- **Business Rule:** Stock decreases by quantity sold
- **Affected Entities:** products.stock, sale_items.quantity
- **Formula:** `new_stock = current_stock - quantity_sold`
- **Enforcement:** Database trigger
- **Validation:** Must check stock available before sale

### PR-003: Low Stock Alert
- **Process:** Identify products needing reorder
- **Trigger:** Product stock falls to or below min_stock
- **Business Rule:** Alert when stock ≤ min_stock
- **Affected Entities:** products.stock, products.min_stock
- **Enforcement:** Query/View for monitoring
- **Action:** Generate purchase order

### PR-004: Inventory Audit Logging
- **Process:** Record all stock changes
- **Trigger:** Any change to products.stock
- **Business Rule:** Log previous stock, new stock, change amount, and reason
- **Affected Entities:** products.stock, inventory_logs
- **Enforcement:** Database trigger
- **Purpose:** Complete audit trail

---

## 🔐 Security & Access Rules

### SR-001: Employee Salary Privacy
- **Rule:** Only managers and HR can view employee salary information
- **Affected Fields:** employees.salary
- **Enforcement:** Application-level permissions
- **Justification:** Protect sensitive compensation data

### SR-002: Sale Modification Restrictions
- **Rule:** Completed sales cannot be modified, only refunded
- **Affected Entity:** sales
- **Enforcement:** Application logic
- **Justification:** Prevent fraud and maintain audit integrity

### SR-003: Customer Data Privacy
- **Rule:** Employees can only view customer data during active transaction
- **Affected Entity:** customers
- **Enforcement:** Application-level access control
- **Justification:** Comply with privacy regulations

---

## 📊 Rule Traceability Matrix

This matrix maps business rules to their technical implementation:

| Business Rule ID | Rule Type | Constraint Strategy ID | Implementation Method | Priority |
|-----------------|-----------|----------------------|---------------------|----------|
| BR-CUST-001 | Mandatory | CS-CUST-001 | NOT NULL | Critical |
| BR-CUST-003 | Uniqueness | CS-CUST-002 | UNIQUE | Critical |
| BR-CUST-006 | Range | CS-CUST-003 | CHECK (points >= 0) | High |
| BR-PROD-005 | Business Logic | CS-PROD-004 | CHECK (price > cost) | Medium |
| BR-SALE-005 | Calculation | CS-SALE-003 | CHECK (total = sub + tax) | Critical |
| RR-001 | Referential | CS-REL-001 | ON DELETE RESTRICT | Critical |
| PR-001 | Process | TRG-001 | Database Trigger | High |

**Priority Levels:**
- **Critical:** Data integrity violation; prevents database corruption
- **High:** Important business rule; significant impact if violated
- **Medium:** Business preference; some flexibility allowed
- **Low:** Nice-to-have; minimal impact if violated

---

## ✅ Rule Validation & Testing

For each business rule, we must verify:

1. **Positive Test:** Valid data is accepted
2. **Negative Test:** Invalid data is rejected
3. **Boundary Test:** Edge cases are handled correctly
4. **Performance Test:** Rule enforcement doesn't slow down operations

Example Test Case for BR-CUST-006:
```sql
-- Positive: Should succeed
UPDATE customers SET points = 0 WHERE customer_id = 1;
UPDATE customers SET points = 100 WHERE customer_id = 1;

-- Negative: Should fail
UPDATE customers SET points = -10 WHERE customer_id = 1;

-- Boundary: Should succeed
UPDATE customers SET points = 0 WHERE customer_id = 1;  -- Exactly 0 is valid
```

---

## 🤝 Approval & Sign-off

This business rules document requires approval before implementation:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Owner | [Name] | ____________ | ______ |
| Store Manager | [Name] | ____________ | ______ |
| Database Architect | [Name] | ____________ | ______ |
| Development Lead | [Name] | ____________ | ______ |

---

## 📝 Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-04 | [Your Name] | Initial business rules document |

---

## 📚 References

- CONSTRAINTS_STRATEGY.md - Technical implementation of these rules
- NAMING_CONVENTIONS.md - Naming standards for constraints
- ER_Diagram.png - Visual representation of entities and relationships

---

**Next Step:** Use this document as input to create CONSTRAINTS_STRATEGY.md, which translates these business-language rules into SQL constraints.