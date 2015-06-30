      SUBROUTINE PARAML
C
C     TO SELECT PARAMETERS FROM A GINO DATA BLOCK
C
C     PARAML  DB/ /C,N,OP/V,N,P1/V,N,P2/V,N,RSP/V,N,INTEG/V,N,RDP/
C                  V,N,BCD/V,N,SPLX/V,N,DPLX $
C
C     INPUT GINO FILE -
C       DB = TABLE  INPUT FILE IF OP='TABLEi'
C       DB = MATRIX INPUT FILE IF OP='MATRIX','NULL', etc.
C     OUTPUT GINO FILE -
C       NONE
C     INPUT PARAMETER -
C       OP    = OPERATION FLAG, ONE OF THE FOLLOWING KEY WORDS,
C               'MATRIX', 'NULL', 'PRESENCE', 'TRAILER', OR
C               'TABLE1' - ABSTRACT FROM 1 INPUT WORD TO FORM ALL OUTPUT
C                          DATA TYPE (INTEGER, S.P /D.P. REAL S.P./D.P.
C                          COMPLEX) AND 4-BYTE BCD WORD (1 WORD)
C               'TABLE2' - ABSTRACT FROM 2 INPUT WORDS TO FORM ALL
C                          OUTPUT DATA TYPE, AND 8-BYTE BCD (2 WORDS)
C               'TABLE4' - ABSTRACT FORM 4 INPUT WORDS TO FORM S.P./D.P.
C                          COMPLEX NUMBER
C               'TABLE1/2/4' OPERATES ONLY IN TABLE  DATA BLOCK, AND
C                THE OTHERS  OPERATE  ONLY IN MATRIX DATA BLOCK.
C
C                IF 'PRESENCE' IS ABBREVIATED AS 'PRES  ', THE USER
C                PARAML INFORMATION MESSAGE IS NOT ECHOED OUT.
C
C     INPUT/OUTPUT PARAMETERS -
C       P1    = RECORD NO. IF DB IS A TABLE, OR
C       P1    = ROW NO. IF DB IS A MATRIX
C               (DEFAULT=1)
C       P2    = WORD POSITION INDEX (BASED ON S.P.REAL WORD COUNT)
C               IF DB IS A TABLE, OR
C       P2    = COLUMN NUMBER, IF DB IS A MATRIX DATA BLOCK, S.P. OR
C               D.P.
C               (DEFAULT=1)
C       (ROW FIRST AND COLUMN SECOND - IN CONSISTANT WITH SCALAR MODULE)
C     OUTPUT PARAMETERS -
C       RSP   = SINGLE PRECISION REAL
C               (DATA ABSTRACTED FROM 1 OR 2 INPUT WORDS)
C       INTEG = INTEGER (DATA ABSTRACTED FROM 1 INPUT WORD)
C       RDP   = DOUBLE PREC. FLOATING NUMBERS (FROM 1 OR 2 INPUT WORDS)
C       BCD   = 8-BYTE BCD WORD, BLANK FILLED IF NECCESSARY
C       SPLX  = SINGLE PRECISION COMPLEX (FROM 1 TO 4 INPUT WORDS)
C       DPLX  = DOUBLE PRECISION COMPLEX (FROM 1 TO 4 INPUT WORDS)
C
      IMPLICIT INTEGER (A-Z)
      LOGICAL          TB1,TB2,TB4,MAT,PRT
      INTEGER          MCB(7),NAME(2),IVPS(1),OPCD(7),FNM(2),
     1                 NMVPS(2),EI(3),AT(2)
      REAL             Z(1),RSP,SPLX,SP(4),VPS,X,Y
      DOUBLE PRECISION DZ(1),RDP,DPLX,DP(2)
      CHARACTER*7      NTY(4)
      CHARACTER*10     TYPE(4)
      CHARACTER        UFM*23,UWM*25,UIM*29
      COMMON /XMSSG /  UFM,UWM,UIM
      COMMON /XVPS  /  VPS(2)
      COMMON /UNPAKX/  ITYP,II,JJ,INCR
      COMMON /ILOCAL/  IL(2),IL3,IL4,IL5,IL6,IL7,IL8,IL9
      COMMON /SYSTEM/  SYSBUF,NOUT
      COMMON /BLANK /  OP(2),P1,P2,RSP,INTEG,RDP,BCD(2),SPLX(2),DPLX(2)
