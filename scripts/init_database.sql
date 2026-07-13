/*
=============================================================
Create Database and Schemas
=============================================================
Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO -- required to separate batches when working with multiple SQL statements in a single script

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create new 'DataWarehouse' database. This will be used to store and manage data for the data warehouse solution.
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- CREATE SCHEMA statement is used to create a new schema in the current database. 
-- A schema is a collection of database objects, such as tables, views, and stored procedures, that are logically grouped together. 
-- Each schema can be used to organize and manage different sets of data within the DataWarehouse database.
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
