       Ctl-Opt DftActGrp(*No) ActGrp(*New);
        //=====================================================================
        //
        // *NOTE:  CHGOBJOWN OBJ(PJS_ENV/PJSLAUNCH) OBJTYPE(*PGM) NEWOWN(AMAPICS)
        //
        // PROGRAM NAME...: pjslaunchd - PJS Application Launcher
        // AUTHOR.........: Profound Logic Software, Inc.
        // DATE...........: 06/09/2023
        // FUNCTION/DESC..:
        //    This program will setup the PJS environment variables
        //    for a specific application environment.
        //
        //--------------------------------------------------------------------
        // Modifications
        //
        //--------------------------------------------------------------------

        dcl-f pjslaunchd Workstn Infds(DSPFINFDS) usropn;

     D DSPFINFDS       DS                  QUALIFIED
     D**
     D  Thisdspf               1      8A
     D** Function Key pressed
     D  FKey                 369    369A
     D** Max number of sfl recs after done loading
     D  Maxsflrecs           376    377I 0
     D** First sfl rec on visible screen
     D  Lowrrn               378    379I 0
     D** number of sfl records after SFLINZ
     D  Inzmaxrecs           380    381I 0

       //----------------------------------------------------------------------
       // Define Procedures
       //----------------------------------------------------------------------
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

       dcl-pr getenv pointer extproc('getenv');
         name pointer value options(*string);
       end-pr;

       dcl-pr setPjsEnv ExtPgm('SETPJSENV') End-Pr;

       dcl-pr GetUsrInf ExtPgm('QSYRUSRI');
         RcvVar char(32767) options(*varsize);
         RcvVarLen int(10) const;
         Format char(8) const;
         UsrPrf char(10) const;
         ErrCode char(32767) options(*varsize);
       End-Pr;

       //----------------------------------------------------------------------
       //  Variables
       //----------------------------------------------------------------------
       dcl-s isGenie ind;
       dcl-s Cmd char(5000);
       dcl-s varptr pointer;
       dcl-s url varchar(5000);
       dcl-s environmentDataLibraryName Char(10);
       dcl-s environmentObjectLibraryName Char(10);

       //----------------------------------------------------------------------
       //  Temporary Variables
       //----------------------------------------------------------------------
       dcl-s GenieLib Char(10);

       //----------------------------------------------------------------------
       //  Mainline
       //----------------------------------------------------------------------
       // Retrieve ProfoundJS Environment Data Library.
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

       Exec Sql
         Set Option Commit = *None;

        callp PUISETENV(isGenie: GenieLib);
        snd-msg GenieLib;
        if isGenie;

          setPjsEnv();

          open pjslaunchd;
          exfmt LAUNCH01;

          //  cmd = 'CHGJOB DEVRCYACN(*ENDJOBNOLIST)';
          //  callp qcmdexec(cmd:%len(cmd));

           if (not *in03);

              // Add Additional Libraries specified on launcher.
              addlible( lib1 : pos1 );
              addlible( lib2 : pos2 );
              addlible( lib3 : pos3 );
              addlible( lib4 : pos4 );
              addlible( lib5 : pos5 );
              addlible( lib6 : pos6 );
              addlible( lib7 : pos7 );
              addlible( lib8 : pos8 );
              addlible( lib9 : pos9 );
              addlible( lib10 : pos10 );

              // Calling a cmdpgm
              if (cmdpgm <> *blanks);
                snd-msg '*cmdpgm: ' + %trim(cmdpgm);
                callp qcmdexec(%trim(cmdpgm):%len(cmdpgm));
                callp qcmdexec('signoff':9);
              endif;

            // If no MenuID nor cmdpgm - then just return back to the caller program
            else;
              *INLR = *ON;
              RETURN;
           endif;

        endif;

       // If this is the launcher macro -- signoff now
       varptr = getenv('HTTP_REFERER');
       if varptr <> *null;
         url = %str(varptr);
         if (%scan('atrium_macro' : %lower(url)) < 1);
           callp qcmdexec('call qcmd':9);
         endif;
         callp qcmdexec('signoff':9);
       endif;

       *INLR = *ON;
       RETURN;

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
            snd-msg GenieLib;
          endmon;
        endif;

       end-proc;
