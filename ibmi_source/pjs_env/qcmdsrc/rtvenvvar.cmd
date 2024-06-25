RTVENVVAR:  CMD        PROMPT('Retrieve Environment Variable')

            /* Command processing program is RTVENVVAR  */

            PARM      KWD(ENVVAR) TYPE(*CHAR) LEN(256) MIN(1) +
                          EXPR(*YES) INLPMTLEN(17) +
                          PROMPT('Environment variable')
            PARM      KWD(RTNVAL) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          VARY(*YES) CHOICE('Environment var return +
                          value') PROMPT('CL Var. for return value')
            PARM      KWD(LEVEL) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*JOB) SPCVAL((*JOB) (*SYS)) +
                          EXPR(*YES) PMTCTL(*PMTRQS) PROMPT('Level')