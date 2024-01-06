-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Manage UC Objects Using SQL Commands
-- MAGIC #### The following commands can be used to create the basic Unity Catalog objects required for a project & to set permissions on those objects:
-- MAGIC   - Storage Credential
-- MAGIC   - External Locations
-- MAGIC   - Catalog
-- MAGIC   - Schemas
-- MAGIC   - Volumes

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Storage Credentials:
-- MAGIC ###### Storage credentials can be created using the UI by following the directions below:
-- MAGIC - Navigate to the Catalog Page -> External Data -> Storage Credentials -> Create credential
-- MAGIC - Create a storage credential using the following inputs:
-- MAGIC   - Credential Type: Azure Managed Identity
-- MAGIC   - Storage Credential Name: umpqua_poc_sc
-- MAGIC   - Access Connector ID: '/subscriptions/\<subscriptionID>/resourcegroups/\<resourceGroupName>/providers/Microsoft.Databricks/accessConnectors/\<accessConnectorName>'
-- MAGIC   - Comment: Umpqua POC storage credential
-- MAGIC ###### For further information visit: 
-- MAGIC - https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-storage-credentials

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### External Locations:
-- MAGIC ###### Storage credentials can be created using SQL commands & the inputs below:
-- MAGIC - external_location_name: umpqua_poc_bronze_ext_loc 
-- MAGIC - external_url: abfss://\<container>@\<storage_account>.dfs.core.windows.net/\<path>
-- MAGIC - storage_credential_name: umpqua_poc_sc (Created in previous step)
-- MAGIC - comment: Umpqua POC bronze external location
-- MAGIC ###### For further information visit: 
-- MAGIC - https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-external-locations

-- COMMAND ----------

-- Grant permission to user, group, or service principal to create external locations using storage credential
GRANT CREATE EXTERNAL LOCATION ON STORAGE CREDENTIAL `umpqua_poc_sc` TO `david.finch@databricks.com`;


-- Create external location to be used for the bronze schema volume
CREATE EXTERNAL LOCATION IF NOT EXISTS `umpqua_poc_bronze_ext_loc` URL 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/bronze'
    WITH (CREDENTIAL `umpqua_poc_sc`)
    COMMENT 'Umpqua POC bronze external location';
-- Grant permission to user, group, or service principal to browse, read, & write files located in the external location & create managed storage and external volumes using the external location
GRANT BROWSE, READ FILES, WRITE FILES, CREATE EXTERNAL VOLUME, CREATE MANAGED STORAGE ON EXTERNAL LOCATION `umpqua_poc_bronze_ext_loc` TO `david.finch@databricks.com`;


-- Create external location to be used for the silver schema volume
CREATE EXTERNAL LOCATION IF NOT EXISTS `umpqua_poc_silver_ext_loc` URL 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/silver'
    WITH (CREDENTIAL `umpqua_poc_sc`)
    COMMENT 'Umpqua POC silver external location';
-- Grant permission to user, group, or service principal to browse, read, & write files located in the external location & create managed storage and external volumes using the external location
GRANT BROWSE, READ FILES, WRITE FILES, CREATE EXTERNAL VOLUME, CREATE MANAGED STORAGE ON EXTERNAL LOCATION `umpqua_poc_silver_ext_loc` TO `david.finch@databricks.com`;


-- Create external location to be used for the gold schema volume
CREATE EXTERNAL LOCATION IF NOT EXISTS `umpqua_poc_gold_ext_loc` URL 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/gold'
    WITH (CREDENTIAL `umpqua_poc_sc`)
    COMMENT 'Umpqua POC gold external location';
-- Grant permission to user, group, or service principal to browse, read, & write files located in the external location & create managed storage and external volumes using the external location
GRANT BROWSE, READ FILES, WRITE FILES, CREATE EXTERNAL VOLUME, CREATE MANAGED STORAGE ON EXTERNAL LOCATION `umpqua_poc_gold_ext_loc` TO `david.finch@databricks.com`;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Catalogs:
-- MAGIC ###### Catalogs can be created using SQL commands & the inputs below:
-- MAGIC - catalog_name: umpqua_poc 
-- MAGIC ###### For further information visit: 
-- MAGIC - https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-catalog

-- COMMAND ----------

-- Create Catalog if it does not exist
CREATE CATALOG IF NOT EXISTS umpqua_poc;
-- Grant "data editor" permissions to to user, group, or service principal on Catalog
GRANT USE CATALOG, USE SCHEMA, APPLY TAG, BROWSE, MODIFY, READ VOLUME, SELECT, WRITE VOLUME, CREATE FUNCTION, CREATE MATERIALIZED VIEW, CREATE MODEL, CREATE SCHEMA, CREATE TABLE, CREATE VOLUME ON CATALOG `umpqua_poc` TO `david.finch@databricks.com`;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Schemas:
-- MAGIC ###### Schemas can be created using SQL commands & the inputs below:
-- MAGIC - catalog_name: umpqua_poc
-- MAGIC - schema_name: bronze_data
-- MAGIC ###### For further information visit: 
-- MAGIC - https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-schema

-- COMMAND ----------

-- Create Schema if it does not exist
CREATE SCHEMA IF NOT EXISTS umpqua_poc.bronze_data;

-- Create Schema if it does not exist
CREATE SCHEMA IF NOT EXISTS umpqua_poc.silver_data;

-- Create Schema if it does not exist
CREATE SCHEMA IF NOT EXISTS umpqua_poc.gold_data;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Volumes:
-- MAGIC ###### Volumes can be created using SQL commands & the inputs below:
-- MAGIC - catalog_name: umpqua_poc
-- MAGIC - schema_name: bronze_data
-- MAGIC ###### For further information visit: 
-- MAGIC - https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-volume

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### Cleanup:
-- MAGIC ###### SQL statements such as the ones below can be used to revoke permissions on and to remove UC objects. You may need to remove objects contained in a UC object before being able to remove the UC object itself. 

-- COMMAND ----------

CREATE EXTERNAL VOLUME IF NOT EXISTS umpqua_poc.bronze_data.bronze_volume
  LOCATION 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/bronze'
  COMMENT 'External volume for the Umpqua POC bronze layer';

CREATE EXTERNAL VOLUME IF NOT EXISTS umpqua_poc.silver_data.silver_volume
  LOCATION 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/silver'
  COMMENT 'External volume for the Umpqua POC silver layer';

CREATE EXTERNAL VOLUME IF NOT EXISTS umpqua_poc.gold_data.gold_volume
  LOCATION 'abfss://umpquapoc@oneenvadls.dfs.core.windows.net/umpqua_poc/volumes/gold'
  COMMENT 'External volume for the Umpqua POC gold layer';

-- COMMAND ----------