CZZ   COMMON /ZZPARM/  IZ(1)
      COMMON /ZZZZZZ/  IZ(1)
      EQUIVALENCE      (VPS(1),IVPS(1)) ,(Z(1),IZ(1),DZ(1))
      EQUIVALENCE      (SP(1) ,  DP(1))
      DATA NAME / 4HPARA,4HML  /,BLANK/4H     /, AT/ 4HAND ,4HTHRU /
      DATA OPCD / 4HTABL,4HMATR,4HPRES,4HNULL,4HTRAI,4HDTI ,4HDMI  /
      DATA FIRST/ 12 /  ,IN1   / 101  /,   EI /2HE1, 2HE2, 2HE4    /
      DATA NTY  / 'ZERO', 'INTEGER', 'REAL',  'BCD' /
      DATA TYPE / 'S.P. REAL ', 'D.P. REAL ', 'S.P. CMPLX', 'D.P.CMPLX'/
C
C     SUPPRESS ALL PARAML CHECKING MESSAGES IF DIAG 37 IS ON
C
      CALL SSWTCH (37,I)
      PRT   = I .EQ. 0
      NZ    = KORSZ(IZ)
      IBUF1 = NZ - SYSBUF + 1
      IF (IBUF1 .LE. 0) GO TO 1220
      FLAG  = 1
      MCB(1)= IN1
      CALL RDTRL (MCB)
      IF (MCB(1) .GT. 0) GO TO 20
C
C     INPUT PURGED.  RETURN IF OP(1) IS NOT 'PRES'
C
      IF (OP(1) .NE. OPCD(3)) GO TO 1240
      FLAG  =-1
      CALL FNDPAR (-5,IL5)
      IF (PRT .AND. OP(2).NE.BLANK) WRITE (NOUT,40) UIM,OP
   10 INTEG = FLAG
      IVPS(IL5) = FLAG
      NMVPS(1) = IVPS(IL5-3)
      NMVPS(2) = IVPS(IL5-2)
      IF (PRT .AND. OP(2).NE.BLANK) WRITE (NOUT,510) INTEG,NMVPS
      GO TO 1240
C
   20 PREC = MCB(5)
      CALL FNAME (IN1,FNM)
      DO 30 J=3,9
      CALL FNDPAR (-J,IL(J))
   30 CONTINUE
      IF (OP(1).EQ.OPCD(3) .AND. OP(2).EQ.BLANK) GO TO 200
      IF (OP(1) .EQ. OPCD(4)) GO TO 210
      IF (.NOT.PRT) GO TO 45
      CALL PAGE2 (FIRST)
      FIRST = 5
      WRITE  (NOUT,40) UIM,OP
   40 FORMAT (A29,' FROM PARAML MODULE  - ',2A4, ' -', /5X,
     1       '(ALL PARAML MESSAGES CAN BE SUPPRESSED BY DIAG 37)',/)
C
C     IDENTIFY OPCODE
C
   45 DO 50 I = 1,7
      IF (OP(1) .EQ. OPCD(I)) GO TO (300,800,200,210,220,90,90), I
   50 CONTINUE
   60 WRITE  (NOUT,70) UFM,OP
   70 FORMAT (A23,', ILLEGAL OP REQUEST TO MODULE PARAML - ',2A4)
   80 CALL MESAGE (-37,0,NAME)
