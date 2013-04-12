DBAMetrics is a SQL Server database that stores:

1. Windows server disk information, including total disk size, free size. It also collects size information for mount points;
2. SQL Server database file and table size information. For database files, it stores total size, size free, and growth patterns. For table size, it stores the database and schema the table belongs to, along with row counts, data size, and index size.

Data collection is done via PowerShell scripts here. Based on those scripts, one can create SQL Server Agent jobs to update (for servers and instances) and insert (for database files and tables) data. All scripts have been tested and are ready to use.

Once setup, the data collected can be used for forecasting, capacity planning, data center management, and such. Once set up and collected at an interval you define, the data can also be used to draw graph for better visualization, planning, and decision-making.
