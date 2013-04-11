CREATE DATABASE DBAMetrics
GO
SET ANSI_PADDING OFF
GO
USE [DBAMetrics]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'Windows')
DROP SCHEMA [Windows]
GO

CREATE SCHEMA [Windows] AUTHORIZATION [dbo]
GO

/****** Object:  Table [Windows].[Host]    Script Date: 06/05/2012 17:23:16 ******/
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG],
 CONSTRAINT [UNQ_HostName] UNIQUE NONCLUSTERED 
(
	[HostName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG]
) ON [DefFG]

GO

ALTER TABLE [Windows].[Host]  WITH CHECK ADD  CONSTRAINT [CK_Host_IsActive] CHECK  (([IsActive]='N' OR [IsActive]='n' OR [IsActive]='Y' OR [IsActive]='y'))
GO

ALTER TABLE [Windows].[Host] CHECK CONSTRAINT [CK_Host_IsActive]
GO

ALTER TABLE [Windows].[Host] ADD  CONSTRAINT [DF_Host_IsActive]  DEFAULT ('Y') FOR [IsActive]
GO

ALTER TABLE [Windows].[Host] ADD CONSTRAINT [DF_Host_LastUpdate] DEFAULT (getdate()) FOR [LastUpdate]
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
CREATE PROCEDURE Windows.Host_Select_HostID_HostName 
	@IsActive nchar(1) = 'Y'
AS
BEGIN
	SET NOCOUNT ON;

	SELECT HostID, HostName FROM Windows.Host
	WHERE IsActive = @IsActive;
END
GO
INSERT INTO Windows.Host (HostName) VALUES ('dev1')


CREATE TABLE [Windows].[Instance](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[HostID] [int] NOT NULL,
	[InstanceName] [nvarchar](30) NULL,
	[InstanceEdition] [nvarchar](50) NULL,
	[InstanceVersion] [nchar](20) NULL,
	[InstanceServicePack] [nvarchar](20) NULL,
	[IsActive] [nchar](1) NOT NULL,
	[LastUpdate] [datetime2] NULL
 CONSTRAINT [PK_Host] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG],
 CONSTRAINT [UNQ_InstanceName] UNIQUE NONCLUSTERED 
(
	[InstanceName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG]
) ON [DefFG]

GO

ALTER TABLE [Windows].[Instance]  WITH CHECK ADD  CONSTRAINT [CK_Instance_IsActive] CHECK  (([IsActive]='N' OR [IsActive]='n' OR [IsActive]='Y' OR [IsActive]='y'))
GO

ALTER TABLE [Windows].[Instance] CHECK CONSTRAINT [CK_Instance_IsActive]
GO

ALTER TABLE [Windows].[Instance] ADD  CONSTRAINT [DF_Instance_IsActive]  DEFAULT ('Y') FOR [IsActive]
GO

ALTER TABLE [Windows].[Instance] ADD CONSTRAINT [DF_Instance_LastUpdate] DEFAULT (getdate()) FOR [LastUpdate]
GO