C
   90 IF (.NOT.PRT) GO TO 60
      WRITE  (NOUT,100) UIM
  100 FORMAT (A29,', NEW PARAMETERS USED IN PARAML MODULE:', //5X,
     1 'PARAML  DB//C,N,OP/C,N,P1/V,N,P2/V,N,RSP/V,N,INT/V,N,RDP/',
     2 'V,N,BCD/V,N,CSX/V,N,CDX  $', /13X,
     3 'OP      = OPCODE, ONE OF THE FOLLOWING KEY WORDS, BCD INPUT, N',
     4 'O DEFAULT', /23X,43H'MATRIX', 'NULL', 'PRESENCE', 'TRAILER', OR,
     5 /23X,28H'TABLE1', 'TABLE2', 'TABLE4',
     6 /13X,'P1,P2   = RECORD NO. AND WORD POSITION IF OP= TABLEi',
     7 /21X,'= ROW AND COLUMN INDEXES IF OP= MATRIX,  INTEGERS INPUT',
     8 /21X,'= P2 GIVES THE VALUE OF P1 TRAILER WORD IF OP= TRAILER',
     9 /13X,'RSP,RDP = SINGLE PRECISION AND DOUBLE PREC. REAL, OUTPUT',
     O /23X,'(DEFAULTS ARE 0.0 AND 0.D+0,  PREVIOUS DEFAULTS WARE ONES',
     1 /13X,'INT,BCD = INTEGER AND 2-BCD WORDS OUTPUT', /23X,'INT =-1,',
     2 ' IF NULL MATRIX AND OP= NULL, OR PURGED DB AND OP= PRESENCE',
     3 /13X,'CSX,CDX = SINGLE PRECISION AND DOUBLE PRECISION COMPLEX, ',
     4 'OUTPUT', //5X,'EXAMPLE - ',
     5 'ABSTRACT THE 3RD COL. 9TH ROW ELEMENT OF KGG MATRIX, AND', /15X,
     6 'ABSTRACT THE 3RD RECORD AND 9TH WORD  OF EPT DATA BLCOK', //5X,
     7 'PARAML  KGG//*MATRIX*/C,N,9/C,N,3/V,N,R93//V,N,D93//V,N,CS93',
     8 /5X,'PARAML  EPT//*TABLE1*/C,N,3/C,N,9//V,N,I39/V,N,D39',/)
      IF (I .EQ. 6) WRITE (NOUT,110)
      IF (I .EQ. 7) WRITE (NOUT,120)
 110  FORMAT (5X,'SUGGESTION- REPLACE THE OPCODE ''DTI'' BY ''TABLE1''')
 120  FORMAT (5X,'SUGGESTION- REPLACE THE OPCODE ''DMI'' BY ''MATRIX''',
     1      /18X,'AND NOTE THAT P1 IS ROW NUMBER AND P2 IS COLUMN NO.')
      GO TO 60
C
C     OP = PRESENCE
C     TEST FOR PRESENCE OF DATA BLOCK
C
  200 GO TO 10
C
C     OP = NULL
C     TEST FOR NULL MATRIX DATA BLOCK
C
  210 IF (MCB(7) .EQ. 0) FLAG =-1
      GO TO 10
C
C     OP = TRAILER
C     PLACE THE (P1+1) WORD OF THE TRAILER IN P2
C
  220 IF (P1.LE.0 .OR. P1.GE.7) GO TO 230
      P2 = MCB(P1+1)
      IVPS(IL3) = P2
      NMVPS(1) = IVPS(IL3-3)
      NMVPS(2) = IVPS(IL3-2)
      IF (PRT) WRITE (NOUT,510) P2,NMVPS
      GO TO 1240
  230 WRITE  (NOUT,240) UFM,P1
  240 FORMAT (A23,', 2ND PARAMETER IN PARAML MODULE IS ILLEGAL',I5)
      GO TO 80
