# Data_Cleaning_Using_SQL

Loaded Nashville Housing data in excel to SSMS and performed the following operations in SQL to clean the data.
- Changed DateTime Format using 'convert(Date, SaleDate))'
- Removed Null values in a column by populating the null values in columns with appropriate values using 'self join' and 'isnull()'
- Split Address columns to Address, City & State columns using 'parsename()', 'substring()' and 'charindex()'
- Corrected distinct values with same interpretation to single values using 'distinct()' and 'case-when-else-end' 
- Removed Duplicate rows using 'with CLT', 'partition by' and 'delete'
- Deleted unused columns using 'alter table' and 'drop column'
