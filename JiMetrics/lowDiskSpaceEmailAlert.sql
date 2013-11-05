-- Scan storage table for today's disk data collection and send alerts out for disks that have less than 25% free space.
DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
    N'<H1>Low disk space report</H1>' +
    N'<table border="1">' +
    N'<tr><th>ServerName</th><th>DiskPath</th>' +
    N'<th>DiskSizeGB</th><th>DiskFreeGB</th><th>PercentFree</th>' +
    N'<th>DiskLabel</th></tr>' +
    CAST ( ( SELECT td = substring(h.hostname, 1, charindex('.', h.hostname) - 1), '',
       td = s.diskpath, '',
       td = s.disksizegb, '',
       td = s.diskfreegb, '',
       td = cast ((Cast(diskfreegb AS NUMERIC) / disksizegb ) * 100 as integer), '',
       td = s.disklabel
FROM   JiMetrics.Windows.Storage s
       INNER JOIN JiMetrics.Windows.Host h
               ON s.HostID = h.HostID
WHERE  collectiondate > CONVERT(CHAR(8), Getdate(), 112)
       AND ( ( Cast(diskfreegb AS NUMERIC) / disksizegb ) * 100 ) < 25
       AND disksizegb > 0
ORDER  BY h.hostname
    , (Cast(diskfreegb AS NUMERIC) / disksizegb ) * 100
              FOR XML PATH('tr'), TYPE
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

EXEC msdb.dbo.sp_send_dbmail @recipients='me@myemail.com',
    @subject = 'Disk space alert',
    @body = @tableHTML,
    @body_format = 'HTML' ;
