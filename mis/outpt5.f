      SUBROUTINE OUTPT5
C
C     DRIVER OF OUTPUT5 MODULE
C     COPIES UP TO 5 GINO DATA BLOCKS TO TAPE, BY FORTRAN WRITE,
C     FORMATTED (ASCII), OR UNFORMATTED (BINARY)
C
C     THIS MODULE HAS BEEN EXPANDED TO INCLUDE TABLE DATA BLOCKS.
C     ORIGINALLY IT HANDLES ONLY MATRIX DATA BLOCKS.  G.CHAN/MAY 88
C
C     ==== TABLE  ====
C     OUTPT5 CALLS TABLE5 TO PROCESS TABLE DATA BLOCKS
C      . UNFORMATTED (BINARY) OR FORMATTED (UNDER P4 CONTROL)
C      . IF BINARY, EACH RECORD IS WRITTEN OUT BY -
C           WRITE (OUT) L,(Z(J),J=1,L)
C      . IF FORMATTED,  5 BYTES ARE USED FOR BCD WORD,
C                      10 BYTES FOR INTEGER,
C                      15 BYTES FOR REAL, S.P. OR D.P.
C      . A HEADER RECORD, WHICH CONFORMS TO OUTPT5 HEADER STANDARD,
C           IS WRITTEN OUT FIRST, PRECEEDING THE TABLE DATA RECORDS.
C
C     ==== MATRIX ====
C     COPY GINO MATRIX DATA BLOCK(S) ONTO FORTRAN UNIT IN
C      . UNPACKED BANDED RECORD
C      . BANDED COLUMN  RECORD (FIRST TO LAST NON-ZERO ELEMENTS),
C      . UNFORMATTED (BINARY) OR FORMATTED
C      . SINGLE PRECISION OR DOUBLE, REAL OR COMPLEX DATA
C      . OUTPUT FORTRAN TAPE INPI (I=T,1,2,..,9) FOR UNIVAC, IBM, VAX
C                    OR TAPE UTI  (I=  1,2,..,5) FOR CDC
C        (DEFAULT=INP1, UNIT 15, OR UT1, UNIT 11)
C
C     THIS MODULE HANDLES ONLY MATRIX DATA BLOCKS, NOT TRUE ANY MORE
C
C     UNFORMATTED RECORDS CAN ONLY BE USED BY THE SAME COMPUTER SYSTEM,
C     WHILE FORMATTED RECORDS CAN BE USED ACROSS COMPUTER BOUNDARY
C     (E.G. WRITTEN BY CDC MACHINE AND READ BY IBM) AND ALSO, CAN BE
C     EDITED BY SYSTEM EDITOR, OR PRINTED OUT BY SYSTEM PRINT COMMAND.
C
C     CALL TO THIS MODULE IS
C
C     OUTPUT5  IN1,IN2,IN3,IN4,IN5//C,N,P1/C,N,P2/C,N,P3/C,N,P4
C                                  /C,N,T1/C,N,T2/C,N,T3/C,N,T4... $
C
C              P1=+N, SKIP FORWARD N MATRIX DATA BLOCKS OR TABLES BEFORE
C                     WRITE. (EXCEPT THE FIRST HEADER RECORD. EACH
C                     MATRIX DATA BLOCK OR TABLE, PRECEEDED BY A HEADER
C                     RECORD, IS A COMPLETE MATRIX OR TABLE, MADE UP OF
C                     MANY PHYSICAL RECORDS.
C                     SKIP TO THE END OF TAPE IF P1 EXCEEDS THE
C                     NO. OF DATA BLOCKS AVAILABLE ON THE OUTPUT FILE)
C              P1= 0, NO ACTION TAKEN BEFORE WRITE. (DEFAULT)
C              P1=-1, FORTRAN TAPE IS REWOUND, A TAPE HEADER RECORD IS
C                     WRITTEN TO TAPE. DATA IN FIRST GINO DATA BLOCK IS
C                     COPIED TO TAPE, FOLLOWED BY 4 MORE GINO DATA
C                     BLOCKS IF THEY ARE PRESENT.
C                     AT END, NO EOF WRITTEN, AND TAPE NOT REWOUND
C              P1=-3, THE NAMES OF ALL DATA BLOCKS ON FORTRAN TAPE
C                     ARE PRINTED AND WRITE OCCURS AT THE END OF TAPE
C              P1=-9, WRITE AN INTERNAL END-OF-FILE RECORD, FOLLOWED BY
C                     A SYSTEM ENDFILE MARK, AND REWIND FORTRAN TAPE
C              P2  IS THE FORTRAN UNIT NO. ON WHICH THE DATA BLOCKS WILL
C                     BE WRITTEN.  DEFAULT IS 15 (INP1 FOR UNIVAC, IBM,
C                     VAX), OR UNIT 11 (UT1 FOR CDC)
C
C              P3  IS TAPE ID IF GIVEN BY USER. DEFAULT IS XXXXXXXX
C
C              P4= 0, OUTPUT FILE IS FORTRAN WRITTEN, UNFORMATTED
C              P4= 1, OUTPUT FILE IS FORTRAN WRITTEN, FORMATTED
C                     (BCD IN 2A4, INTEGER IN I8, REAL IN 10E13.6 AND
C                      D.P. IN 5D26.17)
C              P4= 2, SAME AS P4=1, EXECPT 5E26.17 IS USED FOR S.P. REAL
C                     DATA. P4=2 IS USED ONLY IN MACHINES WITH LONG WORD
C                     FOR ACCURACY (60 OR MORE BITS PER WORD)
C
C              TI     10 WORD ARRAY USED ONLY BY TABLE BLOCK DATA.
C                     TO OVERRIDE AUTOMATIC FORMAT TYPE SETTING.
C
C     OUTPT5 LOGIC -
C                                                       (P4=0)   (P4=1)
C     RECORD  WORD        CONTENTS                      BINARY   FORMAT
C     ------  ----  --------------------------------   -------  -------
C        0            TAPE HEADER RECORD -
C              1,2    TAPEID                             2*BCD      2A4
C              3,4    MACHINE (2ND WORD BLANK)           2*BCD      2A4
C              5-7    DATE                               3*INT      3I8
C               8     SYSTEM BUFFSIZE                      INT       I8
C               9     P4 (0,1, OR 2)                       INT       I8
C      1A,1B%         FIRST MATRIX HEADER RECORD -
C               1     ZERO                                 INT       I8
C              2,3    ONE,ONE                            2*INT      2I8
C               4     D.P. ZERO                           F.P.   D26.17
C              5-10   MATRIX TRAILER                     6*INT      6I8
C                     (COL,ROW,FORM,TYPE,MAX,DENSITY)
C             11,12   DMAP NAME OF FIRST INPUT MATRIX    2*BCD      2A4
C      2A,2B    1     1 (FIRST MATRIX COLUMN ID)           INT       I8
C               2     COLUMN LOC. OF FIRST NON-ZERO ELEM.  INT       I8
C               3     COLUMN LOC. OF LAST  NON-ZERO ELEM.  INT       I8
C              1-W    FIRST BANDED COLUMN DATA            F.P.     (**)
C                     (W=WORD3-WORD2)
C      3A,3B    1     2 (SECOND MATRIX COLUMN ID)          INT       I8
C              2-3    FIRST AND LAST NON-ZERO ELEM LOC.  2*INT      2I8
C              1-W    SECOND BANDED COLUMN DATA           F.P.     (**)
C      4A,4B   1-3    THIRD  MATRIX COLUMN, SAME FORMAT  3*INT      3I8
C              1-W    AS RECORD 1                         F.P.     (**)
C        :      :       :
C      ZA,ZB    1     (A NULL COLUMN ID)                   INT       I8
C              2,3    1,1                                2*INT      2I8
C               1     0.0                                 F.P.     (**)
C        :      :       :
C      MA,MB   1-3    LAST MATRIX COLUMN, SAME AS REC #2 3*INT      3I8
C              1-W    LAST BANDED COLUMN DATA             F.P.     (**)
C
C      SA,SB    :     SECOND MATRIX HEADER RECORD   3*INT+F.P. 3I8+D26.
C                                                       +2*BCD   +2*BCD
C                                                       +6*INT     +6I8
C    S+1A,S+1B 1-W    FIRST THRU LAST COLS OF 2ND MATRIX
C        :      :     REPEAT FOR MORE MATRICES
C        :      :     (UP TO 5 MATRIX DATA BLOCKS PER ONE OUTPUT FILE)
C
C    EOFA,EOFB  1     -1                                   INT       I8
C              2,3    1,1                                2*INT      2I8
C               1     D.P. ZERO                           F.P.   D26.17
C
C                                                               - NOTE -
C                                                  BCD AND INTEGERS IN 8
C                                         SINGLE PRECISION REAL IN  13.6
C                                         DOUBLE PRECISION DATA IN 26.17
C                                         S.P. LOGN WORD MACHINE   26.17
C
C     WHERE   %  RECORDS A AND B ARE 2 (OR MORE) RECORDS ON FORMATTED
C                OUTPUT FILE, WHILE
C                A & B ARE 1 CONTINUOUS RECORD IN UNFORMATTED TAPE
C           (**) IS (10E13.6) FOR S.P.REAL, OR (5D26.17) FOR D.P. DATA.
C                OR (5E26.17) FOR S.P. AND D.P. DATA (P4=2 ONLY)
C     NOTE -
C     NO SYSTEM END-OF-FILE MARK WRITTEN BETWEEN MATRICES.
C
C     TO READ BINARY TAPE              TO READ FORMATTED TAPE
C     ----------------------------     --------------------------------
C                LOGICAL SP,DP
C                INTEGER COL,ROW,FORM,TYPE,DENS,FILE(2),IZ(M,N)
C    *                   TAPEID(2),MAC(2),DATE(3),BUFSZ,P4
C                DOUBLE PRECISION DZ(M/2,N/2),DTEMP
C                COMMON  /ZZZZZZ/ Z(M,N)
C                EQUIVALENCE      (Z,IZ,DZ)
C                DATA     SP,DP / .TRUE.,.FALSE./
C     READ (TAPE,ERR=7)                READ (TAPE,10,ERR=7)
C    *           TAPEID,MAC,DATE,BUFSZ,P4
C   1            K = 0
C   2            K = K + 1
C     READ (TAPE,ERR=7,END=3) I,JB,    IF (SP) READ (TAPE,8,ERR=7,END=3)
C    *                        JE               I,JB,JE,( Z(J,K),J=JB,JE)
C                                      IF (DP) READ (TAPE,9,ERR=7,END=3)
C    *                                         I,JB,JE,(DZ(J,K),J=JB,JE)
C                IF (I)   3,            4,     6
CC                      EOF,MATRIX-HEADER,COLUMN
C   3            CONTINUE
CC               (EOF ENCOUNTERED, COMPLETE TAPE READ)
C                CALL EXIT
C   4            BACKSPACE TAPE
C                                      BACKSPACE TAPE
CC               (MATRIX-HEADER READ)
C     READ (TAPE) J,J,J,               READ (TAPE,11) J,J,J
C    *           DTEMP,COL,ROW,FORM,TYPE,MAX,DENS,FILE
C                DP = .FALSE.
C                IF (TYPE.EQ.2 .OR. TYPE.EQ.4) DP=.TRUE.
C                SP = .NOT.DP
C                JTYP = TYPE
C                IF (TYPE .EQ. 3) JTYP = 2
C                IF (COL*JTYP.GT.M .OR. ROW*JTYP.GT.N) STOP 'Z DIM ERR'
C                J = COL*ROW*JTYP
C                DO 5 I = 1,J
C   5            Z(I,1) = 0.0
C                GO TO 1
C   6            CONTINUE
CC               (A COLUMN OF MATRIX READ)
C                IF (I .NE. K) STOP 'COLUMN COUNTER MISSMATCH'
C                GO TO 2
C   7            STOP 'READ ERROR. CHECK TAPE FORMAT TYPE'
C                                     8 FORMAT (3I8,/,(10E13.6))
C                                     9 FORMAT (3I8,/,(5D26.17))
C                                    10 FORMAT (4A4,5I8)
C                                    11 FORMAT (3I8,/,D26.17,6I8,2A4)
CC             FOR LONG WORD MACHINE  8 FORMAT (3I8,/,(5E26.17))
C
C     SEE SUBROUTINE INPTT5 FOR MORE COMPREHENSIVE DETAILS IN RECOVERING
C     MATRIX DATA FROM THE TAPE GENERATED IN THIS OUTPT5 ROUTINE.
C     OR SUBROUTINE TABLE-V FOR TABLE DATA BLOCK RECOVERY.
C
C     WRITTEN BY G.CHAN/UNISYS   1987
C
      IMPLICIT INTEGER (A-Z)
      LOGICAL          P40,P40S,P40D,P41,P41S,P41D,P41C,COMPLX
      INTEGER          TRL(9),NAME(2),TAPEID(2),SUBNAM(2),TI,DT(3),
     1                 FN(3,10),NONE(2)
      REAL             RZ(1),X,ZERO
      DOUBLE PRECISION DZ(1),DX,DZERO
      CHARACTER*8      BINARY,FORMTD,BF
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25
      COMMON /XMSSG /  UFM,UWM,UIM,SFM
      COMMON /BLANK /  P1,P2,P3(2),P4,TI(10)
      COMMON /MACHIN/  MACH,IJHALF(3),MCHNAM
      COMMON /SYSTEM/  IBUF,NOUT,DUM6(7),LINE,DUMM4(4),DATE(3),
     1                 DUM22(22),NBPW,DUM50(50),LPCH
