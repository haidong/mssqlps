mssqlps
=======

PowerShell and related scripts for SQL Server administration

The scripts here make extensive use of sqlps by importing that module. To install the sqlps module (independent of the sqlps utility inside of Management Studio), please go to:

https://www.microsoft.com/en-us/download/details.aspx?id=29065

and install the following:

1. Microsoft System CLR Types for Microsoft SQL Server 2012
2. Microsoft SQL Server 2012 Shared Management Objects
3. Microsoft Windows PowerShell Extensions for Microsoft SQL Server 2012

## baseFunctions.ps1
Base functions that we source into and exposes commonly used functions. For instance, it has functions for:

1. Get instance version
2. Get a list of user (non-system) databases
3. Get a list of data files for a given database
4. Get a list of log files for a given database
5. Generate database attach scripts given a database name
6. Get data and index sizes given a database name

The rest of the PowerShell scripts mostly use the functions exposed inside baseFunctions.ps1. It's purpose is explained by its name. You may need to modify two places to run those scripts:

1. The path to where baseFunction.ps1. Normally this is the second line in the file;
2. The $fileName and, if present, the $savedScriptPath parameter. They decide where the generated files will be saved.
