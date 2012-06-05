USE [DBAMetrics]
GO

IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'Metrics')
DROP SCHEMA [Metrics]
GO

CREATE SCHEMA [Metrics] AUTHORIZATION [dbo]
GO


IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Metrics].[CK_Host_Active]') AND parent_object_id = OBJECT_ID(N'[Metrics].[Host]'))
ALTER TABLE [Metrics].[Host] DROP CONSTRAINT [CK_Host_Active]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Metrics].[CK_Host_OS]') AND parent_object_id = OBJECT_ID(N'[Metrics].[Host]'))
ALTER TABLE [Metrics].[Host] DROP CONSTRAINT [CK_Host_OS]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Metrics].[CK_Host_WMIError]') AND parent_object_id = OBJECT_ID(N'[Metrics].[Host]'))
ALTER TABLE [Metrics].[Host] DROP CONSTRAINT [CK_Host_WMIError]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Host_WMIError]') AND type = 'D')
BEGIN
ALTER TABLE [Metrics].[Host] DROP CONSTRAINT [DF_Host_WMIError]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Host_Active]') AND type = 'D')
BEGIN
ALTER TABLE [Metrics].[Host] DROP CONSTRAINT [DF_Host_Active]
END

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Metrics].[Host]') AND type in (N'U'))
DROP TABLE [Metrics].[Host]
GO