CZZ   COMMON /ZZOUT5/  IZ(1)
      COMMON /ZZZZZZ/  IZ(1)
      COMMON /UNPAKX/  ITYP,II,JJ,INCR
      EQUIVALENCE      (RZ(1),DZ(1),IZ(1))
      DATA    BINARY,           FORMTD,         SUBNAM             /
     1       'BINARY  ',        'FORMATTD',     4HOUTP, 2HT5       /
      DATA    ZERO,    DZERO,   IZERO,  ONE,    MONE,   FN         /
     1        0.0,     0.0D0,   0,      1,      -1,     30*4H      /
      DATA    MTRX,    TBLE,    BLANK / 4HMTRX, 4HTBLE, 4H         /
      DATA    NONE  /  4H (NO,  4HNE) /
C
C     IF MACHINE IS CDC OR UNIVAC, CALL CDCOPN OR UNVOPN TO OPEN OUTPUT
C     FILE, A FORMATTED SEQUENTIAL TAPE.  NO CONTROL WORDS ARE TO BE
C     ADDED TO EACH FORMATTED RECORD. RECORD LENGTH IS 132 CHARACTERS,
C     AN ANSI STANDARD.
C
      IF (MACH .EQ. 3) CALL UNVOPN (P2)
      IF (MACH .EQ. 4) CALL CDCOPN (P2)
      BF = BINARY
      IF (P4 .GE. 1) BF = FORMTD
      CALL PAGE
      CALL PAGE2 (1)
      WRITE  (NOUT,3) UIM,BF,P1
 3    FORMAT (A29,', MODULE OUTPUT5 CALLED BY USER DMAP ALTER, ON ',A8,
     1        ' TAPE,', /5X,'WITH FOLLOWING REQUEST  (P1=',I2,1H))
      IF (P1 .EQ. -9) WRITE (NOUT,4)
      IF (P1 .EQ. -3) WRITE (NOUT,5)
      IF (P1 .EQ. -1) WRITE (NOUT,6)
      IF (P1 .EQ.  0) WRITE (NOUT,7)
      IF (P1 .GT.  0) WRITE (NOUT,8) P1
 4    FORMAT (5X,'WRITE AN INTERNAL E-O-F RECORD, FOLLOWED BY A SYSTEM',
     1       ' E-O-F MARK, AND REWIND OUTPUT TAPE')
 5    FORMAT (5X,'REWIND TAPE, PRINT DATA BLOCK NAMES AND THEN WRITE ',
     1        'AFTER THE LAST DATA BLOCK ON TAPE')
 6    FORMAT (5X,'REWIND, WRITE A TAPE HEADER RECORD, THEN FOLLOWED BY '
     1,       'DATA BLOCKS WRITING.',/5X,'AT END, NO EOF AND NO REWIND')
 7    FORMAT (5X,'DATA BLOCKS ARE WRITTEN STARTING AT CURRENT TAPE ',
     1        'POSITION. AT END, NO EOF AND NO REWIND')
 8    FORMAT (5X,'SKIP FORWARD',I4,' DATA BLOCKS BEFORE WRITING (TAPE ',
     1       'HEADER RECORD NOT COUNTED AS A DATA BLOCK).', /5X,
     2       'NO REWIND BEFORE SKIPPING. AT END, NO EOF AND NO REWIND')
