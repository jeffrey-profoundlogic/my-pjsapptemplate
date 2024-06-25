**Free

  //========================================================================*
  //
  // *NOTE:  CHGOBJOWN OBJ(PJS_ENV/SETPJSENV) OBJTYPE(*PGM) NEWOWN(AMAPICS)
  //
  // PROGRAM NAME...: PICKENV - Pick your desired environment
  // AUTHOR.........: G Hopwood - Profound Logic Software, Inc.
  // DATE...........: 09/2023
  // PCR #..........:
  // FUNCTION/DESC..:
  //    This program will present the suer with a list fo all the
  //     environments and allow them to pick one.
  //------------------------------------------------------------------------
  //    MODIFICATIONS:
  //------------------------------------------------------------------------
  // MOD#  PCR#    PGMR   DATE   DESCRIPTION
  //
  //========================================================================*
  ctl-opt option(*nodebugio:*srcstmt) dftactgrp(*no);

  //-------------------------------------------------------------------------
  //  Files
  //-------------------------------------------------------------------------
  dcl-f PICKENVD Workstn
    sfile(ENVSFL:ENVSFLRRN);

  //-------------------------------------------------------------------------
  //  Data defs
  //-------------------------------------------------------------------------
  dcl-s ENVSFLRRN int(5);
  dcl-s varptr pointer;
  dcl-s wasError ind;
  dcl-s environmentDataLibraryName Char(10);
  dcl-s environmentObjectLibraryName Char(10);
  dcl-s choseOne ind;
  dcl-s envPicked char(20);
  dcl-s SqlStmt char(500);
  dcl-s SqlStmt2 char(500);
  dcl-s SqlStmt3 char(500);
  dcl-s savSearch char(20) inz('Init');
  dcl-s isGenie ind;
  dcl-s cmd char(50);
  dcl-s allowChange ind inz(*off);
  dcl-s result char(1);

  dcl-c q '''';
  dcl-c Ok 0;

  dcl-ds pgmStatus PSDS qualified;
    status *STATUS;
    routine *ROUTINE;
    library char(10) pos(81);
    curUser char(10) pos(358);
  end-ds;

  dcl-ds envData qualified;
    id varchar(36);
    environmentName varchar(20);
    environmentDesc varchar(100) ;
  end-ds;

  dcl-ds usrDftData qualified;
    defaultEnvironmentName varchar(20);
    allowChangeEnvironment int(5);
  End-Ds;

  //-------------------------------------------------------------------------
  //  Procedure defs
  //-------------------------------------------------------------------------
  dcl-pr qcmdexc extpgm('QCMDEXC');
    cmdStr char(500) const options(*varsize);
    cmdlength packed(15:5) const;
  end-pr;

  dcl-pr getenv pointer extproc('getenv');
    name pointer value options(*string);
  end-pr;

  dcl-pr putenv int(10) extproc('putenv');
    *n pointer value options(*string:*trim) ;
  end-pr;

  dcl-pr setPjsEnv ExtPgm('SETPJSENV') end-pr;

  dcl-pr PUISETENV ExtPgm('PROFOUNDUI/PUISETENV');
    isGenie ind options(*NoPass);
  End-Pr;

  //-------------------------------------------------------------------------
  //  Main Procedure
  //-------------------------------------------------------------------------

  exec sql
    set option naming = *sys, commit = *none;

  // Retrieve User Defaults
  getUserDefaults();

  // Check to see if we are in a Genie session.
  callp PUISETENV(isGenie);


  if isGenie;
    setPjsEnv();
  else;
    setInitLibrary();

    if allowChange = *on;
      processDisplay();
    else;
      setDefaultEnvironment();
    endif;

  endif;


  *inlr  = *on;

  //-------------------------------------------------------------------------
  //  Subroutine: dclCursor
  //-------------------------------------------------------------------------
  dcl-proc dclCursor;


    if %Trim(s1Search) = '';
      sqlStmt = 'select ID, ENVIRONMENTNAME, ENVIRONMENTDESC '+
        'From Environments ' +
        'Where DISABLED = 0 ' +
        'order by ENVIRONMENTName';

    else;
      sqlStmt = 'select ID, ENVIRONMENTNAME, ENVIRONMENTDESC '+
      'From Environments ' +
      'Where DISABLED = 0 and ' +
      '(upper(environmentName) like ' +
         q + '%' + %trim(%upper(s1Search)) + '%' + q + ' ' +
      ' or upper(EnvironmentDesc) like ' +
        q + '%' + %trim(%upper(s1Search)) + '%' + q + ') ' +
      'order by ENVIRONMENTName';

    endif;

    Exec Sql Declare C1 Cursor For Sqlstmt;
    Exec Sql Prepare Sqlstmt From :Sqlstmt;
    Exec Sql Open C1;

  end-proc;

  //-------------------------------------------------------------------------
  //  Subroutine: clearSfl
  //-------------------------------------------------------------------------
  dcl-proc clearSfl;

    *in70 = *on;
    ENVSFLRRN = 0;
    write ENVCTL;
    *in70 = *off;

  end-proc;

  //-------------------------------------------------------------------------
  //  Subroutine: loadSfl
  //-------------------------------------------------------------------------
  dcl-proc loadSfl;

    dou SqlCod <> *Zero;
      Exec Sql Fetch Next From C1 Into :envData;

      if SqlCod <> *zero;
        leave;
      endif;

      SFENVID   = envData.id;
      SFENVNAME = envData.environmentName;
      SFENVDESC = envData.environmentDesc;

      ENVSFLRRN += 1;
      write ENVSFL;

      if ENVSFLRRN = 9999;
        leave;
      endif;

    enddo;

    exec sql close C1;
    *in71 = *on;

  end-proc;

  //-------------------------------------------------------------------------
  //  Subroutine: procSfl
  //-------------------------------------------------------------------------
  dcl-proc procSfl;

    Dou *in95 = *ON;
      READC envSfl;
      *in95 = %EOF;

      If *in95 = *OFF;

        if opt = '1';
          choseOne = *on;
          envPicked = SFENVNAME;
        endif;
      endIf;

   enddo;

  End-Proc;



  //-------------------------------------------------------------------------
  //  Sub_Procedure: addlible
  //    Adds the passed in library to the specified position
  //  Return: indicator - *on = error
  //-------------------------------------------------------------------------
  dcl-proc addlible;
    dcl-pi *n ind;
     lib char(10) const;
     pos char(99) const;
    end-pi;

    dcl-s wasError ind;
    dcl-s cmd char(200);

    wasError = *off;

    if (lib <> ' ');
      monitor;
        cmd = 'ADDLIBLE LIB(' + %trim(lib) +
              ') POSITION(' + %trim(pos) + ')';
        callp qcmdexc(cmd:%len(cmd));
      on-error;
        wasError = *on;
      endmon;
    endif;

    return wasError;

  end-proc;

//-------------------------------------------------------------------------
//  Sub_Procedure: processDisplay
//-------------------------------------------------------------------------
dcl-proc processDisplay;

  dou *in03 = *on;

    if s1Search <> savSearch;
      dclCursor();
      savSearch = s1Search;
    endif;

    clearSfl();
    loadSfl();

    write FKEY;
    exfmt ENVCTL;
    *in40 = *off;
    choseOne = *off;
    envPicked = *blanks;

    if *in03 = *on;
      leave;
    endif;

    procSfl();
    if choseOne = *on;
      leave;
    endif;

  enddo;


  // Set the environment based on the selected option
  if choseOne;
    putenv('PROFOUNDJS_ENVIRONMENT_NAME=' + envPicked);
    setPjsEnv();
  else;
    setDefaultEnvironment();
  endif;

end-proc;


//-------------------------------------------------------------------------
//  Sub_Procedure: setInitLibrary
//-------------------------------------------------------------------------
dcl-proc setInitLibrary;


  // Retrieve ProfoundJS Environment Data Library.
  varptr = getenv('PROFOUNDJS_ENVIRONMENT_DATA_LIBRARY');
  if varptr <> *null;
    environmentDataLibraryName = %str(varptr);
  endif;

  // Add Profoundjs Environment Data Library to Library List.
  wasError = addlible( environmentDataLibraryName : '*FIRST');

  // Retrieve ProfoundJS Environment Object Library.
  varptr = getenv('PROFOUNDJS_ENVIRONMENT_OBJECT_LIBRARY');
  if varptr <> *null;
    environmentObjectLibraryName = %str(varptr);
  endif;
  // Add Profoundjs Environment Object Library to Library List.
  wasError = addlible( environmentObjectLibraryName : '*FIRST');



end-proc;

 //-------------------------------------------------------------------------
  dcl-proc getUserDefaults;

    allowChange = *off;

    SqlStmt2 =
      'Select defaultEnvironmentName, allowChangeEnvironment ' +
      'From environmentUserDefaults ' +
      ' Where userName = upper(' + q + %Trim(pgmStatus.curUser) + q + ')' +
      '  and disabled = 0' ;

    Exec Sql Declare C2 Cursor For Sqlstmt2;
    Exec Sql Prepare Sqlstmt2 From :Sqlstmt2;
    Exec Sql Open C2;

    dou sqlCode = Ok;
      Exec Sql Fetch Next From C2 Into :usrDftData;

      // If defaults for user not found, try *DEFAULT settings
      if sqlCode <> Ok;

        SqlStmt3 =
          'Select defaultEnvironmentName, allowChangeEnvironment ' +
          'From environmentUserDefaults ' +
          ' Where userName = upper(' + q + '*DEFAULT' + q + ')' ;

        Exec Sql Declare C3 Cursor For Sqlstmt3;
        Exec Sql Prepare Sqlstmt3 From :Sqlstmt3;
        Exec Sql Open C3;
        Exec Sql Fetch Next From C3 Into :usrDftData;

        if sqlCode <> Ok;
          dsply 'User not found in environmentUserDefaults table.' ''  result;
          cmd = 'SIGNOFF';
          runCommand();
        endif;

        Exec Sql Close C3;
      endif;

    enddo;

    Exec Sql Close C3;

    if usrDftData.allowChangeEnvironment = 1;
      allowChange = *on;
    endif;

end-proc;

//-------------------------------------------------------------------------
  dcl-proc runCommand;

    monitor;
      qcmdexc(cmd:%len(%trim(cmd)));
    on-error;
    endmon;

  end-proc;

//-------------------------------------------------------------------------
dcl-proc setDefaultEnvironment;

    if usrDftData.defaultEnvironmentName <> *blanks;
      putenv('PROFOUNDJS_ENVIRONMENT_NAME=' + usrDftData.defaultEnvironmentName);
      setPjsEnv();
      *inlr = *ON;
      return;
    else;
      dsply 'No default environment setup for this user.' ''  result;
      cmd = 'SIGNOFF';
      runCommand();
    endif;

end-proc;