/****** Object:  Table [Metrics].[Host]    Script Date: 06/05/2012 17:23:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [Metrics].[Host](
	[HostSID] [int] IDENTITY(1,1) NOT NULL,
	[HostName] [varchar](20) NOT NULL,
	[Domain] [varchar](50) NOT NULL,
	[OS] [varchar](20) NOT NULL,
	[WMIError] [char](1) NOT NULL,
	[Active] [char](1) NOT NULL,
 CONSTRAINT [PK_Host] PRIMARY KEY CLUSTERED 
(
	[HostSID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG],
 CONSTRAINT [UNQ_HostName] UNIQUE NONCLUSTERED 
(
	[HostName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DefFG]
) ON [DefFG]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [Metrics].[Host]  WITH CHECK ADD  CONSTRAINT [CK_Host_Active] CHECK  (([Active]='N' OR [Active]='n' OR [Active]='Y' OR [Active]='y'))
GO

ALTER TABLE [Metrics].[Host] CHECK CONSTRAINT [CK_Host_Active]
GO

ALTER TABLE [Metrics].[Host]  WITH CHECK ADD  CONSTRAINT [CK_Host_OS] CHECK  (([OS]='Linux' OR [OS]='Windows'))
GO

ALTER TABLE [Metrics].[Host] CHECK CONSTRAINT [CK_Host_OS]
GO

ALTER TABLE [Metrics].[Host]  WITH CHECK ADD  CONSTRAINT [CK_Host_WMIError] CHECK  (([WMIError]='N' OR [WMIError]='n' OR [WMIError]='Y' OR [WMIError]='y'))
GO

ALTER TABLE [Metrics].[Host] CHECK CONSTRAINT [CK_Host_WMIError]
GO

ALTER TABLE [Metrics].[Host] ADD  CONSTRAINT [DF_Host_WMIError]  DEFAULT ('Y') FOR [WMIError]
GO

ALTER TABLE [Metrics].[Host] ADD  CONSTRAINT [DF_Host_Active]  DEFAULT ('Y') FOR [Active]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Metrics].[FK_WindowsHostDiskInfo_HostSID]') AND parent_object_id = OBJECT_ID(N'[Metrics].[WindowsHostDiskInfo]'))
ALTER TABLE [Metrics].[WindowsHostDiskInfo] DROP CONSTRAINT [FK_WindowsHostDiskInfo_HostSID]
GO

IF  EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Metrics].[CK_WindowsHostDiskInfo_DriverLetter]') AND parent_object_id = OBJECT_ID(N'[Metrics].[WindowsHostDiskInfo]'))
ALTER TABLE [Metrics].[WindowsHostDiskInfo] DROP CONSTRAINT [CK_WindowsHostDiskInfo_DriverLetter]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_WindowsHostDiskInfo_collectionTime]') AND type = 'D')
BEGIN
ALTER TABLE [Metrics].[WindowsHostDiskInfo] DROP CONSTRAINT [DF_WindowsHostDiskInfo_collectionTime]
END

GO

/****** Object:  Table [Metrics].[WindowsHostDiskInfo]    Script Date: 06/05/2012 17:23:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Metrics].[WindowsHostDiskInfo]') AND type in (N'U'))
DROP TABLE [Metrics].[WindowsHostDiskInfo]
GO

/****** Object:  Table [Metrics].[WindowsHostDiskInfo]    Script Date: 06/05/2012 17:23:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [Metrics].[WindowsHostDiskInfo](
	[WindowsHostDiskInfoSID] [int] IDENTITY(1,1) NOT NULL,
	[HostSID] [int] NOT NULL,
	[DriveLetter] [char](1) NOT NULL,
	[DiskFormat] [varchar](10) NULL,
	[DiskLabel] [varchar](50) NULL,
	[DiskTotalSizeInGB] [int] NOT NULL,
	[DiskAvailableSizeInGB] [int] NOT NULL,
	[CollectionTime] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_WindowsHostDiskInfo] PRIMARY KEY CLUSTERED 
(
	[WindowsHostDiskInfoSID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [Metrics].[WindowsHostDiskInfo]  WITH CHECK ADD  CONSTRAINT [FK_WindowsHostDiskInfo_HostSID] FOREIGN KEY([HostSID])
REFERENCES [Metrics].[Host] ([HostSID])
GO

ALTER TABLE [Metrics].[WindowsHostDiskInfo] CHECK CONSTRAINT [FK_WindowsHostDiskInfo_HostSID]
GO

ALTER TABLE [Metrics].[WindowsHostDiskInfo]  WITH CHECK ADD  CONSTRAINT [CK_WindowsHostDiskInfo_DriverLetter] CHECK  (([DriveLetter]>='a' AND [driveLetter]<='z'))
GO

ALTER TABLE [Metrics].[WindowsHostDiskInfo] CHECK CONSTRAINT [CK_WindowsHostDiskInfo_DriverLetter]
GO

ALTER TABLE [Metrics].[WindowsHostDiskInfo] ADD  CONSTRAINT [DF_WindowsHostDiskInfo_collectionTime]  DEFAULT (getdate()) FOR [CollectionTime]
GO


/****** Object:  StoredProcedure [Metrics].[SelectHostSID_Name_WMIError]    Script Date: 06/05/2012 17:23:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Metrics].[SelectHostSID_Name_WMIError]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Metrics].[SelectHostSID_Name_WMIError]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Metrics].[SelectHostSID_Name_WMIError] 

AS

SELECT HostSID
	, HostName
	, WMIError
FROM Metrics.Host
WHERE OS = 'Windows' and Active = 'Y'
ORDER BY HostName

GO

/****** Object:  StoredProcedure [Metrics].[InsertWindowsHostDiskInfo]    Script Date: 06/05/2012 17:24:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Metrics].[InsertWindowsHostDiskInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [Metrics].[InsertWindowsHostDiskInfo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
CREATE procedure [Metrics].[InsertWindowsHostDiskInfo] 
 	@HostSID [int],
	@DriveLetter [char](1),
	@DiskFormat [varchar](10),
	@DiskLabel [varchar](50),
	@DiskTotalSizeInGB [int],
	@DiskAvailableSizeInGB [int]
AS

--INSERT INTO serverDiskInfo (serverName, driveLetter, diskFormat, diskLabel, diskTotalSizeInGB, diskAvailableSizeInGB) VALUES 
--('serverName', 'C', 'NTFS', '', 136.69, 52.31)

INSERT INTO Metrics.WindowsHostDiskInfo (
	HostSID
	, DriveLetter
	, DiskFormat
	, DiskLabel
	, DiskTotalSizeInGB
	, DiskAvailableSizeInGB) 
VALUES (
	@HostSID
	, @DriveLetter
	, @DiskFormat
	, @DiskLabel
	, @DiskTotalSizeInGB
	, @DiskAvailableSizeInGB)
GO