C
      BUF1 = KORSZ(RZ(1)) - IBUF - 1
      IF (BUF1 .LE. 0) CALL MESAGE (-8,0,SUBNAM)
      OUT = P2
      WRT = 0
      LFN = -1
      IF (P1 .EQ. -3) LFN = 0
C
C     SET P4 FLAGS
C
C     SET P40  TO .TRUE. IF USER SPECIFIES P4 TO ZERO (BINARY)
C     SET P41  TO .TRUE. IF USER SPECIFIES P4 TO ONE  (FORMATTED)
C     SET P40D TO .TRUE. IF P40 IS TRUE AND DATA IS IN D.P.
C     SET P40S TO .TRUE. IF P40 IS TRUE AND DATA IS IN S.P.
C     SET P41D TO .TRUE. IF P41 IS TRUE AND DATA IS IN D.P.
C     SET P41S TO .TRUE. IF P41 IS TRUE AND DATA IS IN S.P.
C     SET P41C TO .TRUE. IF P4=2, AND RESET P41S AND P41D TO .FALSE.
C
      P40D = .FALSE.
      P41S = .FALSE.
      P41D = .FALSE.
      P41C =  P4.EQ.2 .AND. NBPW.GE.60
      P41  = .FALSE.
      IF (P4 .GE. 1) P41 = .TRUE.
      IF (P41C) GO TO 10
      P41S =  P41
      IF (P41 ) P41D = .NOT.P41S
 10   P40  = .NOT.P41
      P40S =  P40
      IF (P40) P40D = .NOT.P40S
      IF (P1 .NE. -9) GO TO 20
