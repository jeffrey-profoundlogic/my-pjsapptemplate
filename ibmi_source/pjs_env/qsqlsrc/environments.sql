CREATE OR REPLACE TABLE DTA_LIB/Environments FOR SYSTEM NAME PUIPJSENV (
	id varchar(36) ALLOCATE(36) CCSID 37 NOT NULL,
	environmentName FOR envName varchar(20) ALLOCATE(20) CCSID 37 DEFAULT ' ' NOT NULL,
	environmentDesc FOR envDesc varchar(100) ALLOCATE(100) CCSID 37 DEFAULT ' ' NOT NULL,
	jobDescription FOR jobDesc varchar(21) ALLOCATE(21) CCSID 37 DEFAULT ' ' NOT NULL,
	puiProtocol FOR puiProtol varchar(10) ALLOCATE(10) CCSID 37 DEFAULT ' ' NOT NULL,
	puiHost varchar(200) ALLOCATE(50) CCSID 37 DEFAULT ' ' NOT NULL,
	puiPort char(5) CCSID 37 DEFAULT ' ' NOT NULL,
	pjsProtocol FOR pjsProtol varchar(10) ALLOCATE(10) CCSID 37 DEFAULT ' ' NOT NULL,
	pjsHost varchar(200) ALLOCATE(50) CCSID 37 DEFAULT ' ' NOT NULL,
	pjsPort char(5) CCSID 37 DEFAULT ' ' NOT NULL,
	disabled smallint NOT NULL DEFAULT 0,
  tsAdded TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  addedByUser FOR addByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsLastChange FOR tslstchg TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  lastChangeUser FOR updByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsDisabled FOR tsdisable TIMESTAMP WITH DEFAULT '0001-01-01 00:00:00.000000',
  disabledByUser FOR disByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
    CONSTRAINT DTA_LIB/Environments PRIMARY KEY ( id )
);

LABEL ON TABLE DTA_LIB/Environments IS 'PUI/PJS Environments';

LABEL ON COLUMN DTA_LIB/Environments
(
 id                 TEXT IS 'Id',
 environmentName    TEXT IS 'Environment Name',
 environmentDesc    TEXT IS 'Environment Description',
 jobDescription     TEXT IS 'Job Description',
 puiProtocol        TEXT IS 'PUI Protocol (http/https)',
 puiHost            TEXT IS 'PUI Host Name or IP Address',
 puiPort            TEXT IS 'PUI Port Number',
 pjsProtocol        TEXT IS 'PJS Protocol (http/https)',
 pjsHost            TEXT IS 'PJS Host Name or IP Address',
 pjsPort            TEXT IS 'PJS Port Number',
 disabled           TEXT IS 'Disabled',
 tsAdded            TEXT IS 'Timestamp           Added',
 addedByUser        TEXT IS 'Added by            User',
 tsLastChange       TEXT IS 'Timestamp           Last                Updated',
 lastChangeUser     TEXT IS 'Last Updated        by User',
 tsDisabled         TEXT IS 'Timestamp           Disabled',
 disabledByUser     TEXT IS 'Disabled            by User'
);

LABEL ON COLUMN DTA_LIB/Environments
(
 id                 IS 'Id',
 environmentName    IS 'Environment         Name                X',
 environmentDesc    IS 'Environment         Description',
 jobDescription     IS 'Job                 Description',
 puiProtocol        IS 'PUI                 Protocol            (http/https)',
 puiHost            IS 'PUI                 Host Name           or IP Address',
 puiPort            IS 'PUI                 Port                Number',
 pjsProtocol        IS 'PJS                 Protocol            (http/https)',
 pjsHost            IS 'PJS                 Host Name           or IP Address',
 pjsPort            IS 'PJS                 Port                Number',
 disabled           IS 'Disabled',
 tsAdded            IS 'Timestamp           Added',
 addedByUser        IS 'Added by            User',
 tsLastChange       IS 'Timestamp           Last                Updated',
 lastChangeUser     IS 'Last Updated        by User',
 tsDisabled         IS 'Timestamp           Disabled',
 disabledByUser     IS 'Disabled            by User'
);

--GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
--ON DTA_LIB/Environments TO PUBLIC ;

ALTER TABLE DTA_LIB/Environments ADD CONSTRAINT DTA_LIB/CK_FK_Environments_disabled CHECK(disabled IN ( 1 , 0 ));

DROP INDEX IF EXISTS DTA_LIB/Environments_i1 ;
CREATE INDEX DTA_LIB/Environments_i1 FOR SYSTEM NAME PUIPJSENI1 ON DTA_LIB/Environments ( id );

alter table DTA_LIB.environments add notes varchar(255) ;
label on column DTA_LIB.environments (notes is 'Notes');

alter table DTA_LIB.puipjsenc add notes varchar(255) ;
label on column DTA_LIB.puipjsenc (notes is 'Notes');