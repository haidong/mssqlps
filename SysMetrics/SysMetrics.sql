CREATE DATABASE SysMetrics
GO
ALTER DATABASE SysMetrics SET RECOVERY SIMPLE;
GO
USE [SysMetrics]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'Windows')
DROP SCHEMA [Windows]
GO

CREATE SCHEMA [Windows] AUTHORIZATION [dbo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Windows].[Host](
	[HostID] [int] IDENTITY(1,1) NOT NULL,
	[HostName] [nvarchar](20) NOT NULL,
	[Domain] [nvarchar](50) NULL,
	[OS] [nvarchar](50) NULL,
	[OSArchitecture] [nchar](6) NULL,
	[OSServicePack] [nvarchar](20) NULL,
	[OSVersionNumber] [nvarchar](20) NULL,
	[HardwareModel] [nvarchar](50) NULL,
	[HardwareVendor] [nvarchar](50) NULL,
	[MemorySizeGB] [int] NULL,
	[CPUType] [nvarchar] (50) NULL,
	[CoreCount] [int] NULL,
	[IsActive] [nchar](1) NOT NULL,
	[LastUpdate] [datetime2] NULL
 CONSTRAINT [PK_Host] PRIMARY KEY CLUSTERED 
(
	[HostID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON),
 CONSTRAINT [UNQ_HostName] UNIQUE NONCLUSTERED 
(
	[HostName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)

GO

ALTER TABLE [Windows].[Host]  WITH CHECK ADD  CONSTRAINT [CK_Host_IsActive] CHECK  (([IsActive]='N' OR [IsActive]='n' OR [IsActive]='Y' OR [IsActive]='y'))
GO

ALTER TABLE [Windows].[Host] CHECK CONSTRAINT [CK_Host_IsActive]
GO

ALTER TABLE [Windows].[Host] ADD  CONSTRAINT [DF_Host_IsActive]  DEFAULT ('Y') FOR [IsActive]
GO

ALTER TABLE [Windows].[Host] ADD CONSTRAINT [DF_Host_LastUpdate] DEFAULT (getdate()) FOR [LastUpdate]
GO

CREATE PROCEDURE Windows.Host_Select_HostID_HostName 
	@IsActive nchar(1) = 'Y'
AS
BEGIN
	SET NOCOUNT ON;

	SELECT HostID, HostName FROM Windows.Host
	WHERE IsActive = @IsActive;
END
GO
CREATE PROCEDURE Windows.Host_Update 
	  @HostID int = 0
	, @Domain nvarchar(50) = NULL
	, @OS nvarchar(50) = NULL
	, @OSArchitecture nchar(6) = NULL
	, @OSServicePack nvarchar(20) = NULL
	, @OSVersionNumber nvarchar(20) = NULL
	, @HardwareModel nvarchar(50) = NULL
	, @HardwareVendor nvarchar(50) = NULL
	, @MemorySizeGB int = NULL
	, @CPUType nvarchar(50) = NULL
	, @CoreCount int = NULL
	, @IsActive nchar(1) = 'Y'
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Windows.Host SET
	  Domain = @Domain
	, OS = @OS
	, OSArchitecture = @OSArchitecture
	, OSServicePack = @OSServicePack
	, OSVersionNumber = @OSVersionNumber
	, HardwareModel = @HardwareModel
	, HardwareVendor = @HardwareVendor
	, MemorySizeGB = @MemorySizeGB
	, CPUType = @CPUType
	, CoreCount = @CoreCount
	, IsActive = @IsActive
	WHERE HostID = @HostID;
END
GO
--INSERT INTO Windows.Host (HostName) VALUES ('sql1')
--INSERT INTO Windows.Host (HostName) VALUES ('sql2')


CREATE TABLE [Windows].[Instance](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[HostID] [int] NOT NULL,
	[InstanceName] [nvarchar](30) NULL,
	[InstanceEdition] [nvarchar](50) NULL,
	[InstanceEditionID] [bigint] NULL,
	[InstanceVersion] [nchar](20) NULL,
	[InstanceServicePack] [nvarchar](20) NULL,
	[IsActive] [nchar](1) NOT NULL,
	[LastUpdate] [datetime2] NULL
 CONSTRAINT [PK_Instance] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON),
 CONSTRAINT [UNQ_InstanceName] UNIQUE NONCLUSTERED 
(
	[InstanceName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) 

GO

ALTER TABLE [Windows].[Instance]  WITH CHECK ADD  CONSTRAINT [CK_Instance_IsActive] CHECK  (([IsActive]='N' OR [IsActive]='n' OR [IsActive]='Y' OR [IsActive]='y'))
GO

ALTER TABLE [Windows].[Instance] CHECK CONSTRAINT [CK_Instance_IsActive]
GO

ALTER TABLE [Windows].[Instance] ADD  CONSTRAINT [DF_Instance_IsActive]  DEFAULT ('Y') FOR [IsActive]
GO

ALTER TABLE [Windows].[Instance] ADD CONSTRAINT [DF_Instance_LastUpdate] DEFAULT (getdate()) FOR [LastUpdate]
GO

CREATE PROCEDURE Windows.Instance_Select_InstanceID_InstanceName 
	@IsActive nchar(1) = 'Y'
AS
BEGIN
	SET NOCOUNT ON;

	SELECT InstanceID, InstanceName FROM Windows.Instance
	WHERE IsActive = @IsActive;
END
GO

CREATE PROCEDURE Windows.Instance_Insert 
       	@HostID int
	, @InstanceName nvarchar(30)
	, @IsActive nvarchar(1)
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT * FROM Windows.Instance WHERE InstanceName = @InstanceName)
	INSERT INTO [Windows].[Instance] (HostID, InstanceName, IsActive) VALUES (@HostID, @InstanceName, @IsActive);
END
GO

CREATE PROCEDURE Windows.Instance_Update 
	  @InstanceID int = 0
	, @InstanceEdition nvarchar(50) = NULL
	, @InstanceEditionID bigint = NULL
	, @InstanceVersion nvarchar(20) = NULL
	, @InstanceServicePack nvarchar(20) = NULL
	, @IsActive nchar(1) = 'Y'
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Windows.Instance SET
	  InstanceEdition = @InstanceEdition
	, InstanceEditionID = @InstanceEditionID
	, InstanceVersion = @InstanceVersion
	, InstanceServicePack = @InstanceServicePack
	, IsActive = @IsActive
	WHERE InstanceID = @InstanceID;
END
GO

CREATE TABLE [Windows].[Storage](
	  [RecordID] [int] IDENTITY(1,1) NOT NULL
	, [HostID] [int] NOT NULL
	, [DiskPath] [nvarchar](300) NOT NULL
	, [DiskFormat] [nvarchar](25) NOT NULL
	, [DiskLabel] [nvarchar](100) NULL
	, [DiskSizeGB] [int] NOT NULL
	, [DiskFreeGB] [int] NOT NULL
	, [DiskUsedGB] AS ([DiskSizeGB]-[DiskFreeGB]) PERSISTED
	, [CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__Storage_RecordID] PRIMARY KEY CLUSTERED
(
[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
 
GO
 
ALTER TABLE [Windows].[Storage] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[Storage] WITH CHECK ADD CONSTRAINT [fk__Storage_HostID] FOREIGN KEY([HostID])
REFERENCES [Windows].[Host] ([HostID])
GO
 
ALTER TABLE [Windows].[Storage] CHECK CONSTRAINT [fk__Storage_HostID]
GO
 
ALTER TABLE [Windows].[Storage] WITH CHECK ADD CONSTRAINT [ck__Storage_DiskSize] CHECK (([DiskUsedGB]>=(0) AND [DiskSizeGB]>=(0) AND [DiskFreeGB]>=(0)))
GO
 
ALTER TABLE [Windows].[Storage] CHECK CONSTRAINT [ck__Storage_DiskSize]
GO
 
CREATE procedure [Windows].[Storage_Insert]
	  @HostID [int]
	, @DiskPath [nvarchar](1000)
	, @DiskFormat [nvarchar](50)
	, @DiskLabel [nvarchar](100)
	, @DiskSizeGB [int]
	, @DiskFreeGB [int]
AS

BEGIN
	SET NOCOUNT ON;
	INSERT INTO Windows.Storage (
		HostID
		, DiskPath
		, DiskFormat
		, DiskLabel
		, DiskSizeGB
		, DiskFreeGB)
	VALUES (
		@HostID
		, @DiskPath
		, @DiskFormat
		, @DiskLabel
		, @DiskSizeGB
		, @DiskFreeGB);
END
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [Windows].[DbFileStats](
	[DbFileStatsID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[DbName] [sysname] NOT NULL,
	[FileLogicalName] [sysname] NOT NULL,
	[FilePhysicalName] [sysname] NOT NULL,
	[FileGroupName] [sysname] NOT NULL,
	[FileSizeInMB] [int] NOT NULL,
	[FreeSizeInMB] [int] NOT NULL,
	[Max_Size] [int] NOT NULL,
	[Growth] [int] NOT NULL,
	[Is_Percent_Growth] nchar(1) NOT NULL,
	[CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__DbFileStatsID_SID] PRIMARY KEY CLUSTERED
(
[DbFileStatsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
) 
 
GO
 
ALTER TABLE [Windows].[DbFileStats] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[DbFileStats] WITH CHECK ADD FOREIGN KEY([InstanceID])
REFERENCES [Windows].[Instance] ([InstanceID])
GO

ALTER TABLE [Windows].[DbFileStats]  WITH CHECK ADD  CONSTRAINT [CK_DbFileStats_Is_Percent_Growth] CHECK  (([Is_Percent_Growth]='N' OR [Is_Percent_Growth]='n' OR [Is_Percent_Growth]='Y' OR [Is_Percent_Growth]='y'))
GO

ALTER TABLE [Windows].[DbFileStats] CHECK CONSTRAINT [CK_DbFileStats_Is_Percent_Growth]
GO

ALTER TABLE [Windows].[DbFileStats] ADD  CONSTRAINT [DF_DbFileStats_Is_Percent_Growth]  DEFAULT ('N') FOR [Is_Percent_Growth]
GO

CREATE PROCEDURE [Windows].[DbFileStats_Insert]
	@InstanceID int
	, @DbName sysname
	, @FileLogicalName sysname
	, @FilePhysicalName nvarchar(500)
	, @FileGroupName sysname
	, @FileSizeInMB [int]
	, @FreeSizeInMB [int]
	, @max_size [int]
	, @growth [int]
	, @is_percent_growth nchar(1)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Windows.DbFileStats (
		InstanceID
		, DbName
		, FileLogicalName
		, FilePhysicalName
		, FileGroupName
		, FileSizeInMB
		, FreeSizeInMB
		, max_size
		, growth
		, is_percent_growth)
	VALUES (
		@InstanceID
		, @DbName
		, @FileLogicalName
		, @FilePhysicalName
		, @FileGroupName
		, @FileSizeInMB
		, @FreeSizeInMB
		, @max_size
		, @growth
		, @is_percent_growth);
END

GO
 
CREATE TABLE [Windows].[TableStats](
	[TableStatsID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[DbName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[TotalRowCount] [bigint] NOT NULL,
	[DataSizeInMB] [int] NOT NULL,
	[IndexSizeInMB] [int] NOT NULL,
	[CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__TableStatsID_ID] PRIMARY KEY CLUSTERED
(
[TableStatsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
 
GO
 
ALTER TABLE [Windows].[TableStats] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[TableStats] WITH CHECK ADD FOREIGN KEY([InstanceID])
REFERENCES [Windows].[Instance] ([InstanceID])
GO
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 
CREATE procedure [Windows].[TableStats_Insert]
	@InstanceID int,
	@DbName sysname,
	@SchemaName sysname,
	@TableName sysname,
	@TotalRowCount bigint,
	@DataSizeInMB int,
	@IndexSizeInMB int
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO Windows.TableStats (InstanceID, DbName, SchemaName, TableName, TotalRowCount, DataSizeInMB, IndexSizeInMB)
	VALUES (@InstanceID, @DbName, @SchemaName, @TableName, @TotalRowCount, @DataSizeInMB, @IndexSizeInMB);
END 
 
GO


IF NOT EXISTS ( SELECT  *
                FROM    [sys].[tables]
                WHERE   [name] = N'InstanceConfig'
                        AND [type] = N'U' ) 
    CREATE TABLE [Windows].[InstanceConfig]
        (
	  [InstanceConfigID] [int] IDENTITY(1,1) NOT NULL,
	  [InstanceID] [int] NOT NULL,
          [ConfigurationID] [int] NOT NULL ,
          [Name] [nvarchar](35) NOT NULL ,
          [Value] [sql_variant] NULL ,
          [ValueInUse] [sql_variant] NULL ,
          [CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__InstanceConfigID_ID] PRIMARY KEY CLUSTERED
(
[InstanceConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

ALTER TABLE [Windows].[InstanceConfig] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO

CREATE PROCEDURE [Windows].[InstanceConfig_Insert]
	@InstanceID int
	, @ConfigurationID int
	, @Name nvarchar(35)
	, @Value sql_variant
	, @ValueInUse sql_variant
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Windows.InstanceConfig (
		InstanceID
		, ConfigurationID
		, Name
		, Value
		, ValueInUse)
	VALUES (
		@InstanceID
		, @ConfigurationID
		, @Name
		, @Value
		, @ValueInUse);
END
GO