C
C     FINAL CALL TO OUTPUT5
C
      IF (P40) WRITE (OUT    ) MONE,ONE,ONE,DZERO
      IF (P41) WRITE (OUT,290) MONE,ONE,ONE,DZERO
      ENDFILE OUT
      REWIND OUT
      RETURN
C
 20   IF (P1 .EQ. -3) GO TO 60
      IF (P1 .EQ. -1) GO TO 180
      IF (P1) 30,190,65
C
 30   WRITE  (NOUT,35) UFM,P1
 35   FORMAT (A23,' 4120, MODULE OUTPUT5 - ILLEGAL VALUE FOR FIRST ',
     1       'PARAMETER = ',I8)
 40   ERR = -37
 50   CALL MESAGE (ERR,INPUT,SUBNAM)
      RETURN
C
C     OLD TAPE. CHECK TAPE ID
C
 60   REWIND OUT
 65   IF (P40) READ (OUT,    END=150) TAPEID,NAME,DT,I,K
      IF (P41) READ (OUT,185,END=150) TAPEID,NAME,DT,I,K
      IF (TAPEID(1).EQ.P3(1) .AND. TAPEID(2).EQ.P3(2)) GO TO 70
      WRITE  (NOUT,67) TAPEID,P3
 67   FORMAT ('0*** WRONG TAPE MOUNTED - TAPEID =',2A4,', NOT ',2A4)
      GO TO 40
 70   CALL PAGE2 (6)
      WRITE  (NOUT,75) TAPEID,NAME,DT,I
 75   FORMAT (/5X,'MODULE OUTPUT5 IS PROCESSING TAPE ',2A4, /5X,
     1       'WRITTEN BY ',2A4, /5X,'ON ',I2,1H/,I2,1H/,I2,  /5X,
     2       'BUFFSIZE USED =',I7,/)
      IF (K .EQ. 0) WRITE (NOUT,80) BINARY
      IF (K .GE. 1) WRITE (NOUT,80) FORMTD
 80   FORMAT (5X,'ORIGINAL TAPE IS ',A8)
      IF (K .EQ. P4) GO TO 90
      WRITE  (NOUT,85) UFM,P4
 85   FORMAT (A23,', THE 4TH PARAMETER TO OUTPUT5 DOES NOT AGREE WITH ',
     1       'ORIG. TAPE FORMAT    P4=',I5,/)
      CALL MESAGE (-37,0,SUBNAM)
