CREATE OR REPLACE TABLE DTA_LIB/EnvironmentCommands FOR SYSTEM NAME PUIPJSENC (
	id varchar(36) ALLOCATE(36) CCSID 37 NOT NULL,
	environmentid FOR envId varchar(36) ALLOCATE(36) CCSID 37,
	commandSequence FOR cmdSeq smallint NOT NULL DEFAULT 0,
	command varchar(300) ALLOCATE(100) CCSID 37 DEFAULT ' ' NOT NULL,
  chronology char(1) DEFAULT 'A' NOT NULL,
	disabled smallint NOT NULL DEFAULT 0,
	continueOnErrors smallint NOT NULL DEFAULT 0,
  tsAdded TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  addedByUser FOR addByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsLastChange FOR tslstchg TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  lastChangeUser FOR updByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsDisabled FOR tsdisable TIMESTAMP WITH DEFAULT '0001-01-01 00:00:00.000000',
  disabledByUser FOR disByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
    CONSTRAINT DTA_LIB/EnvironmentCommands PRIMARY KEY ( id )
);

LABEL ON COLUMN DTA_LIB/EnvironmentCommands
(
 id                 TEXT IS 'Id',
 environmentid      TEXT IS 'Environment Id',
 commandSequence    TEXT IS 'Command Sequence',
 command            TEXT IS 'Command to Execute',
 chronology         TEXT IS 'Command Chronology (A=After, B=Before)',
 disabled           TEXT IS 'Disabled',
 continueOnErrors   TEXT IS 'Continue On-Errors',
 tsAdded            TEXT IS 'Timestamp           Added',
 addedByUser        TEXT IS 'Added by            User',
 tsLastChange       TEXT IS 'Timestamp           Last                Updated',
 lastChangeUser     TEXT IS 'Last Updated        by User',
 tsDisabled         TEXT IS 'Timestamp           Disabled',
 disabledByUser     TEXT IS 'Disabled            by User'
);

LABEL ON COLUMN DTA_LIB/EnvironmentCommands
(
 id                 IS 'Id',
 environmentid      IS 'Environment         Id',
 commandSequence    IS 'Command             Sequence',
 command            IS 'Command             to Execute',
 chronology         IS 'Command Chronology  (A=After, B=Before)',
 disabled           IS 'Disabled',
 continueOnErrors   IS 'Continue            On-Errors',
 tsAdded            IS 'Timestamp           Added',
 addedByUser        IS 'Added by            User',
 tsLastChange       IS 'Timestamp           Last                Updated',
 lastChangeUser     IS 'Last Updated        by User',
 tsDisabled         IS 'Timestamp           Disabled',
 disabledByUser     IS 'Disabled            by User'
);

LABEL ON TABLE DTA_LIB/EnvironmentCommands IS 'PUI/PJS Environment Commands';

--GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
--ON DTA_LIB/EnvironmentCommands TO PUBLIC ;

ALTER TABLE DTA_LIB/EnvironmentCommands ADD FOREIGN KEY DTA_LIB/FK_environmentCommands_id ( environmentid ) REFERENCES DTA_LIB/Environments( id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE DTA_LIB/EnvironmentCommands ADD CONSTRAINT DTA_LIB/CK_FK_environmentCommands_disabled CHECK(disabled IN ( 1 , 0 ));

ALTER TABLE DTA_LIB/EnvironmentCommands ADD CONSTRAINT DTA_LIB/CK_FK_environmentCommands_continueOnErrors CHECK(continueOnErrors IN ( 1 , 0 ));

DROP INDEX IF EXISTS DTA_LIB/EnvironmentCommands_I1 ;
CREATE INDEX DTA_LIB/EnvironmentCommands_I1 FOR SYSTEM NAME PUIPJSECI1 ON DTA_LIB/EnvironmentCommands ( environmentid );

DROP INDEX IF EXISTS DTA_LIB/Environments_I2 ;
CREATE INDEX DTA_LIB/Environments_I2 FOR SYSTEM NAME PUIPJSECI2 ON DTA_LIB/EnvironmentCommands ( id );