C
C     OP = TABLE
C     PROCESS TABLE TYPE DATA BLOCK
C
  300 TB1 = .FALSE.
      TB2 = .FALSE.
      TB4 = .FALSE.
      IF (OP(2) .EQ. EI(1)) TB1 = .TRUE.
      IF (OP(2) .EQ. EI(2)) TB2 = .TRUE.
      IF (OP(2) .EQ. EI(3)) TB4 = .TRUE.
      IF (.NOT.TB1 .AND. .NOT.TB2 .AND. .NOT.TB4) GO TO 60
      MAT = .FALSE.
      RECNO = P1
      INDEX = P2
      IF (TB2) IXP1 = INDEX+1
      IF (TB4) IXP1 = INDEX+3
      ATX = AT(1)
      IF (TB4) ATX = AT(2)
      CALL OPEN (*1200,IN1,IZ(IBUF1),0)
      CALL SKPREC (IN1,RECNO)
      CALL READ (*1210,*310,IN1,IZ,IBUF1-1,1,RL)
      GO TO 1220
  310 IF (INDEX .GT. RL) GO TO 1210
      IF (IL4 .LE. 0) GO TO 500
C
C     OUTPUT REQUEST IN S.P. REAL
C
      IF (.NOT.PRT) GO TO 350
      IF (.NOT.TB1) GO TO 330
      WRITE  (NOUT,320) FNM,RECNO,INDEX
  320 FORMAT (5X,'INPUT FILE ',2A4,' RECORD',I6,' WORD',I6,13X, '=')
      GO TO 350
  330 WRITE  (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  340 FORMAT (5X,'INPUT FILE ',2A4,' RECORD',I6,' WORDS',I6,1X,A4,I5,
     1       '  =')
  350 NMVPS(1) = IVPS(IL4-3)
      NMVPS(2) = IVPS(IL4-2)
      IF (TB4) GO TO 400
      IF (TB2) GO TO 355
      RSP = Z(INDEX)
      IF (MAT) GO TO 360
      K = NUMTYP(RSP)+1
      IF (K.EQ.2 .OR. K.EQ.4) GO TO 400
      GO TO 360
  355 K = -1
      IF (INDEX+1 .GT. RL) GO TO 400
      SP(1) = Z(INDEX  )
      SP(2) = Z(INDEX+1)
CWKBI
      IF ( SP(2) .EQ. 0.0 ) DP(1) = SP(1)
      RSP = SNGL(DP(1))
      K = NUMTYP(RSP)+1
      IF (K.EQ.2 .OR. K.EQ.4) GO TO 400
  360 IF (PRT) WRITE (NOUT,370) RSP,NMVPS
  370 FORMAT ('+', 70X,E15.8,'   = ',2A4)
      VPS(IL4) = RSP
      GO TO 500
C
  400 IF (.NOT.PRT) GO TO 500
      WRITE  (NOUT,410) NMVPS
  410 FORMAT ('+',70X,'(INVALID REQUEST) = ',2A4)
      IF (K .GT. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ.-1) WRITE (NOUT,430) UWM,NMVPS
  420 FORMAT (A25,' - ILLEGAL OUTPUT REQUESTED. ORIG. DATA TYPE IS ',A7,
     1       ',  PARAMETER ',2A4,' NOT SAVED')
  430 FORMAT (A25,' - E-O-R ENCOUNTERED.  PARAMETER ',2A4,' NOT SAVED')
C
  500 IF (IL5.LE.0 .OR. MAT) GO TO 540
C
C     OUTPUT REQUEST IS INTEGER
C
      IF (.NOT.PRT) GO TO 505
      IF (     TB1) WRITE (NOUT,320) FNM,RECNO,INDEX
      IF (.NOT.TB1) WRITE (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  505 NMVPS(1) = IVPS(IL5-3)
      NMVPS(2) = IVPS(IL5-2)
      K = 0
      IF (TB2 .OR. TB4) GO TO 520
      INTEG = IZ(INDEX)
      K = NUMTYP(INTEG)+1
      IF (K .GT. 2) GO TO 520
      IVPS(IL5) = INTEG
      IF (PRT) WRITE (NOUT,510) INTEG,NMVPS
  510 FORMAT ('+',70X,I15,'   = ',2A4)
      GO TO 540
C
  520 IF (.NOT.PRT) GO TO 540
      WRITE (NOUT,410) NMVPS
      IF (K .GT. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ. 0) WRITE (NOUT,530) UWM,NMVPS
  530 FORMAT (A25,' - ILLEGAL INTEGER ABSTRACTION FROM 2 OR 4 DATA ',
     1       'WORDS.  OUPUT PARAMETER ',2A4,' NOT SAVED')
      GO TO 540
C
  540 IF (IL6 .LE. 0) GO TO 600
C
C     OUTPUT REQUEST IN D.P. REAL
C
      IF (.NOT.PRT) GO TO 545
      IF (     TB1) WRITE (NOUT,320) FNM,RECNO,INDEX
      IF (.NOT.TB1) WRITE (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  545 NMVPS(1) = IVPS(IL6-3)
      NMVPS(2) = IVPS(IL6-2)
      IF (MAT) GO TO 560
      IF (TB2) GO TO 550
      IF (TB4) GO TO 590
      K = NUMTYP(Z(INDEX))+1
      IF (K.EQ.2 .OR. K.EQ.4) GO TO 590
      DP(1) = DBLE(Z(INDEX))
      GO TO 570
  550 K =-1
      J = 0
      IF (INDEX+1 .GT. RL) GO TO 590
      SP(1) = Z(INDEX  )
      SP(2) = Z(INDEX+1)
      X = SNGL(DP(1))
      J = NUMTYP(X)+1
      IF (J.EQ.2 .OR. J.EQ.4) GO TO 590
      GO TO 570
  560 IF (PREC .EQ. 1) DP(1) = DBLE(Z(INDEX))
CWKBI
  570 IF ( SP(2) .EQ. 0.0 ) DP(1) = SP(1)
CWKBR  570 RDP = DP(1)
      RDP = DP(1)
      VPS(IL6  ) = SP(1)
      VPS(IL6+1) = SP(2)
      IF (PRT) WRITE (NOUT,580) RDP,NMVPS
  580 FORMAT ('+',70X,D15.8,'   = ',2A4)
      GO TO 600
C
  590 IF (.NOT.PRT) GO TO 600
      WRITE (NOUT,410) NMVPS
      IF (J.EQ.2 .OR. J.EQ.4) K = J
      IF (K .GT. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ.-1) WRITE (NOUT,430) UWM,NMVPS
C
  600 IF (IL7.LE.0 .OR. MAT) GO TO 650
C
C     OUTPUT REQUEST IN BCD
C
      IF (.NOT.PRT) GO TO 605
      IF (     TB1) WRITE (NOUT,320) FNM,RECNO,INDEX
      IF (.NOT.TB1) WRITE (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  605 NMVPS(1) = IVPS(IL7-3)
      NMVPS(2) = IVPS(IL7-2)
      K = 0
      IF (TB4) GO TO 630
      BCD(1) = IZ(INDEX)
      BCD(2) = BLANK
      K = NUMTYP(BCD(1))+1
      IF (K .NE. 4) GO TO 630
      IF (TB1) GO TO 610
      K = -1
      IF (INDEX+1 .GT. RL) GO TO 630
      BCD(2) = IZ(INDEX+1)
      K = NUMTYP(BCD(2))+1
      IF (K .NE. 4) GO TO 630
  610 IVPS(IL7  ) = BCD(1)
      IVPS(IL7+1) = BCD(2)
      IF (PRT) WRITE (NOUT,620) BCD,NMVPS
  620 FORMAT ('+',70X,2A4,'   = ',2A4)
      GO TO 650
C
  630 IF (.NOT.PRT) GO TO 650
      WRITE (NOUT,410) NMVPS
      IF (K .GT. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ. 0) WRITE (NOUT,640) UWM,NMVPS
      IF (K .EQ.-1) WRITE (NOUT,430) UWM,NMVPS
  640 FORMAT (A25,' - ILLEGAL BCD ABSTRACTION FROM 4 DATA WORDS. ',
     1       ' PARAMETER ',2A4,'NOT SAVED')
C
  650 IF (IL8 .LE. 0) GO TO 700
C
C     OUTPUT REQUEST IN S.P. COMPLEX
C
      IF (.NOT.PRT) GO TO 655
      IF (     TB1) WRITE (NOUT,320) FNM,RECNO,INDEX
      IF (.NOT.TB1) WRITE (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  655 NMVPS(1) = IVPS(IL8-3)
      NMVPS(2) = IVPS(IL8-2)
      K =-1
      J = 0
      IF (TB4) GO TO 660
      SPLX(1) = Z(INDEX)
      SPLX(2) = 0.0
      IF (TB1 .OR. MAT) GO TO 670
      IF (INDEX+1 .GT. RL) GO TO 690
      SPLX(2) = Z(INDEX+1)
      GO TO 670
  660 IF (INDEX+3 .GT. RL) GO TO 690
      SP(1)   = Z(INDEX  )
      SP(2)   = Z(INDEX+1)
      SP(3)   = Z(INDEX+2)
      SP(4)   = Z(INDEX+3)
      SPLX(1) = SNGL(DP(1))
      SPLX(2) = SNGL(DP(2))
  670 J = NUMTYP(SPLX(1))+1
      K = NUMTYP(SPLX(2))+1
      IF (J.EQ.2 .OR. J.EQ.4 .OR. K.EQ.2 .OR. J.EQ.4) GO TO 690
      VPS(IL8  ) = SPLX(1)
      VPS(IL8+1) = SPLX(2)
      IF (PRT) WRITE (NOUT,680) SPLX,NMVPS
  680 FORMAT ('+',70X,'(',E15.8,',',E15.8,')','  = ',2A4)
      GO TO 700
C
  690 IF (.NOT.PRT) GO TO 700
      WRITE (NOUT,410) NMVPS
      IF (J.EQ.2 .OR. J.EQ.4) K = J
      IF (K .EQ. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ.-1) WRITE (NOUT,430) UWM,NMVPS
C
  700 IF (IL9 .LE. 0) GO TO 1100
C
C     OUTPUT REQUEST IN D.P. COMPLEX
C
      IF (.NOT.PRT) GO TO 705
      IF (     TB1) WRITE (NOUT,320) FNM,RECNO,INDEX
      IF (.NOT.TB1) WRITE (NOUT,340) FNM,RECNO,INDEX,ATX,IXP1
  705 NMVPS(1) = IVPS(IL9-3)
      NMVPS(2) = IVPS(IL9-2)
      K =-1
      J = 0
      IF (TB4) GO TO 710
      K = NUMTYP(Z(INDEX))+1
      IF (K.EQ.2 .OR. K.EQ.4) GO TO 740
      DP(1) = DBLE(Z(INDEX))
      DP(2) = 0.D0
      IF (TB1 .OR. MAT) GO TO 720
      IF (INDEX+1 .GT. RL) GO TO 740
      K = NUMTYP(Z(INDEX+1))+1
      IF (K.EQ.2 .OR. K.EQ.4) GO TO 740
      DP(2) = DBLE(Z(INDEX+1))
      GO TO 720
  710 IF (INDEX+3 .GT. RL) GO TO 740
      SP(1) = Z(INDEX  )
      SP(2) = Z(INDEX+1)
      SP(3) = Z(INDEX+2)
      SP(4) = Z(INDEX+3)
      X = SNGL(DP(1))
      Y = SNGL(DP(2))
      J = NUMTYP(X)+1
      K = NUMTYP(Y)+1
      IF (J.EQ.2 .OR. J.EQ.4 .OR. K.EQ.2 .OR. K.EQ.4) GO TO 740
      DP(1)   = DBLE(Z(INDEX))
      DP(2)   = 0.D0
  720 DPLX(1) = DP(1)
      DPLX(2) = DP(2)
      VPS(IL9  ) = SP(1)
      VPS(IL9+1) = SP(2)
      VPS(IL9+2) = SP(3)
      VPS(IL9+3) = SP(4)
      IF (PRT) WRITE (NOUT,730) DPLX,NMVPS
  730 FORMAT ('+', 70X, '(', D15.8, ',', D15.8, ')', '  = ',2A4)
      GO TO 1100
C
  740 IF (.NOT.PRT) GO TO 1100
      WRITE (NOUT,410) NMVPS
      IF (J.EQ.2 .OR. J.EQ.4) K = J
      IF (K .GT. 0) WRITE (NOUT,420) UWM,NTY(K),NMVPS
      IF (K .EQ.-1) WRITE (NOUT,430) UWM,NMVPS
      GO TO 1100
C
C     OP = MATRIX
C     PROCESS MATRIX TYPE DATA BLOCK
C
  800 ROW  = P1
      COL  = P2
      ITYP = MCB(5)
      IF (IL5 .LE. 0) GO TO 840
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
  810 FORMAT (5X,'ELEMENT (',I5,'-ROW,',I5,'-COL) OF ',A10,' INPUT ',
     1       'FILE ',2A4,2H =)
      NMVPS(1) = IVPS(IL5-3)
      NMVPS(2) = IVPS(IL5-2)
      IF (.NOT.PRT) GO TO 840
      WRITE  (NOUT,820) NMVPS
  820 FORMAT ('+',70X,'(INVALID INTEGER) = ',2A4)
      WRITE  (NOUT,830) UWM,NMVPS
  830 FORMAT (A25,' - OUTPUT PARAMETER ',2A4,' NOT SAVED')
  840 IF (IL7 .LE. 0) GO TO 860
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      NMVPS(1) = IVPS(IL7-3)
      NMVPS(2) = IVPS(IL7-2)
      IF (.NOT.PRT) GO TO 860
      WRITE  (NOUT,850) NMVPS
  850 FORMAT ('+',70X,'(INVALID BCD WORD)= ',2A4)
      WRITE  (NOUT,830) UWM,NMVPS
C
  860 IF (IL4.LE.0 .AND. IL6.LE.0 .AND. IL8.LE.0 .AND. IL9.LE.0)
     1   GO TO 1240
C
C     OUTPUT REQUEST - IL4 - S.P. REAL
C                      IL5 - INTEGER
C                      IL6 - D.P. REAL
C                      IL7 - BCD
C                      IL8 - S.P. COMPLEX
C                      IL9 - D.P. COMPLEX
C
      MAT   = .TRUE.
      TB1   = .FALSE.
      TB2   = .FALSE.
      TB4   = .FALSE.
      RECNO = P2
      INDEX = P1
      RL    = 999999
      II    = 1
      JJ    = MCB(3)
      INCR  = 1
      CALL GOPEN (IN1,IZ(IBUF1),0)
      CALL SKPREC (IN1,COL-1)
      CALL UNPACK (*1030,IN1,Z)
      GO TO (900,910,950,950), ITYP
C
C     INPUT MATRIX PRECISION TYPE = 1, S.P. REAL
C
  900 GO TO 350
C
C     MATRIX PRECISION TYPE = 2, D.P. REAL
C
  910 IF (IL4 .LE. 0) GO TO 920
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      RSP = DZ(ROW)
      VPS(IL4) = RSP
      NMVPS(1) = IVPS(IL4-3)
      NMVPS(2) = IVPS(IL4-2)
      IF (PRT) WRITE (NOUT,370) RSP,NMVPS
  920 IF (IL6 .LE. 0) GO TO 930
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      RDP   = DZ(ROW)
      DP(1) = RDP
      VPS(IL6  ) = SP(1)
      VPS(IL6+1) = SP(2)
      NMVPS(1) = IVPS(IL6-3)
      NMVPS(2) = IVPS(IL6-2)
      IF (PRT) WRITE (NOUT,580) RDP,NMVPS
  930 IF (IL8 .LE. 0) GO TO 940
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      SPLX(1) = DZ(ROW)
      SPLX(2) = 0.0
      VPS(IL8  ) = SPLX(1)
      VPS(IL8+1) = SPLX(2)
      NMVPS(1) = IVPS(IL8-3)
      NMVPS(2) = IVPS(IL8-2)
      IF (PRT) WRITE (NOUT,680) SPLX,NMVPS
  940 IF (IL9 .LE. 0) GO TO 1100
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      DP(1) = DZ(ROW)
      DP(2) = 0.D0
      NMVPS(1) = IVPS(IL9-3)
      NMVPS(2) = IVPS(IL9-2)
      GO TO 720
C
C     INPUT MATRIX PRECISION TYPE = 3 OR 4, COMPLEX
C
  950 IF (IL4 .LE. 0) GO TO 970
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      NMVPS(1) = IVPS(IL4-3)
      NMVPS(2) = IVPS(IL4-2)
      IF (.NOT.PRT) GO TO 970
      WRITE  (NOUT,960) NMVPS
  960 FORMAT ('+',70X,' (INVALID S.P. REAL NUMBER)  = ',2A4)
      WRITE  (NOUT,830) UWM,NMVPS
  970 IF (IL6 .LE. 0) GO TO 990
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      NMVPS(1) = IVPS(IL6-3)
      NMVPS(2) = IVPS(IL6-2)
      IF (PRT) WRITE (NOUT,980) NMVPS
  980 FORMAT ('+',70X,' (INVALID D.P.REAL NUMBER)  = ',2A4)
  990 IF (IL8.LE.0 .AND. IL9.LE.0) GO TO 1100
      IF (ITYP .EQ. 4) GO TO 1010
C
C     INPUT MATRIX PRECISION TYPE = 3, S.P.COMPLEX
C
      IF (IL8 .LE. 0) GO TO 1000
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      SPLX(1) = Z(ROW  )
      SPLX(2) = Z(ROW+1)
      VPS(IL8  ) = SPLX(1)
      VPS(IL8+1) = SPLX(2)
      NMVPS(1) = IVPS(IL8-3)
      NMVPS(2) = IVPS(IL8-2)
      IF (PRT) WRITE (NOUT,680) SPLX,NMVPS
 1000 IF (IL9 .LE. 0) GO TO 1100
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      DP(1) = DBLE(Z(ROW  ))
      DP(2) = DBLE(Z(ROW+1))
      NMVPS(1) = IVPS(IL9-3)
      NMVPS(2) = IVPS(IL9-2)
      GO TO 720
C
C     INPUT MATRIX PRECISION TYPE = 4, D.P.COMPLEX
C
 1010 IF (IL8 .LE. 0) GO TO 1020
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      SPLX(1) = SNGL(DZ(ROW  ))
      SPLX(2) = SNGL(DZ(ROW+1))
      VPS(IL8  ) = SPLX(1)
      VPS(IL8+1) = SPLX(2)
      NMVPS(1) = IVPS(IL8-3)
      NMVPS(2) = IVPS(IL8-2)
      IF (PRT) WRITE (NOUT,680) SPLX,NMVPS
 1020 IF (IL9 .LE. 0) GO TO 1100
      IF (PRT) WRITE (NOUT,810) ROW,COL,TYPE(ITYP),FNM
      DP(1) = DZ(ROW  )
      DP(2) = DZ(ROW+1)
      NMVPS(1) = IVPS(IL9-3)
      NMVPS(2) = IVPS(IL9-2)
      GO TO 720
C
C     NULL INPUT MATRIX ELEMENT
C
 1030 Z (ROW  ) = 0.
      Z (ROW+1) = 0.
      DZ(ROW  ) = 0.D0
      DZ(ROW+1) = 0.D0
      GO TO (900,910,950,950), ITYP
C
 1100 CALL CLOSE (IN1,1)
      GO TO 1240
C
C     ERRORS
C
 1200 J = -1
      GO TO 1230
 1210 J = -2
      GO TO 1230
 1220 J = -8
 1230 CALL MESAGE (J,IN1,NAME)
C
 1240 RETURN
      END