C
C     TO SKIP P1 MATRIX DATA BLOCKS OR TABLES ON THE OLD OUTPUT FILE
C     OR TO TABULATE TAPE CONTENTS IF P1 = -3
C
 90   LFN = 0
 100  IF (P40 ) READ (OUT,    ERR=160,END=150) NC,JB,JE
      IF (P41S) READ (OUT,280,ERR=100,END=150) NC,JB,JE,( X,J=JB,JE)
      IF (P41C) READ (OUT,285,ERR=100,END=150) NC,JB,JE,( X,J=JB,JE)
      IF (P41D) READ (OUT,290,ERR=100,END=150) NC,JB,JE,(DX,J=JB,JE)
      IF (NC) 140,120,100
 110  IF (P40 ) READ (OUT,    ERR=160,END=150) L
      IF (P41 ) READ (OUT,115,ERR=100,END=150) L,(TABLE,J=1,L)
 115  FORMAT (I10,24A5,/,(26A5))
      IF (L) 140,120,110
 120  IF (P1.NE.-3 .AND. LFN.GE.P1) GO TO 140
      LFN = LFN + 1
      BACKSPACE OUT
      IF (P41) BACKSPACE OUT
      IF (P40) READ (OUT    ) I,I,I,DX,J,J,J,J,K,K,FN(1,LFN),FN(2,LFN)
      IF (P41) READ (OUT,250) I,I,I,DX,J,J,J,J,K,K,FN(1,LFN),FN(2,LFN)
      IF (K.GT.0 .AND. J.GE.1 .AND. J.LE.4) GO TO 130
      FN(3,LFN) = TBLE
      GO TO 110
 130  FN(3,LFN) = MTRX
      IF (P40) GO TO 100
      P41S = .FALSE.
      P41D = .FALSE.
      P41C =  P4.EQ.2 .AND. NBPW.GE.60
      IF (P41C) GO TO 100
      IF (J.EQ.1 .OR. J.EQ.3) P41S = .TRUE.
      P41D = .NOT.P41S
      GO TO 100
 140  IF (P41) BACKSPACE OUT
 150  BACKSPACE OUT
      IF (P1.EQ.-3 .AND. LFN.GT.0) GO TO 430
      GO TO 200
