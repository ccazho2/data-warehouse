/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Bronze.BulkInsertData;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.BulkInsertData AS
BEGIN
    BEGIN TRY
        DECLARE @start_time_whole_batch DATETIME, @end_time_whole_batch DATETIME, @start_time DATETIME, @end_time DATETIME;

        SET @start_time_whole_batch = GETDATE();

        -- This stored procedure performs a bulk insert of data from CSV files into the Bronze schema tables
        PRINT '=============================================';
        PRINT '| Bulk Insert Data into Bronze Schema Tables |';
        PRINT '=============================================';

        PRINT '+--------------------------------------------+';
        PRINT '| Loading CRM Tables                         |';
        PRINT '+--------------------------------------------+';

        -- FULL LOAD of the Bronze.crm_cust_info table from the source CSV file
        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.crm_cust_info table...';
        TRUNCATE TABLE Bronze.crm_cust_info;
        BULK INSERT Bronze.crm_cust_info
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''
        -- Quality Check: Verify that the data has been successfully inserted into the Bronze.crm_cust_info table
        -- Running a SELECT statement to retrieve all records from the table. 
        -- Use a COUNT(*) query to check the total number of rows inserted.

        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.crm_prd_info table...';
        TRUNCATE TABLE Bronze.crm_prd_info;
        BULK INSERT Bronze.crm_prd_info
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''


        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.crm_sales_details table...';
        TRUNCATE TABLE Bronze.crm_sales_details;
        BULK INSERT Bronze.crm_sales_details
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''

        PRINT '+--------------------------------------------+';
        PRINT '| Loading ERP Tables                         |';
        PRINT '+--------------------------------------------+';
        
        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.erp_cust_az12 table...';
        TRUNCATE TABLE Bronze.erp_cust_az12;
        BULK INSERT Bronze.erp_cust_az12
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.erp_loc_a101 table...';
        TRUNCATE TABLE Bronze.erp_loc_a101;
        BULK INSERT Bronze.erp_loc_a101
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''

        SET @start_time = GETDATE();
        PRINT '>> Truncating and Bulk Inserting data into Bronze.erp_px_cat_g1v2 table...';
        TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
        BULK INSERT Bronze.erp_px_cat_g1v2
        FROM 'C:/var/lib/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
        WITH (
            FIELDTERMINATOR = ',',
            FIRSTROW = 2,
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds.';
        PRINT ''

        SET @end_time_whole_batch = GETDATE();
        PRINT 'Whole Batch Bulk Insert completed in ' + CAST(DATEDIFF(SECOND, @start_time_whole_batch, @end_time_whole_batch) AS NVARCHAR(10)) + ' seconds.';
    END TRY

    BEGIN CATCH
        PRINT 'An error occurred during the bulk insert operation of Bronze layer.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END
