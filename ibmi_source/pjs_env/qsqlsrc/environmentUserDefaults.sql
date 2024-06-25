CREATE OR REPLACE TABLE DTA_LIB/environmentUserDefaults FOR SYSTEM NAME PUIPJSUDF (
	id varchar(36) ALLOCATE(36) CCSID 37 NOT NULL,
	userName varchar(25) ALLOCATE(25) CCSID 37 NOT NULL,
	initialMenu varchar(10) ALLOCATE(10) CCSID 37 NOT NULL,
	initialMenuLibrary varchar(10) ALLOCATE(10) CCSID 37 NOT NULL,
	initialProgram varchar(10) ALLOCATE(10) CCSID 37 NOT NULL,
	initialProgramLibrary varchar(10) ALLOCATE(10) CCSID 37 NOT NULL,
	defaultEnvironmentName FOR dftEnvName varchar(20) ALLOCATE(20) CCSID 37 NOT NULL,
  allowChangeEnvironment smallint NOT NULL DEFAULT 0,
  isGenieOnly smallint NOT NULL DEFAULT 0,
  workstnid varchar(10) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
	suffixid smallint NOT NULL DEFAULT 0,
	disabled smallint NOT NULL DEFAULT 0,
  tsAdded TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  addedByUser FOR addByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsLastChange FOR tslstchg TIMESTAMP WITH DEFAULT CURRENT TIMESTAMP,
  lastChangeUser FOR updByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
  tsDisabled FOR tsdisable TIMESTAMP WITH DEFAULT '0001-01-01 00:00:00.000000',
  disabledByUser FOR disByUser varchar(25) ALLOCATE(10) CCSID 37 NOT NULL DEFAULT '',
    CONSTRAINT DTA_LIB/environmentUserDefaults PRIMARY KEY ( id )
);

LABEL ON COLUMN DTA_LIB/environmentUserDefaults
(
 id                      TEXT IS 'Id',
 userName                TEXT IS 'User Name',
 initialMenu             TEXT IS 'Initial Menu',
 initialMenuLibrary      TEXT IS 'Initial Menu Library',
 initialProgram          TEXT IS 'Initial Program',
 initialProgramLibrary   TEXT IS 'Initial Program Library',
 defaultEnvironmentName  TEXT IS 'Default Environment Name',
 allowChangeEnvironment  TEXT IS 'Allow Change Environment (PICK_ENV)',
 isGenieOnly             TEXT IS 'Is Genie Only',
 disabled                TEXT IS 'Disabled',
 workstnid               TEXT IS 'Default Workstation Id',
 suffixid                TEXT IS 'Apply Workstation Suffixes',
 tsAdded                 TEXT IS 'Timestamp           Added',
 addedByUser             TEXT IS 'Added by            User',
 tsLastChange            TEXT IS 'Timestamp           Last                Updated',
 lastChangeUser          TEXT IS 'Last Updated        by User',
 tsDisabled              TEXT IS 'Timestamp           Disabled',
 disabledByUser          TEXT IS 'Disabled            by User'
);

LABEL ON COLUMN DTA_LIB/environmentUserDefaults
(
 id                      IS 'Id',
 userName                IS 'User Name',
 initialMenu             IS 'Initial Menu',
 initialMenuLibrary      IS 'Initial Menu Library',
 initialProgram          IS 'Initial Program',
 initialProgramLibrary   IS 'Initial Program Library',
 defaultEnvironmentName  IS 'Default Environment Name',
 allowChangeEnvironment  IS 'Allow Change Environment (PICK_ENV)',
 isGenieOnly             IS 'Is                  Genie               Only',
 disabled                IS 'Disabled',
 workstnid               IS 'Default             Workstation         Id',
 suffixid                IS 'Apply               Workstation         Suffixes',
 tsAdded                 IS 'Timestamp           Added',
 addedByUser             IS 'Added by            User',
 tsLastChange            IS 'Timestamp           Last                Updated',
 lastChangeUser          IS 'Last Updated        by User',
 tsDisabled              IS 'Timestamp           Disabled',
 disabledByUser          IS 'Disabled            by User'
);

LABEL ON TABLE DTA_LIB/environmentUserDefaults IS 'PUI/PJS Environment User Defaults';

ALTER TABLE DTA_LIB/environmentUserDefaults ADD CONSTRAINT CK_ENVUSRDFT_UNIQUE_userName UNIQUE(userName);

--GRANT ALTER , DELETE , INDEX , INSERT , REFERENCES , SELECT , UPDATE
--ON DTA_LIB/environmentUserDefaults TO PUBLIC ;

DROP INDEX IF EXISTS DTA_LIB/environmentUserDefaultsI2 ;
CREATE INDEX DTA_LIB/environmentUserDefaultsI2 FOR SYSTEM NAME PUIPJSUDI2 ON DTA_LIB/environmentUserDefaults ( id );
