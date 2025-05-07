-- Pharmacy POS Management System Database
-- This script creates all necessary tables for a pharmacy management system

DROP DATABASE IF EXISTS pharmacy_pos;
CREATE DATABASE pharmacy_pos;
USE pharmacy_pos;

-- 1. Users/Employees Table (1-M with Sales, InventoryLogs)
-- This table will store employee information and roles
-- Roles: Pharmacist, Technician, Cashier, Manager
-- Passwords should be hashed and salted in the application layer
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('Pharmacist', 'Technician', 'Cashier', 'Manager') NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Suppliers Table (1-M with Products)


CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    tax_id VARCHAR(50),
    payment_terms VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Product Categories Table (1-M with Products)
-- This table will store product categories

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_prescription_required BOOLEAN DEFAULT FALSE
);

-- 4. Products/Inventory Table (1-M with SalesItems, InventoryLogs)

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    generic_name VARCHAR(100),
    category_id INT NOT NULL,
    supplier_id INT,
    barcode VARCHAR(50) UNIQUE,
    sku VARCHAR(50) UNIQUE,
    description TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    reorder_level INT NOT NULL,
    current_stock INT NOT NULL DEFAULT 0,
    unit_of_measure VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- 5. Customers Table (1-M with Sales)
-- This table will store customer information and their health details
-- Health card number, allergies, and other relevant information
-- should be stored securely and in compliance with privacy regulations
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    health_card_number VARCHAR(50),
    allergies TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Sales Table (1-M with SalesItems)
-- This table will store sales transactions
-- It will include payment details, subtotal, tax, discount, and total amount
-- Payment method can be Cash, Credit Card, Debit Card, Insurance, or Other
-- Payment details can include transaction ID, card type, etc.
-- Insurance information can include policy number, provider, etc.
-- Notes can include any additional information related to the sale

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Other') NOT NULL,
    payment_details VARCHAR(100),
    insurance_info TEXT,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 7. Sales Items Table (M-1 with Sales and Products)
-- This table will store individual items sold in a transaction
-- It will include quantity, unit price, discount percentage, and total price
-- The total price will be calculated as (unit price * quantity) - (discount percentage * unit price * quantity)
-- The discount percentage can be applied to the total price of the item
-- The total price will be stored for reporting purposes
-- The sale_id will reference the sales table to link items to a specific transaction
-- The product_id will reference the products table to link items to specific products
-- The quantity will be the number of units sold
-- The unit price will be the selling price of the product at the time of sale
-- The discount percentage will be the percentage discount applied to the item
-- The total price will be the final price after applying the discount
-- The sale_item_id will be the primary key for this table
-- The sale_item_id will be auto-incremented to ensure uniqueness
-- The sale_id will be a foreign key referencing the sales table
-- The product_id will be a foreign key referencing the products table
-- The quantity, unit price, discount percentage, and total price will be stored as decimal values
CREATE TABLE sale_items (
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 8. Prescriptions Table (1-M with PrescriptionItems, M-1 with Customers and Doctors)
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    doctor_id INT NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    is_fulfilled BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 9. Doctors Table (1-M with Prescriptions)
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    specialization VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    clinic_address TEXT
);

-- Add foreign key to prescriptions after doctors table is created
ALTER TABLE prescriptions
ADD FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id);

-- 10. Prescription Items Table (M-1 with Prescriptions and Products)
CREATE TABLE prescription_items (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    product_id INT NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    instructions TEXT,
    is_fulfilled BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 11. Inventory Logs Table (M-1 with Products and Employees)
CREATE TABLE inventory_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    employee_id INT NOT NULL,
    log_type ENUM('Purchase', 'Sale', 'Adjustment', 'Return', 'Expired', 'Damaged') NOT NULL,
    quantity_change INT NOT NULL,
    previous_quantity INT NOT NULL,
    new_quantity INT NOT NULL,
    reference_id INT, -- Can reference sale_id, purchase_order_id, etc.
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 12. Purchase Orders Table (1-M with PurchaseOrderItems)
CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    status ENUM('Pending', 'Approved', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    total_amount DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 13. Purchase Order Items Table (M-1 with PurchaseOrders and Products)
CREATE TABLE purchase_order_items (
    po_item_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    received_quantity INT DEFAULT 0,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 14. Insurance Providers Table (1-M with Customers)
CREATE TABLE insurance_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    website VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

-- 15. Customer Insurance Table (M-1 with Customers and InsuranceProviders)
CREATE TABLE customer_insurance (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    provider_id INT NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    group_number VARCHAR(50),
    coverage_details TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (provider_id) REFERENCES insurance_providers(provider_id),
    UNIQUE KEY unique_customer_policy (customer_id, policy_number)
);

-- 16. Shifts Table (M-1 with Employees)
CREATE TABLE shifts (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 17. System Settings Table (1-1)
-- This table will store system-wide settings and configurations
-- such as pharmacy name, address, phone number, email, tax rate, currency, etc.
-- It will also include settings for low stock alerts, backup schedules, etc.

CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    pharmacy_name VARCHAR(100) NOT NULL,
    pharmacy_address TEXT NOT NULL,
    pharmacy_phone VARCHAR(20) NOT NULL,
    pharmacy_email VARCHAR(100),
    tax_rate DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    receipt_header TEXT,
    receipt_footer TEXT,
    low_stock_threshold INT DEFAULT 10,
    last_backup TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_sales_date ON sales(transaction_date);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_inventory_product ON inventory_logs(product_id);
CREATE INDEX idx_prescription_customer ON prescriptions(customer_id);