mssqlps
=======

PowerShell and related scripts for SQL Server administration

baseFunctions.ps1
Base functions that we source into and exposes commonly used functions. For instance, it has functions for:
Get instance version
Get a list of user (non-system) databases
Get a list of data files for a given database
Get a list of log files for a given database
Generate database attach scripts given a database name
Get data and index sizes given a database name

The rest of the PowerShell scripts mostly use the functions exposed inside baseFunctions.ps1. It's purpose is explained by its name. You may need to modify two places to run those scripts:
1. The path to where baseFunction.ps1. Normally this is the second line in the file;
2. The $fileName and, if present, the $savedScriptPath parameter. They decide where the generated files will be saved.
