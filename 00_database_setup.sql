-- ============================================================================
-- POS SYSTEM - DATABASE SETUP SCRIPT
-- ============================================================================
-- Description: Initial database setup including roles, schemas, and extensions
-- Author: Your Name
-- Date: December 2024
-- Version: 1.0
-- ============================================================================

-- ============================================================================
-- PART 1: DATABASE CREATION
-- ============================================================================
-- Note: Run this section as PostgreSQL superuser (postgres)
-- Command: psql -U postgres -f 00_database_setup.sql

-- Drop database if exists (only for development/testing)
DROP DATABASE IF EXISTS pos_system;

-- Create database with proper encoding
CREATE DATABASE pos_system
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE pos_system IS 'Point of Sale System - Retail Management Database';

-- Connect to the new database
\c pos_system