CREATE TABLE [Windows].[DiskInfo](
[DiskSID] [int] IDENTITY(1,1) NOT NULL,
[HostID] [int] NOT NULL,
[DiskPath] [nvarchar](300) NOT NULL,
[DiskFormat] [nvarchar](25) NOT NULL,
[DiskLabel] [nvarchar](100) NULL,
[DiskSizeGB] [int] NOT NULL,
[DiskFreeGB] [int] NOT NULL,
[DiskUsedGB] AS ([DiskSizeGB]-[DiskFreeGB]) PERSISTED,
[CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__DiskInfo_DiskSID] PRIMARY KEY CLUSTERED
(
[DiskSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [DefFG]
) ON [DefFG]
 
GO
 
SET ANSI_PADDING OFF
GO
 
ALTER TABLE [Windows].[DiskInfo] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[DiskInfo] WITH CHECK ADD CONSTRAINT [fk__DiskInfo_HostID] FOREIGN KEY([HostID])
REFERENCES [Windows].[MasterServerList] ([HostID])
GO
 
ALTER TABLE [Windows].[DiskInfo] CHECK CONSTRAINT [fk__DiskInfo_HostID]
GO
 
ALTER TABLE [Windows].[DiskInfo] WITH CHECK ADD CONSTRAINT [ck__DiskInfo_DiskSizes] CHECK (([DiskUsedGB]>=(0) AND [DiskSizeGB]>=(0) AND [DiskFreeGB]>=(0)))
GO
 
ALTER TABLE [Windows].[DiskInfo] CHECK CONSTRAINT [ck__DiskInfo_DiskSizes]
GO
 
/****** Object: Table [Windows].[DbFileStats] Script Date: 4/10/2013 11:27:42 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [Windows].[DbFileStats](
[DbFileStatsSID] [int] IDENTITY(1,1) NOT NULL,
[HostID] [int] NOT NULL,
[DbName] [sysname] NOT NULL,
[FileLogicalName] [sysname] NOT NULL,
[FilePhysicalName] [sysname] NOT NULL,
[FileSizeInGB] [numeric](18, 4) NOT NULL,
[SizeFreeInGB] [numeric](18, 4) NOT NULL,
[CollectionDate] [datetime2] NOT NULL,
CONSTRAINT [pk__DbFileStatsSID_SID] PRIMARY KEY CLUSTERED
(
[DbFileStatsSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [DefFG]
) ON [DefFG]
 
GO
 
ALTER TABLE [Windows].[DbFileStats] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[DbFileStats] WITH CHECK ADD FOREIGN KEY([HostID])
REFERENCES [Windows].[MasterServerList] ([HostID])
GO
 
 
USE [DBAWindows]
GO
 
/****** Object: Table [Windows].[TableStats] Script Date: 4/10/2013 11:28:04 PM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [Windows].[TableStats](
[TableStatsSID] [int] IDENTITY(1,1) NOT NULL,
[HostID] [int] NOT NULL,
[DbName] [sysname] NOT NULL,
[SchemaName] [sysname] NOT NULL,
[TableName] [sysname] NOT NULL,
[TotalRowCount] [bigint] NOT NULL,
[DataSizeInGB] [numeric](18, 4) NOT NULL,
[IndexSizeInGB] [numeric](18, 4) NOT NULL,
[CollectionDate] [smalldatetime] NOT NULL,
CONSTRAINT [pk__TableStatsSID_SID] PRIMARY KEY CLUSTERED
(
[TableStatsSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [DefFG]
) ON [DefFG]
 
GO
 
ALTER TABLE [Windows].[TableStats] ADD DEFAULT (getdate()) FOR [CollectionDate]
GO
 
ALTER TABLE [Windows].[TableStats] WITH CHECK ADD FOREIGN KEY([HostID])
REFERENCES [Windows].[MasterServerList] ([HostID])
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Windows].[FK_HostDiskInfo_HostID]') AND parent_object_id = OBJECT_ID(N'[Windows].[HostDiskInfo]'))
ALTER TABLE [Windows].[HostDiskInfo] DROP CONSTRAINT [FK_HostDiskInfo_HostID]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Windows].[CK_HostDiskInfo_DriverLetter]') AND parent_object_id = OBJECT_ID(N'[Windows].[HostDiskInfo]'))
ALTER TABLE [Windows].[HostDiskInfo] DROP CONSTRAINT [CK_HostDiskInfo_DriverLetter]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_HostDiskInfo_collectionTime]') AND type = 'D')
BEGIN
ALTER TABLE [Windows].[HostDiskInfo] DROP CONSTRAINT [DF_HostDiskInfo_collectionTime]
END

GO

/****** Object:  Table [Windows].[HostDiskInfo]    Script Date: 06/05/2012 17:23:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Windows].[HostDiskInfo]') AND type in (N'U'))
DROP TABLE [Windows].[HostDiskInfo]
GO

/****** Object:  Table [Windows].[HostDiskInfo]    Script Date: 06/05/2012 17:23:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Windows].[HostDiskInfo](
	[HostDiskInfoSID] [int] IDENTITY(1,1) NOT NULL,
	[HostID] [int] NOT NULL,
	[DriveLetter] [char](1) NOT NULL,
	[DiskFormat] [varchar](10) NULL,
	[DiskLabel] [varchar](50) NULL,
	[DiskTotalSizeInGB] [int] NOT NULL,
	[DiskAvailableSizeInGB] [int] NOT NULL,
	[CollectionTime] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_HostDiskInfo] PRIMARY KEY CLUSTERED 
(
	[HostDiskInfoSID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [Windows].[HostDiskInfo]  WITH CHECK ADD  CONSTRAINT [FK_DiskInfo_HostID] FOREIGN KEY([HostID])
REFERENCES [Windows].[Host] ([HostID])
GO

ALTER TABLE [Windows].[HostDiskInfo] CHECK CONSTRAINT [FK_HostDiskInfo_HostID]
GO

ALTER TABLE [Windows].[HostDiskInfo]  WITH CHECK ADD  CONSTRAINT [CK_HostDiskInfo_DriverLetter] CHECK  (([DriveLetter]>='a' AND [driveLetter]<='z'))
GO

ALTER TABLE [Windows].[HostDiskInfo] CHECK CONSTRAINT [CK_HostDiskInfo_DriverLetter]
GO

ALTER TABLE [Windows].[HostDiskInfo] ADD  CONSTRAINT [DF_HostDiskInfo_collectionTime]  DEFAULT (getdate()) FOR [CollectionTime]
GO


/****** Object:  StoredProcedure [Windows].[SelectHostID_Name_WMIError]    Script Date: 06/05/2012 17:23:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Windows].[SelectHostID_Name_WMIError]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Windows].[SelectHostID_Name_WMIError]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Windows].[SelectHostID_Name_WMIError] 

AS

SELECT HostID
	, HostName
	, WMIError
FROM Windows.Host
WHERE OS = 'Windows' and Active = 'Y'
ORDER BY HostName

GO

/****** Object:  StoredProcedure [Windows].[InsertHostDiskInfo]    Script Date: 06/05/2012 17:24:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Windows].[InsertWindowsHostDiskInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Windows].[InsertWindowsHostDiskInfo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
CREATE procedure [Windows].[InsertWindowsHostDiskInfo] 
 	@HostID [int],
	@DriveLetter [char](1),
	@DiskFormat [varchar](10),
	@DiskLabel [varchar](50),
	@DiskTotalSizeInGB [int],
	@DiskAvailableSizeInGB [int]
AS

--INSERT INTO serverDiskInfo (serverName, driveLetter, diskFormat, diskLabel, diskTotalSizeInGB, diskAvailableSizeInGB) VALUES 
--('serverName', 'C', 'NTFS', '', 136.69, 52.31)

INSERT INTO Windows.WindowsHostDiskInfo (
	HostID
	, DriveLetter
	, DiskFormat
	, DiskLabel
	, DiskTotalSizeInGB
	, DiskAvailableSizeInGB) 
VALUES (
	@HostID
	, @DriveLetter
	, @DiskFormat
	, @DiskLabel
	, @DiskTotalSizeInGB
	, @DiskAvailableSizeInGB)
GO