C
 160  WRITE  (NOUT,170) UWM,TAPEID
 170  FORMAT (A25,' FROM OUTPUT5 MODULE. ERROR WHILE READING ',2A4)
      GO TO 40
C
C     NEW TAPE (P1=-1)
C
C     WRITE A TAPE IDENTIFICATION RECORD (NOTE -THIS IS THE ONLY TIME
C     A TAPE HEADER RECORD IS WRITTEN)
C
 180  IF (P1 .NE. -1) GO TO 200
      REWIND OUT
      TRL(1) = P3(1)
      TRL(2) = P3(2)
      TRL(3) = MCHNAM
      TRL(4) = BLANK
      TRL(5) = DATE(1)
      TRL(6) = DATE(2)
      TRL(7) = DATE(3)
      IF (P40) WRITE (OUT    ) (TRL(J),J=1,7),IBUF,P4
      IF (P41) WRITE (OUT,185) (TRL(J),J=1,7),IBUF,P4
 185  FORMAT (4A4,5I8)
 190  LFN = 0
C
C     COPY MATRICES OR TABLES OUT TO TAPE
C
 200  DO 400 MX = 1,5
      INPUT = MX + 100
      CALL FNAME (INPUT,NAME)
      IF (NAME(1).EQ.NONE(1) .AND. NAME(2).EQ.NONE(2)) GO TO 390
      TRL(1) = INPUT
      CALL RDTRL (TRL)
      IF (TRL(1) .LE. 0) GO TO 390
      IF (TRL(1) .GT. 0) GO TO 220
      CALL PAGE2 (3)
      WRITE  (NOUT,210) INPUT,NAME
 210  FORMAT (/5X,'INPUT FILE ',2A4,'(',I3,') IS PURGED. NO DATA ',
     1       'TRANSFERRED TO OUTPUT FILE')
      GO TO 400
 220  IF (TRL(4).GT.8 .OR. TRL(5).GT.4 .OR. TRL(6).LE.0 .OR. TRL(7).LE.0
     1   ) CALL TABLE5 (*400,INPUT,OUT,TRL,BUF1,WRT,LFN,FN)
      COL  = TRL(2)
      ROW  = TRL(3)
      TYPE = TRL(5)
      COMPLX = .FALSE.
      IF (TYPE .GE. 3) COMPLX = .TRUE.
C
C     CHECK FOR NULL MATRIX
C
      IF (ROW.EQ.0 .OR. COL.EQ.0 .OR. TYPE.EQ.0) GO TO 380
