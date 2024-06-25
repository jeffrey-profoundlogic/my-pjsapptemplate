CREATE OR REPLACE TABLE DTA_LIB/EnvironmentUserMapicsWorkstations FOR SYSTEM NAME PUIPJSEMW (
  userid varchar(36) ALLOCATE(36) CCSID 37 NOT NULL,
  id varchar(36) ALLOCATE(36) CCSID 37 NOT NULL,
	sequence smallint NOT NULL DEFAULT 0,
  workstnid varchar(10) ALLOCATE(10) CCSID 37 NOT NULL,
	disabled smallint NOT NULL DEFAULT 0,
  tsAdded TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  addedByUser FOR addByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsLastChange FOR tslstchg TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  lastChangeUser FOR updByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsDisabled FOR tsdisable TIMESTAMP WITH DEFAULT '0001-01-01 00:00:00.000000',
  disabledByUser FOR disByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
    CONSTRAINT DTA_LIB/EnvironmentUserMapicsWorkstations PRIMARY KEY ( id )
);

LABEL ON COLUMN DTA_LIB/EnvironmentUserMapicsWorkstations
(
 userid             TEXT IS 'User Id',
 id                 TEXT IS 'Id',
 sequence           TEXT IS 'Sequence',
 workstnid          TEXT IS 'MAPICS Workstation Id',
 disabled           TEXT IS 'Disabled',
 tsAdded            TEXT IS 'Timestamp           Added',
 addedByUser        TEXT IS 'Added by            User',
 tsLastChange       TEXT IS 'Timestamp           Last                Updated',
 lastChangeUser     TEXT IS 'Last Updated        by User',
 tsDisabled         TEXT IS 'Timestamp           Disabled',
 disabledByUser     TEXT IS 'Disabled            by User'
);

LABEL ON COLUMN DTA_LIB/EnvironmentUserMapicsWorkstations
(
 userid             IS 'User Id',
 id                 IS 'Id',
 sequence           IS 'Sequence',
 workstnid          IS 'MAPICS              Workstation         Id',
 disabled           IS 'Disabled',
 tsAdded            IS 'Timestamp           Added',
 addedByUser        IS 'Added by            User',
 tsLastChange       IS 'Timestamp           Last                Updated',
 lastChangeUser     IS 'Last Updated        by User',
 tsDisabled         IS 'Timestamp           Disabled',
 disabledByUser     IS 'Disabled            by User'
);

LABEL ON TABLE DTA_LIB/EnvironmentUserMapicsWorkstations IS 'PUI/PJS Environment User Mapics Workstations';

--GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
--ON DTA_LIB/EnvironmentUserMapicsWorkstations TO PUBLIC ;

ALTER TABLE DTA_LIB/EnvironmentUserMapicsWorkstations ADD FOREIGN KEY DTA_LIB/FK_EnvironmentUserMapicsWorkstations_userid ( userid ) REFERENCES DTA_LIB/environmentUserDefaults( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE DTA_LIB/EnvironmentUserMapicsWorkstations ADD CONSTRAINT DTA_LIB/CK_FK_EnvironmentUserMapicsWorkstations_disabled CHECK(disabled IN ( 1 , 0 ));

DROP INDEX IF EXISTS DTA_LIB/EnvironmentUserMapicsWorkstations_I1 ;
CREATE INDEX DTA_LIB/EnvironmentUserMapicsWorkstations_I1 FOR SYSTEM NAME PUIPJSEM3 ON DTA_LIB/EnvironmentUserMapicsWorkstations ( userid );

DROP INDEX IF EXISTS DTA_LIB/EnvironmentUserMapicsWorkstations_I2 ;
CREATE INDEX DTA_LIB/EnvironmentUserMapicsWorkstations_I2 FOR SYSTEM NAME PUIPJSEM2 ON DTA_LIB/EnvironmentUserMapicsWorkstations ( id );



