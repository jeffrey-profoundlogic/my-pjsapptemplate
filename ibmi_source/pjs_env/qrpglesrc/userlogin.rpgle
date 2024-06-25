**Free
Ctl-opt option(*noDebugIo)   DftActGrp(*no);

//-------------------------------------------------------------------------
//
// *NOTE:  CHGOBJOWN OBJ(PJS_ENV/USERLOGIN) OBJTYPE(*PGM) NEWOWN(AMAPICS)
//
//  Description: This replaces ALL of the initial programs located in
//    the user profile information.
//  Programmer.: Brian Rees - Profound Logic Software, Inc.
//  Date.......: 12/29/2023
//
//-------------------------------------------------------------------------
  dcl-ds pgmStatus PSDS qualified;
    status *STATUS;
    routine *ROUTINE;
    exceptionType char(3) pos(40);
    exceptionNumber char(4) pos(43);
    library char(10) pos(81);
    exceptionData char(80) pos(91);
    messageText char(52) pos(91);
    exceptionId char(4) pos(171);
    curUser char(10) pos(358);
  end-ds;

  dcl-ds usrDftData qualified;
    id varchar(36);
    userName varchar(25);
    initialMenu varchar(10) ;
    initialMenuLibrary varchar(10);
    initialProgram varchar(10) ;
    initialProgramLibrary varchar(10) ;
    isGenieOnly int(5);
  End-Ds;

  dcl-s varptr pointer;
  dcl-s environmentDataLibraryName Char(10);
  dcl-s environmentObjectLibraryName Char(10);

  dcl-s SqlStmt Char(500);
  dcl-s SqlStmt2 Char(500);
  dcl-s result char(1);

  dcl-c q '''';
  dcl-c Ok 0;

  dcl-s GenieLib Char(10);
  dcl-s isGenie ind;

//-------------------------------------------------------------------------
//  Procedure defs
//-------------------------------------------------------------------------

  // Environment Selection
  dcl-pr pickenv ExtPgm('PICKENV') end-pr;

  // Atrium Launch Program
  dcl-pr pjslaunch ExtPgm('PJSLAUNCH') end-pr;

  // Command Execution
  dcl-pr qcmdexc extpgm('QCMDEXC');
    cmdStr char(500) const options(*varsize);
    cmdlength packed(15:5) const;
  end-pr;
  dcl-s cmd char(50);

  dcl-pr getenv pointer extproc('getenv');
    name pointer value options(*string);
  end-pr;

  dcl-pr qcmdexec extpgm('QCMDEXC');
    cmdStr char(500) const options(*varsize);
    cmdlen packed(15:5) const;
  end-pr;

  dcl-pr PUISETENV ExtPgm('PROFOUNDUI/PUISETENV');
    isGenie ind options(*NoPass);
    GenieLib char(10) options(*NoPass);
    GenieSkin char(50) options(*NoPass);
    DocRoot char(128) options(*NoPass);
    UserAgent char(128) options(*NoPass);
    ServerIP char(15) options(*NoPass);
  End-Pr;

//-------------------------------------------------------------------------
//  Mainline Program
//-------------------------------------------------------------------------

       varptr = getenv('PROFOUNDJS_ENVIRONMENT_DATA_LIBRARY');
       if varptr <> *null;
         environmentDataLibraryName = %str(varptr);
       endif;

       // Add Profoundjs Environment Data Library to Library List.
       addlible( environmentDataLibraryName : '*FIRST');

       // Retrieve ProfoundJS Environment Program Library.
       varptr = getenv('PROFOUNDJS_ENVIRONMENT_OBJECT_LIBRARY');
       if varptr <> *null;
         environmentObjectLibraryName = %str(varptr);
       endif;

       // Add Profoundjs Environment Program Library to Library List.
       addlible( environmentObjectLibraryName : '*FIRST');

        // Do not process if Genie (Atrium PJSLAUNCH macro will handle this.)
        callp PUISETENV(isGenie: GenieLib);
        snd-msg GenieLib;
        // if isGenie;
        //   return;
        // endif;

        // Retrieve User Defaults
        getUserDefaults();

        if NOT isGenie OR usrDftData.isGenieOnly = 1;
          pickenv();    // User needs to select their environment.

          // default initialProgramLibrary to *LIBL if not specified
            if usrDftData.initialProgramLibrary = *blanks;
              usrDftData.initialProgramLibrary = '*LIBL';
            endif;

            // if specified, run the inital program for the user
            if usrDftData.initialProgram <> '*NONE' and usrDftData.initialProgram <> *blanks;
              cmd = 'CALL ' + usrDftData.initialProgramLibrary + '/' + usrDftData.initialProgram;
              runCommand();
            endif;

            // default initialMenuLibrary to *LIBL if not specified
            if usrDftData.initialMenuLibrary = *blanks;
              usrDftData.initialMenuLibrary = '*LIBL';
            endif;

          // if specified, run the inital menu for the user
          if usrDftData.initialMenu <> *blanks and usrDftData.initialMenu <> '*SIGNOFF';
            cmd = 'GO ' + usrDftData.initialMenuLibrary + '/' + usrDftData.initialMenu;
            runCommand();
          endif;

        else;
        // T
          // Atrium Launch
          pjslaunch();
        endif;

  // Signoff
  cmd = 'signoff';
  runCommand();

  *inlr  = *on;


  //-------------------------------------------------------------------------
    dcl-proc getUserDefaults;

      SqlStmt =
        'Select id, userName, initialMenu, initialMenuLibrary, initialProgram, ' +
        'initialProgramLibrary, isGenieOnly ' +
        'From environmentUserDefaults ' +
        ' Where userName = upper(' + q + %Trim(pgmStatus.curUser) + q + ')' +
        '  and disabled = 0' ;

      Exec Sql Declare C1 Cursor For Sqlstmt;
      Exec Sql Prepare Sqlstmt From :Sqlstmt;
      Exec Sql Open C1;

      dou sqlCode = Ok;
        Exec Sql Fetch Next From C1 Into :usrDftData;

        // If defaults for user not found, try *DEFAULT settings
        if sqlCode <> Ok;

          SqlStmt2 =
            'Select id, userName, initialMenu, initialMenuLibrary, initialProgram, ' +
            'initialProgramLibrary, isGenieOnly ' +
            'From environmentUserDefaults ' +
            ' Where userName = upper(' + q + '*DEFAULT' + q + ')' ;

          Exec Sql Declare C2 Cursor For Sqlstmt2;
          Exec Sql Prepare Sqlstmt2 From :Sqlstmt2;
          Exec Sql Open C2;
          Exec Sql Fetch Next From C2 Into :usrDftData;

          if sqlCode <> Ok;
            dsply 'User not found in environmentUserDefaults table.' ''  result;
            cmd = 'SIGNOFF';
            runCommand();
          endif;

          Exec Sql Close C2;
        endif;

      enddo;

      Exec Sql Close C1;

  end-proc;

  //-------------------------------------------------------------------------
    dcl-proc runCommand;

      monitor;
        qcmdexc(cmd:%len(%trim(cmd)));
     on-error;
          dsply ('Errors Occurred: ' + pgmStatus.exceptionType +
                 pgmStatus.exceptionNumber);
          dsply (%subst(pgmStatus.messageText:1:30)) ''  result;
        cmd = 'SIGNOFF';
        runCommand();
     endmon;

    end-proc;

       //----------------------------------------------------------------------
       //  Add Library
       //----------------------------------------------------------------------
       dcl-proc addlible;
        dcl-pi *n;
         lib char(10) const;
         pos char(99) const;
        end-pi;

        if (lib <> ' ');
          monitor;
            cmd = 'ADDLIBLE LIB(' + %trim(lib) +
                  ') POSITION(' + %trim(pos) + ')';
            callp qcmdexec(cmd:%len(cmd));
            snd-msg cmd;
          on-error;
            // snd-msg GenieLib;
          endmon;
        endif;

       end-proc;