C
C     SET FLAGS FOR FORMATTED OR UNFORMATTED WRITE, SINGLE OR DOUBLE
C     PRECISION DATA, THEN WRITE THE MATRIX HEADER WITH PROPER FORMAT.
C     MATRIX HEADER CONSISTS OF ONE SCRATCH WORD, ORIGINAL MATRIX
C     TRAILER, AND MATRIX DMAP NAME
C
      P40S = .FALSE.
      P40D = .FALSE.
      P41S = .FALSE.
      P41D = .FALSE.
      P41C =  P4.EQ.2 .AND. NBPW.GE.60
      IF (P41) GO TO 230
      IF (TYPE.EQ.1 .OR. TYPE.EQ.3) P40S = .TRUE.
      P40D = .NOT.P40S
      GO TO 240
 230  IF (P41C) GO TO 240
      IF (TYPE.EQ.1 .OR. TYPE.EQ.3) P41S = .TRUE.
      P41D = .NOT.P41S
 240  IF (P40) WRITE (OUT    ) IZERO,ONE,ONE,DZERO,(TRL(K),K=2,7),NAME
      IF (P41) WRITE (OUT,250) IZERO,ONE,ONE,DZERO,(TRL(K),K=2,7),NAME
 250  FORMAT (3I8,/,D26.17,6I8,2A4)
      WRT = 1
C
C     OPEN INPUT DATA BLOCK AND SAVE DMAP NAME IN FN ARRAY
C
      ERR = -1
      CALL OPEN (*50,INPUT,RZ(BUF1),0)
      CALL FWDREC (*50,INPUT)
      IF (LFN.EQ.-1 .OR. LFN.GE.10) GO TO 260
      LFN = LFN + 1
      FN(1,LFN) = NAME(1)
      FN(2,LFN) = NAME(2)
      FN(3,LFN) = MTRX
C
C     UNPACK A MATRIX COLUMN, AND WRITE TO OUTPUT FILE THE BANDED DATA
C     (FROM FIRST TO LAST NON-ZERO ELEMENTS)
C
 260  ITYP = TYPE
      INCR = 1
      DO 320 NC = 1,COL
      II = 0
      JJ = 0
      CALL UNPACK (*300,INPUT,RZ)
      JB = II
      JE = JJ
      NWDS = JJ - II + 1
      IF (.NOT.COMPLX) GO TO 270
      NWDS = NWDS + NWDS
      JE   = NWDS + JB - 1
 270  IF (NWDS .GT. BUF1) CALL MESAGE (-8,0,SUBNAM)
      IF (P40S) WRITE (OUT) NC,JB,JE,(RZ(J),J=1,NWDS)
      IF (P40D) WRITE (OUT) NC,JB,JE,(DZ(J),J=1,NWDS)
      IF (P41S) WRITE (OUT,280,ERR=480) NC,JB,JE,(RZ(J),J=1,NWDS)
      IF (P41C) WRITE (OUT,285,ERR=480) NC,JB,JE,(RZ(J),J=1,NWDS)
      IF (P41D) WRITE (OUT,290,ERR=480) NC,JB,JE,(DZ(J),J=1,NWDS)
 280  FORMAT (3I8,/,(10E13.6))
 285  FORMAT (3I8,/,(5E26.17))
 290  FORMAT (3I8,/,(5D26.17))
      GO TO 320
C
C     A NULL COLUMN
C
 300  JE = 1
      IF (COMPLX) JE = 2
      IF (P40S) WRITE (OUT    ) NC,ONE,JE,( ZERO,I=1,JE)
      IF (P40D) WRITE (OUT    ) NC,ONE,JE,(DZERO,I=1,JE)
      IF (P41S) WRITE (OUT,280) NC,ONE,JE,( ZERO,I=1,JE)
      IF (P41C) WRITE (OUT,285) NC,ONE,JE,( ZERO,I=1,JE)
      IF (P41D) WRITE (OUT,290) NC,ONE,JE,(DZERO,I=1,JE)
 320  CONTINUE
