**Free
       //========================================================================*
       //
       // *NOTE:  CHGOBJOWN OBJ(PJS_ENV/SETPJSENV) OBJTYPE(*PGM) NEWOWN(AMAPICS)
       //
       // PROGRAM NAME...: setPjsEnv - Set PJS Enviorment
       // AUTHOR.........: Profound Logic Software, Inc.
       // DATE...........: 06/09/2023
       // PCR #..........:
       // FUNCTION/DESC..:
       //    This program will setup the PJS environment variables
       //    for a specific environment.
       //------------------------------------------------------------------------
       //    MODIFICATIONS:
       //------------------------------------------------------------------------
       // MOD#  PCR#    PGMR   DATE   DESCRIPTION
       //
       //========================================================================*

  Ctl-Opt Option(*NODEBUGIO:*SRCSTMT) ActGrp(*NEW);

  dcl-pr qcmdexc extpgm('QCMDEXC');
    cmdStr char(500) const options(*varsize);
    cmdlength packed(15:5) const;
  end-pr;

  dcl-pr getenv pointer extproc('getenv');
    name pointer value options(*string);
  end-pr;

  dcl-pr puisetenv extpgm('PROFOUNDUI/PUISETENV');
    isGenie ind options(*nopass);
  end-pr;

  dcl-s settings char(125) dim(7);
  dcl-s isgenie ind;
  dcl-s varptr pointer;
  dcl-s cmd char(200);
  dcl-s clibl char(32702);
  dcl-c q '''';
  dcl-s msg Char(50);

  dcl-ds envData qualified;
    id varchar(36);
    environmentName varchar(20);
    environmentDesc varchar(100) ;
    jobDescription varchar(21);
    puiProtocol varchar(10) ;
    puiHost varchar(200);
    puiPort char(5);
    pjsProtocol varchar(10);
    pjsHost varchar(200);
    pjsPort char(5);
  End-Ds;

  dcl-ds envCommandData qualified;
    command  Char(300);
    continueOnErrors int(5);
  End-Ds;

  dcl-ds psds PSDS;
    jobName char(10) pos(244);
  End-Ds;

  dcl-s SqlStmt Char(500);
  dcl-s SqlStmt2 Char(500);
  dcl-s environmentName Char(20);
  dcl-s environmentDataLibraryName Char(10);
  dcl-s environmentObjectLibraryName Char(10);
  dcl-s commSecure Char(1) inz('0');
  dcl-s i int(5);

  dcl-s libl varchar(2750);
  dcl-s jobd varchar(21);

  //-------------------------------------------------------------------------
  //
  //  Main Procedure
  //
  //-------------------------------------------------------------------------
  settings(1) = 'ADDENVVAR ENVVAR(PROFOUNDJS_DEFAULTJOBD) VALUE(''%jobd'') REPLACE(*YES)';

  settings(2) = 'ADDENVVAR ENVVAR(PROFOUNDJS_COMM_KEYRING) VALUE(*SYSTEM) REPLACE(*YES)';
  settings(3) = 'ADDENVVAR ENVVAR(PROFOUNDJS_COMM_SECURE) VALUE(%config_ssl) REPLACE(*YES)';
  settings(4) = 'ADDENVVAR ENVVAR(PROFOUNDJS_COMM_HOST) VALUE(''%pjs_host'') REPLACE(*YES)';
  settings(5) = 'ADDENVVAR ENVVAR(PROFOUNDJS_COMM_PORT) VALUE(%pjs_port) REPLACE(*YES)';
  settings(6) = 'ADDENVVAR ENVVAR(PROFOUNDUI_GENIE_URL) ' +
    ' VALUE(''%pui_protocol://%pui_host:%pui_port/profoundui/genie'') REPLACE(*YES)';
  settings(7) = 'ADDENVVAR ENVVAR(INSTANCE_ID) VALUE(''%instance_id'') REPLACE(*YES)';

  // Retrieve ProfoundJS Environment Data Library.
  varptr = getenv('PROFOUNDJS_ENVIRONMENT_DATA_LIBRARY');
  if varptr <> *null;
    environmentDataLibraryName = %str(varptr);
  endif;

  // Add Profoundjs Environment Data Library to Library List.
  addlible( environmentDataLibraryName : '*FIRST');

  // Retrieve ProfoundJS Environment Object Library.
  varptr = getenv('PROFOUNDJS_ENVIRONMENT_OBJECT_LIBRARY');
  if varptr <> *null;
    environmentObjectLibraryName = %str(varptr);
  endif;

  // Add Profoundjs Environment Program Library to Library List.
  addlible( environmentObjectLibraryName : '*FIRST');

  // Retrieve the ProfoundJS Environment Name.
  varptr = getenv('PROFOUNDJS_ENVIRONMENT_NAME');
  if varptr <> *null;
    environmentName = %str(varptr);
  endif;

  SqlStmt =
    'Select id, environmentName, environmentDesc, jobDescription, puiProtocol, ' +
    'puiHost, puiPort, pjsProtocol, pjsHost, ' +
    'pjsPort ' +
    'From Environments ' +
    ' Where environmentName = upper(' + q + %Trim(environmentName) + q + ')' +
    '  and disabled = 0' ;

  Exec Sql Declare C1 Cursor For Sqlstmt;
  Exec Sql Prepare Sqlstmt From :Sqlstmt;
  Exec Sql Open C1;

  dou SqlCod <> *Zero;
    Exec Sql Fetch Next From C1 Into :envData;

    if SqlCod <> *zero;
      leave;
    endif;

    // Run Additional Environment Commands where
    // chronology = 'B' (Before Environment Commands)
    runEnvironmentCommands('B');

    // set Environment
    setEnvironment();

    // Run Additional Environment Commands where
    // chronology = 'A' (After Environment Commands)
    runEnvironmentCommands('A');

  enddo;
  Exec Sql Close C1;

  *inlr = *on;

//-------------------------------------------------------------------------
  dcl-proc setEnvironment;

    // Set Library List based on Job Description FIRST
    cmd = %ScanRpl('%jobd' : %Trim(envData.jobDescription) : settings(1));
    qcmdexc(cmd:%len(%trim(cmd)));
    snd-msg %trim(cmd);

    // Set Job Library List to environment
    setLibraryList();

    // Set Additional Environment Variables
    for i = 2 to %elem(settings);

      cmd = %ScanRpl('%jobd' : %Trim(envData.jobDescription) : settings(i));

      cmd = %ScanRpl('%pui_protocol' : %Trim(envData.puiProtocol) : cmd);
      cmd = %ScanRpl('%pui_host'     : %Trim(envData.puiHost)   : cmd);
      cmd = %ScanRpl('%pui_port'     : %Trim(envData.puiPort)   : cmd);

      cmd = %ScanRpl('%pjs_port'     : %Trim(envData.pjsPort)   : cmd);
      cmd = %ScanRpl('%pjs_host'     : %Trim(envData.pjsHost)   : cmd);

      cmd = %ScanRpl('%instance_id'  : %Trim(envData.environmentName) : cmd);

      if %Scan('%config_ssl' : cmd )  > 0;
        if %lower(envData.pjsProtocol) = 'https';
          commSecure = '1';
        endif;
        cmd = %ScanRpl('%config_ssl'  : commSecure : cmd);
      endif;

      qcmdexc(cmd:%len(%trim(cmd)));
      snd-msg %trim(cmd);
    endfor;

  end-proc;
//-------------------------------------------------------------------------
  dcl-proc runEnvironmentCommands;
    dcl-pi *n;
    chronology char(1) const;
  end-pi;

  SqlStmt2 =
    'Select command, continueOnErrors ' +
    'From EnvironmentCommands ' +
    ' Where environmentId = ' + q + %Trim(envData.id) + q +
    ' and disabled = 0 ' +
    'and chronology = ' + q + chronology + q +
    ' order by commandSequence';

  Exec Sql Declare C2 Cursor For Sqlstmt2;
  Exec Sql Prepare Sqlstmt2 From :Sqlstmt2;
  Exec Sql Open C2;

  dou SqlCod <> *Zero;
    Exec Sql Fetch Next From C2 Into :envCommandData;

    if SqlCod <> *zero;
      leave;
    endif;

    if envCommandData.continueOnErrors = 1;
      monitor;
        qcmdexc(envCommandData.command:%len(%trim(envCommandData.command)));
        snd-msg %trim(envCommandData.command);
      on-error;
      endmon;

    else;    // If the command fails - Hard Error.
      qcmdexc(envCommandData.command:%len(%trim(envCommandData.command)));
      snd-msg %trim(envCommandData.command);
    endif;

  enddo;

  Exec Sql Close C2;

  end-proc;
//-------------------------------------------------------------------------

  dcl-proc addlible;
    dcl-pi *n;
     lib char(10) const;
     pos char(99) const;
    end-pi;

  if (lib <> ' ');
    monitor;
      cmd = 'ADDLIBLE LIB(' + %trim(lib) +
            ') POSITION(' + %trim(pos) + ')';
      callp qcmdexc(cmd:%len(cmd));
    on-error;
    endmon;
  endif;
  end-proc;

// -------------------------------------------------------------------------
  dcl-proc setLibraryList;

      varptr = getenv('PROFOUNDJS_DEFAULTJOBD');
      if varptr <> *null;
        jobd = %str(varptr);
      endif;

      // Set the library list for this job
      if (jobd <> *blanks);
        Exec Sql
        Select 'CHGLIBL LIBL(' || trim(LIBRARY_LIST) || ')' Into :clibl
        From   qsys2.jobd_info
        Where  (Trim(JOB_DESCRIPTION_LIBRARY)||'/'||Trim(JOB_DESCRIPTION)) = :jobd;
        if (clibl <> *blanks);
          monitor;
            callp qcmdexc(clibl:%len(clibl));
          on-error;
            snd-msg '*SETPJSENV: Failed to set Library List using JOBD ' + %Trim(jobd);
          endmon;
        endif;
      endif;

  end-proc;

