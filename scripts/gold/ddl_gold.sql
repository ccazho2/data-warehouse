/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.vw_customer_dim
-- =============================================================================
IF OBJECT_ID('gold.vw_customer_dim', 'V') IS NOT NULL
    DROP VIEW gold.vw_customer_dim;
GO
CREATE VIEW gold.vw_customer_dim AS
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ci.cst_create_date, ci.cst_id) AS Customer_key, -- Surrogate key
        ci.cst_id as Customer_ID,
        ci.cst_key as Customer_Number,
        ci.cst_firstname as First_Name,
        ci.cst_lastname as Last_Name,
        CASE 
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the primary source
            ELSE COALESCE(az.GEN, 'n/a')  			   -- Fallback to ERP data
        END AS Gender,
        az.BDATE as Birth_Date,
        ci.cst_marital_status as Marital_Status,
        loc.CNTRY as Country,
        ci.cst_create_date as Create_Date
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 az 
        ON ci.cst_key = az.CID
    LEFT JOIN silver.erp_loc_a101 loc 
        ON ci.cst_key = loc.CID;
GO
-- =============================================================================
-- Create Dimension: gold.vw_product_dim
-- =============================================================================
IF OBJECT_ID('gold.vw_product_dim', 'V') IS NOT NULL
    DROP VIEW gold.vw_product_dim;
GO
CREATE VIEW gold.vw_product_dim AS
    SELECT 
        ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) AS Product_key, -- Surrogate key
        pr.prd_id as Product_ID,
        pr.prd_key as Product_Number,
        pr.prd_nm as Product_Name,
        pr.cat_id as Category_ID,
        cat.CAT as Category,
        cat.subcat as Subcategory,
        cat.maintenance as Maintenance_Info,
        pr.prd_cost as Product_Cost,
        pr.prd_line as Product_Line,
        pr.prd_start_dt as Start_Date
    FROM silver.crm_prd_info pr
    LEFT JOIN silver.erp_px_cat_g1v2 cat ON pr.cat_id = cat.ID
    WHERE pr.prd_end_dt IS NULL -- Filter for active products only;
GO
-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
    SELECT 
        sd.sls_ord_num as Sales_Order_Number,
        cd.Customer_key,
        pd.Product_key,
        sd.sls_order_dt as Order_Date,
        sd.sls_ship_dt as Ship_Date,
        sd.sls_due_dt as Due_Date,
        sd.sls_sales as Sales_Amount,
        sd.sls_quantity as Quantity,
        sd.sls_price as Price
    FROM silver.crm_sales_details sd
    LEFT JOIN gold.vw_customer_dim cd ON sd.sls_cust_id = cd.Customer_ID
    LEFT JOIN gold.vw_product_dim pd ON sd.sls_prd_key = pd.Product_Number
