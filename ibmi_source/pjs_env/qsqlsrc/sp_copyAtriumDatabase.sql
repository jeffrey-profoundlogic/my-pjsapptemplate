/* =============================================================================
  Stored procedure to copy Atrium Users/Group/Navigation from one
  PUI Instance to another.

  Clears the following files in the target PUI instance, then copies
  all records from source PUI Instance:

  ATGROUPSP
  ATUSERSP
  ATSUPGRPP
  ATNAVP
  ATNVARSP
  ATCONFIGP
  ATAUTHP

  Updates table ATUIDSP
  AUIFIELD = ‘GRPUSRID’ (next user or group id)
  AUIFIELD = ‘ANITEM’ (next navigation id)

==============================================================================*/
CREATE OR REPLACE PROCEDURE PJS_ENV/sp_copyAtriumDatabase (
    IN sourceInstance VARCHAR(10), -- Source PUI Instance
    IN targetInstance VARCHAR(10)  -- Target PUI Instance
)
LANGUAGE SQL
ALLOW DEBUG MODE
SPECIFIC CPYATRMDB
SET OPTION COMMIT = *NONE
BEGIN
    DECLARE SQLSTATE CHAR(5) DEFAULT '00000';
    DECLARE SQL_STMT VARCHAR(500);

    DECLARE maxAUUSER INT;
    DECLARE maxAGGROUP INT;
    DECLARE maxResult INT;

    -- Declare cursor to fetch TABLE_NAME in the desired order
    DECLARE clearCursor CURSOR FOR
        SELECT 'DELETE FROM ' || targetInstance || '.' || ST.TABLE_NAME
        FROM QSYS2.SYSTABLES ST
        JOIN TableNameOrder TO ON ST.TABLE_NAME = TO.TableName
        WHERE ST.TABLE_SCHEMA = targetInstance
        ORDER BY TO.OrderID;

    -- Load Atrium Files in Target Instance with data from the Source Instance
    DECLARE copyCursor CURSOR FOR
        SELECT 'INSERT INTO ' || targetInstance || '.' || ST.TABLE_NAME ||
         ' SELECT * FROM ' ||
          sourceInstance || '.' || ST.TABLE_NAME
        FROM QSYS2.SYSTABLES ST
        JOIN TableNameOrder TO ON ST.TABLE_NAME = TO.TableName
        WHERE ST.TABLE_SCHEMA = targetInstance
        ORDER BY TO.OrderID;

    DECLARE maxAUCursor CURSOR FOR S1;
    DECLARE maxAGCursor CURSOR FOR S2;

    -- Check if sourceInstance is equal to targetInstance
    IF sourceInstance = targetInstance THEN
        SIGNAL SQLSTATE '70001'
          SET MESSAGE_TEXT = 'Error: Source instance cannot be equal to target instance';
    END IF;

    -- Create a temporary table to store the desired order of TABLE_NAME
    CREATE TABLE QTEMP.TableNameOrder (
        OrderID INT,
        TableName VARCHAR(128)
    );

    -- Insert table names in the desired order
    INSERT INTO QTEMP.TableNameOrder (OrderID, TableName)
    VALUES
        (1, 'ATGROUPSP'),
        (2, 'ATUSERSP'),
        (3, 'ATSUPGRPP'),
        (4, 'ATNAVP'),
        (5, 'ATNVARSP'),
        (6, 'ATCONFIGP'),
        (7, 'ATAUTHP');

    -- Clear Atrium Files in Target Instance before copying new data

    OPEN clearCursor;
    CLEAR_LOOP: LOOP
        FETCH clearCursor INTO SQL_STMT;
        IF SQLSTATE <> '00000' THEN
            LEAVE CLEAR_LOOP;
        END IF;

        -- Prepare dynamic SQL statement
        PREPARE stmt FROM SQL_STMT;

        -- Execute dynamic SQL statement
        EXECUTE stmt;

        -- Deallocate the prepared statement
        -- DEALLOCATE PREPARE stmt;
    END LOOP CLEAR_LOOP;
    CLOSE clearCursor;

    OPEN copyCursor;
    COPY_LOOP: LOOP
        FETCH copyCursor INTO SQL_STMT;
        IF SQLSTATE <> '00000' THEN
            LEAVE COPY_LOOP;
        END IF;

        -- Prepare dynamic SQL statement
        PREPARE stmt FROM SQL_STMT;

        -- Execute dynamic SQL statement
        EXECUTE stmt;

        -- Deallocate the prepared statement
        -- DEALLOCATE PREPARE stmt;
    END LOOP COPY_LOOP;
    CLOSE copyCursor;

    -- Update Next Numbering in Target Instance
    SET SQL_STMT = 'UPDATE ' || targetInstance ||
      '.ATUIDSP SET AUINEXT = (SELECT MAX(ANITEM) + 1 FROM ' ||
      targetInstance || '.ATNAVP) WHERE AUIFIELD = ''ANITEM''';

    -- Prepare dynamic SQL statement
    PREPARE stmt FROM SQL_STMT;

    -- Execute dynamic SQL statement
    EXECUTE stmt;

    -- Deallocate the prepared statement
    -- DEALLOCATE PREPARE stmt;

    -- Retrieve the maximum AUUSER from sourceInstance
    SET SQL_STMT = 'SELECT MAX(AUUSER)+1 FROM ' || targetInstance || '.ATUSERSP';
    PREPARE S1 FROM SQL_STMT;
    OPEN maxAUCursor;
    FETCH maxAUCursor INTO maxAUUSER;
    IF SQLSTATE <> '00000' THEN
      SET maxAUCursor = 1;
    END IF;

    CLOSE maxAUCursor;

    -- Retrieve the maximum AGGROUP from sourceInstance
    SET SQL_STMT = 'SELECT MAX(AGGROUP)+1 FROM ' || targetInstance || '.ATGROUPSP';
    PREPARE S2 FROM SQL_STMT;
    OPEN maxAGCursor ;
    FETCH maxAGCursor  INTO maxAGGROUP;
    IF SQLSTATE <> '00000' THEN
      SET maxAGGROUP  = 1;
    END IF;

    CLOSE maxAGCursor ;

    -- Determine the higher of the two maximum values
    IF maxAUUSER > maxAGGROUP THEN
        SET maxResult = maxAUUSER;
    ELSE
        SET maxResult = maxAGGROUP;
    END IF;

    -- Update Next Numbering in Target Instance
    SET SQL_STMT = 'UPDATE ' || targetInstance || '.ATUIDSP SET AUINEXT = ' ||
      maxResult || ' WHERE AUIFIELD = ''GRPUSRID''';

    -- Prepare dynamic SQL statement
    PREPARE stmt FROM SQL_STMT;

    -- Execute dynamic SQL statement
    EXECUTE stmt;

    -- Deallocate the prepared statement
    -- DEALLOCATE PREPARE stmt;
END