C
C     CLOSE INPUT DATA BLOCK WITH REWIND.
C
      CALL CLOSE (INPUT,1)
      CALL PAGE2 (10)
      WRITE  (NOUT,350) NAME,OUT,(TRL(J),J=2,5),IBUF
 350  FORMAT (/5X,'MODULE OUTPUT5 UNPACKED MATRIX DATA BLOCK ',2A4,
     1       ' AND WROTE IT OUT TO', /5X,'FORTRAN UNIT',I4,
     2       ', IN BANDED DATA FORM (FIRST TO LAST NON-ZERO ELEMENTS)',
     3       /9X,'NO. OF COLS =',I8, /9X,'NO. OF ROWS =',I8, /16X,
     4       'FORM =',I8, /16X,'TYPE =',I8, /5X,'SYSTEM BUFFSIZE =',I8)
      IF (P40 ) WRITE (NOUT,360)
      IF (P41S) WRITE (NOUT,365)
      IF (P41C) WRITE (NOUT,370)
      IF (P41D) WRITE (NOUT,375)
 360  FORMAT (5X,'IN FORTRAN BINARY RECORDS')
 365  FORMAT (5X,'IN FORTRAN FORMATTED RECORDS - (3I8,/,(10E13.6))')
 370  FORMAT (5X,'IN FORTRAN FORMATTED RECORDS - (3I8,/,(5E26.17))')
 375  FORMAT (5X,'IN FORTRAN FORMATTED RECORDS - (3I8,/,(5D26.17))')
      GO TO 400
C
C     NULL MATRIX, OR GINO DATA BLOCK IS NOT A MTRIX FILE
C
 380  CALL PAGE2 (5)
      WRITE  (NOUT,385) UWM,NAME
 385  FORMAT (A25,' FROM OUTPUT5 MODULE. ',2A4,' IS EITHER A NULL ',
     1       'MATRIX OR NOT A MATRIX DATA BLOCK', /5X,
     2       'NO DATA WERE COPIED TO OUTPUT FILE',/)
      GO TO 400
C
 390  TRL(1) = INPUT + 1
      CALL RDTRL (TRL)
      IF (TRL(1) .GT. 0) WRITE (NOUT,395) UWM,INPUT,NAME
 395  FORMAT (A25,' FROM OUTPUT5 MODULE. INPUT DATA BLOCK',I5,2H, ,2A4,
     1       ' IS EITHER PURGED OR DOES NOT EXIST')
C
 400  CONTINUE
C
      IF (WRT .EQ. 0) WRITE (NOUT,410) UWM
 410  FORMAT (A25,' FROM OUTPUT5 MODULE. NO DATA BLOCK WRITTEN TO ',
     1        'OUTPUT FILE')
      ENDFILE OUT
      BACKSPACE OUT
      IF (P1 .EQ. -3) GO TO 460
C
C     PRINT LIST OF DATA BLOCKS ON FORTRAN TAPE (P1=-3).
C
      IF (LFN .LE. 0) RETURN
 430  CALL PAGE2 (LFN+10)
      WRITE  (NOUT,440) OUT,MCHNAM,BF,(J,FN(1,J),FN(2,J),FN(3,J),
     1                  J=1,LFN)
 440  FORMAT (/5X,'SUMMARY FROM OUTPUT5 MODULE', //16X,'DATA BLOCKS ',
     1       'WRITTEN TO FORTRAN UNIT',I4, /17X,'(BY ',A4,' MACHINE, ',
     2       A8,' RECORDS)', ///22X,'FILE',8X,'NAME',8X,'TYPE' /17X,
     3       9(4H----), /,(22X,I3,9X,2A4,4X,A4))
      IF (P1 .EQ. -3) GO TO 200
      IF (P40) GO TO 460
      CALL PAGE2 (2)
      WRITE  (NOUT,450)
 450  FORMAT (/5X,'THIS FORMATTED OUTPUT FILE CAN BE VIEWED OR EDITED',
     1        ' VIA SYSTEM EDITOR',/)
C
 460  IF (MACH .EQ. 3) CALL UNVCLS (P2)
      IF (MACH .EQ. 4) CALL CDCCLS (P2)
      RETURN
C
C     WRITE ERROR
C
 480  WRITE  (NOUT,490) SFM
 490  FORMAT (A25,' IN WRITING OUTPUT FILE', /5X,'IBM USER - CHECK FILE'
     1,      ' ASSIGNMENT FOR DCB PARAMETER OF 132 BYTES')
      CALL MESAGE (-37,0,SUBNAM)
      END
