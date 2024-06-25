     H Debug
     H OPTION(*NODEBUGIO : *SRCSTMT) DFTACTGRP(*NO) BNDDIR('QC2LE')
      **************************************************************************
      **  This program returns the environment variable's value.
      **  It is stuffed into the CL variable passed on the 2nd parm.
      **  CPP for RTVENVVAR CL command.
      **************************************************************************

      ** Template definition used for 2nd parameter
     D CL_RTNVAR_T     DS                  based(pNothing_T) QUALIFIED
     D  nLen                          5I 0
     D  Data                      32766A

     DRtvEnvVar        PR
     D  envvar                      256A
     D  rtnVar                             LIKEDS(CL_RTNVAR_T)
     D  envlvl                        4A

     DRtvEnvVar        PI
     D  envvar                      256A
     D  rtnVar                             LIKEDS(CL_RTNVAR_T)
     D  envlvl                        4A

      * Get job level env
     D Qp0zGetEnv      PR              *   ExtProc('Qp0zGetEnv')
     D  envvar                         *   VALUE OPTIONS(*STRING)
     D  nCCSID                       10I 0

      * Get sys level env
     D Qp0zGetSysEnv   PR            10I 0 ExtProc('Qp0zGetSysEnv')
     D  envVarName                     *   VALUE OPTIONS(*STRING)
     D  rtnBuffer                 65535A   OPTIONS(*VARSIZE)
     D  bufLen                       10I 0
     D  nCCSID                       10I 0
     D  reserved                       *   OPTIONS(*OMIT)

     D  rtnBuffer      S            512A
     D  pRtnBuffer     S               *   Inz
     D  pEnv           S               *   Inz
     D  bufLen         S             10I 0
     D  nCCSID         S             10I 0 Inz(0)
     D  nRtn           S             10I 0 Inz(0)

     C                   eval      *INLR = *ON
     C                   if        envlvl = '*JOB'
      ** Retrieve a pointer to the environment variable's value
     C                   eval      pEnv = Qp0zGetEnv(%TRIMR(ENVVAR):nCCSID)

      **  If nothing came back, then the ENVVAR is bad, so return nothing.
     C                   if        pEnv = *NULL
     C                   return
     C                   endif

      **  Copy the environment variable to the return variable,
      **  being careful not to overstep the variable's length.
     C                   eval      %subst(rtnVar.Data:1:rtnVar.nLen) =
     C                                %str(pEnv)
     C                   else
     C                   eval      bufLen = %len(rtnBuffer)
     C                   eval      nRtn = Qp0zGetSysEnv(%TRIMR(ENVVAR):
     C                                                  rtnBuffer  :
     C                                                  bufLen    :
     C                                                  nCCSID :
     C                                                  *OMIT)
     C                   if        nRtn <> 0
     C                   Dump
     C                   return
     C                   endif

     C                   eval      rtnVar.nLen = bufLen
     C                   eval      pRtnBuffer = %addr(rtnBuffer)
     C                   eval      %subst(rtnVar.Data:1:bufLen) =
     C                                 %str(pRtnBuffer)
     C                   endif

     C                   return
