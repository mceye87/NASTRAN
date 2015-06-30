      SUBROUTINE RCARD2 (OUT,FMT,NFLAG,IN)
CDIR$ INTEGER=64
C
C     CDIR$ IS CRAY COMPILE DIRECTIVE. 64-BIT INTEGER IS USED LOCALLY
C
C     THIS ROUTINE IS MUCH MORE EFFICIENT THAN THE OLD ROUTINE RCARD
C     IT CAN SAFELY REPLACE THE OLD RCARD ROUTINE
C     WRITTEN BY G.CHAN/UNISYS            10/1987
C     REVISED, 8/1989, IMPROVED EFFICIENCY BY REDUCING CHARACTER
C     OPERATIONS (VERY IMPORTANT FOR CDC MACHINE)
C     LAST REVISED, 8/1991, SETTING UP REAL NO. UPPER AND LOWER BOUNDS
C     FOR VARIOUS MACHINES
C
C     RCARD2 ASSUMES ALL INPUT FIELDS IN 'IN' ARE LEFT-ADJUSTED.
C
      IMPLICIT INTEGER (A-Z)
      EXTERNAL         LSHIFT   ,RSHIFT   ,COMPLF
      LOGICAL          SEQGP    ,DECIML   ,MINUS    ,NOGO     ,
     1                 EXPONT   ,DOUBLE   ,BLKON
      INTEGER          IN(20)   ,OUT(1)   ,FMT(1)   ,TYPE(16) ,
     1                 NT(16)   ,OUTX(100),IDOUBL(2),VALUE(16),
     2                 NUM1(9)  ,CHR1(16) ,A1(80)
      REAL             FPT
      DOUBLE PRECISION DDOUBL
      CHARACTER*1      BLANKC   ,STARC    ,DOTC     ,PLUSC    ,
     1                 MINUSC   ,DC       ,EC       ,ZEROC    ,
     2                 KHR1(16) ,K1(80)
      CHARACTER*4      IN4(40)  ,C4(1)    ,CHR4(4)  ,OUT4(100)
      CHARACTER*5      D5       ,SEQGP5   ,SEQEP5
      CHARACTER*100    TMP100   ,OUT100(4)
      CHARACTER        NUM9*9   ,UFM*23   ,E80*80
      COMMON /XMSSG /  UFM
      COMMON /LHPWX /  LOWPW    ,HIGHPW
      COMMON /SYSTEM/  BUFSZ    ,NOUT     ,NOGO     ,DUM1(8)  ,
     1                 NLINES
      COMMON /XECHOX/  DUM2(4)  ,XSORT2
      EQUIVALENCE      (CHR11,CHR1(1)),   (K1(1),IN4(1),D5,E80),
     1                 (FPT,INTGR),       (KHR1(1),CHR4(1)),
     2                 (DDOUBL,IDOUBL(1)),(OUT4(1),OUT100(1))
      DATA    BLANKC,  STARC,   PLUSC,  MINUSC,  DOTC,  EC,   DC    /
     1        ' ',     '*',     '+',    '-',     '.',   'E',  'D'   /
      DATA    BLANK,   STARS,   SEQGP5, SEQEP5,  ZEROC, NUM9        /
     1        4H    ,  4H====,  'SEQGP','SEQEP', '0',   '123456789' /
      DATA    PLUS1 /  0    /
C
      IF (PLUS1 .NE. 0) GO TO 10
      CALL K2B (BLANKC,BLANK1,1)
      CALL K2B (STARC ,STAR1 ,1)
      CALL K2B (PLUSC ,PLUS1 ,1)
      CALL K2B (MINUSC,MINUS1,1)
      CALL K2B (DOTC  ,DOT1  ,1)
      CALL K2B (EC    ,E1    ,1)
      CALL K2B (DC    ,D1    ,1)
      CALL K2B (ZEROC ,ZERO1 ,1)
      CALL K2B (NUM9  ,NUM1  ,9)
   10 CONTINUE
C
C     WRITE  (E80,15) IN
C  15 FORMAT (20A4)
      CALL BCDKH8 (IN,E80)
      CALL K2B (E80,A1,80)
      GO TO 30
C
C
      ENTRY RCARD3 (OUT,FMT,NFLAG,C4)
C     ===============================
C
C     IN RCARD2, 'IN' IS 4-BYTE BCD  AND 'OUT' IS 4-BYTE BCD
C     IN RCARD3, 'C4' IS CHARACTER*4 AND 'OUT' IS 4-BYTE BCD
C     'IN' AND 'C4' ARE INPUT, AND 'OUT' IS OUTPUT
C
      DO 20 I = 1,20
   20 IN4(I) = C4(I)
      CALL K2B (C4,A1,80)
C
   30 FIELD  = 0
      IOUT   = 0
      IFMT   = 0
      WORD   = 0
      NWORDS = 2
      SEQGP  = .FALSE.
      A67777 = RSHIFT(LSHIFT(COMPLF(0),1),1)/10 - 10
      N 8 OR 16 = 8
      DO 40 I = 1,100
   40 OUTX(I) = BLANK
C
C     PROCESS ONE FIELD (2 OR 4 WORDS) AT A TIME,
C     GET FIRST NON-BLANK CHARATER
C
   50 IF (WORD .EQ. 18) GO TO 860
      FIELD  = FIELD + 1
      DECIML =.FALSE.
      MINUS  =.FALSE.
      EXPONT =.FALSE.
      DOUBLE =.FALSE.
      BLKON  =.FALSE.
      SIGN1  = BLANK1
      PLACES = 0
      IT     = 0
      POWER  = 0
C
C     READ 8 OR 16 CHARATERS OF ONE FIELD
C     FOR EACH CHARACTER, SET TYPE TO
C            0 IF IT IS A BLANK
C           -1 IF IT IS BCD CHARACTER, AND
C           +1 IF IT IS NUMERIC
C
      BASE = WORD*4
      WORD = WORD + NWORDS
      DO 110 N = 1,N 8 OR 16
      A1NB = A1(N+BASE)
      IF (A1NB .EQ. BLANK1) GO TO 70
      IF (A1NB .EQ. ZERO1 ) GO TO 80
      DO 60 K = 1,9
      IF (A1NB .EQ. NUM1(K)) GO TO 90
   60 CONTINUE
      TYPE(N) = -1
      GO TO 100
   70 TYPE(N) = 0
      GO TO 100
   80 K = 0
   90 TYPE(N) = 1
      VALUE(N)= K
  100 CHR1(N) = A1NB
      KHR1(N) = K1(N+BASE)
  110 CONTINUE
C
      IF (SEQGP) GO TO (120,120,690,120,690,120,690,120,690), FIELD
C
C     BRANCH ON BCD, BLANK, OR NUMERIC
C
  120 IF (TYPE(1)) 150,  130,    320
C                  BCD BLANK NUMERIC
C
C     A BLANK FIELD -
C     ===============
C
  130 IF (FIELD .EQ. 1) GO TO 180
  140 IOUT       = IOUT + 1
      OUTX(IOUT) = 0
      IFMT       = IFMT + 1
      FMT(IFMT)  = 0
      GO TO 50
C
C     BCD FIELD -
C     ===========
C
C     FIRST NON-BLANK CHARATER IS ALPHA, STAR, DOT, PLUS, OR MINUS
C
  150 IF (FIELD.EQ.1 .AND. CHR11.EQ.STAR1) GO TO 270
      IF (CHR11 .EQ. PLUS1 ) GO TO 290
      IF (CHR11 .EQ. DOT1  ) GO TO 300
      IF (CHR11 .EQ. MINUS1) GO TO 310
C
C     TRUE ALPHA BCD-CHARACTER FIELD
C
C     CHECKING FOR DOULBE-FIELD ASTERISK (*) IF WE ARE IN FIELD 1
C     SET DOUBLE FLAGS N8OR16, NWORDS, AND REMOVE THE ASTERISK
C
      IF (FIELD .NE. 1) GO TO 180
      J = 8
      DO 160 I = 2,8
      IF (CHR1(J).EQ.STAR1 .AND. TYPE(J).EQ.-1) GO TO 170
  160 J = J - 1
      GO TO 180
  170 NWORDS = 4
      N 8 OR 16 = 16
      CHR1(J) = BLANK1
      KHR1(J) = BLANKC
C
  180 IOUT = IOUT + 2
      IF (TYPE(1)) 190,200,190
  190 IF (NWORDS.EQ.4 .AND. FIELD.EQ.1) GO TO 200
      N = WORD - NWORDS
      OUT4(IOUT-1) = IN4(N+1)
      OUT4(IOUT  ) = IN4(N+2)
      GO TO 260
C
  200 OUT4(IOUT-1) = CHR4(1)
      OUT4(IOUT  ) = CHR4(2)
  260 IFMT = IFMT + 1
      FMT(IFMT) = 3
C
C     IF FIRST FIELD IS SEQGP OR SEQEP, SET SEQGP FLAG TO TRUE
C
      IF (FIELD.EQ.1 .AND. (D5.EQ.SEQGP5 .OR. D5.EQ.SEQEP5))
     1    SEQGP = .TRUE.
      GO TO 50
C
C     FIRST CHARATER ON CARD IS AN ASTERISK (*)
C
  270 NWORDS = 4
      N 8 OR 16 = 16
  280 IOUT = IOUT + 2
      OUTX(IOUT-1) = 0
      OUTX(IOUT  ) = 0
      IFMT = IFMT + 1
      FMT(IFMT) = 3
      GO TO 50
C
C     FIRST CHARATER IN FIELD IS A PLUS (+)
C     IGNOR IT AND ASSUMING REMAINING FIELD IS NUMBERIC
C
  290 IF (FIELD-1) 340,280,340
C
C     FIRST CHARATER IN FIELD IS A DOT (.)
C
  300 DECIML = .TRUE.
      PLACES = 0
      GO TO 340
C
C     FIRST CHARATER IN FIELD IS A MINUS (-)
C
  310 MINUS = .TRUE.
      GO TO 340
C
C     NUMERIC -  0 TO 9
C     =================
C
  320 IF (VALUE(1) .EQ. 0) GO TO 340
      NT(1) = VALUE(1)
      IT = 1
C
C     PROCESS REMAINING DIGITS
C
  340 DO 370 N = 2,N 8 OR 16
      IF (TYPE(N) .GT. 0) GO TO 360
C
C     A NON-NUMERIC CHARACTER ENCOUNTERED
C
      IF (CHR1(N) .NE. DOT1) GO TO 430
      IF (DECIML) GO TO 950
      PLACES = 0
      DECIML = .TRUE.
      GO TO 370
C
C     A NUMERIC CHARACTER, 0 TO 9, SAVE IT IN NT
C
  360 IT = IT + 1
      NT(IT) = VALUE(N)
      IF (DECIML) PLACES = PLACES + 1
  370 CONTINUE
C
C     IF DECIML IS .FALSE. NUMERIC IS AN INTEGER
C
      IF (DECIML) GO TO 570
C
C     INTEGER FOUND.  NASTRAN INTEGER LIMIT = 10*A67777
C
  390 NUMBER = 0
      IF (IT .EQ. 0) GO TO 410
      DO 400 I = 1,IT
      IF (NUMBER .GT. A67777) GO TO 930
  400 NUMBER = NUMBER*10 + NT(I)
  410 IF (MINUS) NUMBER = - NUMBER
  420 IOUT = IOUT + 1
      OUTX(IOUT) = NUMBER
      IFMT = IFMT + 1
      FMT(IFMT) = 1
      GO TO 50
C
C     PROBABLY WE JUST ENCOUNTERED (E, D, +, -) EXPONENT, OR BLANK
C
  430 IF (TYPE(N)) 460,440,460
C
C     IT IS A BLANK
C     THUS ONLY AN EXPONENT OR BLANKS PERMITTED FOR BALANCE OF FIELD
C
  440 IF (N .EQ. N 8 OR 16) GO TO 450
      N = N + 1
      IF (TYPE(N)) 460,440,970
C
C     FALL THRU ABOVE LOOP IMPLIES BALANCE OF FIELD WAS BLANKS
C
  450 IF (DECIML) GO TO 570
      GO TO 390
C
C     A NON-BLANK CHARACTER -
C     IT HAS TO BE A (+, -, D, OR E ) OF THE EXPONENT STRING
C
  460 EXPONT = .TRUE.
      IF (CHR1(N) .NE. PLUS1) GO TO 470
      SIGN1  = PLUS1
      GO TO 500
  470 IF (CHR1(N) .NE. E1) GO TO 480
      GO TO 500
  480 IF (CHR1(N) .NE. MINUS1) GO TO 490
      SIGN1  = MINUS1
      GO TO 500
  490 IF (CHR1(N) .NE. D1) GO TO 970
      DOUBLE = .TRUE.
C
C     READ INTEGER POWER, WITH OR WITHOUT SIGN
C
  500 IF (N .EQ. N 8 OR 16) GO TO 970
      N = N + 1
C
      IF (TYPE(N)) 510,500,520
  510 IF (CHR1(N).NE.PLUS1 .AND. CHR1(N).NE.MINUS1) GO TO 520
      IF (SIGN1 .NE. BLANK1) GO TO 970
      SIGN1 = CHR1(N)
      GO TO 500
C
C     FIRST DIGIT OF INTEGER POWER AT HAND NOW
C
  520 POWER = 0
      BLKON = .FALSE.
C
  530 IF (TYPE(N)) 970,970,540
  540 POWER = POWER*10 + VALUE(N)
C
C     GET ANY MORE DIGITS IF PRESENT
C
  550 IF (N .EQ. N 8 OR 16) GO TO 570
      N = N + 1
      IF (BLKON) IF (TYPE(N)) 990,550,990
      IF (TYPE(N)) 530,560,530
C
C     IS A BLANK.  BALANCE OF FIELD MUST BE BLANKS
C
  560 BLKON = .TRUE.
      GO TO 550
C
C     SINGLE OR DOUBLE PRECISION FLOATING POINT NUMBER
C     COMPLETE AND OUTPUT IT
C
C     15 SIGNIFICANT FIGURES POSSIBLE ON INPUT
C     CONSIDERED SINGLE PRECISION UNLESS D EXPONENT IS PRESENT
C
  570 IF (SIGN1 .EQ. MINUS1) POWER = -POWER
      POWER = POWER - PLACES
C
      NUMBER = 0
      IF (IT) 580,620,580
  580 IF (IT .LT. 7) GO TO 590
      N = 7
      GO TO 600
  590 N = IT
  600 DO 610 I = 1,N
  610 NUMBER = NUMBER*10 + NT(I)
  620 DDOUBL = DBLE(FLOAT(NUMBER))
      IF (IT .LE. 7) GO TO 640
      NUMBER = 0
      DO 630 I = 8,IT
  630 NUMBER = NUMBER*10 + NT(I)
      DDOUBL = DDOUBL*10.0D0**(IT-7) + DBLE(FLOAT(NUMBER))
  640 IF (MINUS) DDOUBL = -DDOUBL
C
C     CHECK FOR POWER IN RANGE OF MACHINE
C
      CHECK = POWER + IT
      IF (DDOUBL .EQ. 0.0D0) GO TO 660
      IF (CHECK.LT.LOWPW+1 .OR. CHECK.GT.HIGHPW-1 .OR.
     1    POWER.LT.LOWPW+1 .OR. POWER.GT.HIGHPW-1) GO TO 900
C
      DDOUBL = DDOUBL*10.0D0**POWER
  660 IFMT = IFMT + 1
      IF (DOUBLE) GO TO 670
      FPT  = DDOUBL
      IOUT = IOUT + 1
      OUTX(IOUT)= INTGR
      FMT(IFMT) = 2
      GO TO 50
  670 IOUT = IOUT + 2
      OUTX(IOUT-1) = IDOUBL(1)
      OUTX(IOUT  ) = IDOUBL(2)
      FMT(IFMT) = 4
      GO TO 50
C
C     FIRST CHARATER OF FIELD 3, 5, 7,  OR 9 ON SEQGP/SEQEP CARD
C     ENCOUNTERED. IT HAS TO BE A 1 TO 9 FOR NO ERROR
C
  690 DO 700 N = 1,N 8 OR 16
      IF (TYPE(N)) 1020,700,710
  700 CONTINUE
      GO TO 140
C
C     STORE NUMBER IN NT
C
  710 NPOINT = 0
  720 IT = IT + 1
      NT(IT) = VALUE(N)
  730 IF (N .EQ. N 8 OR 16) GO TO 800
      N = N + 1
C
C     GET NEXT CHARATER
C
      IF (NPOINT.GT.0 .AND. .NOT.DECIML .AND. .NOT.BLKON) GO TO 790
      IF (DECIML)  GO TO 770
      IF (BLKON )  GO TO 750
      IF (TYPE(N)) 740,740,720
  740 IF (CHR1(N) .EQ. DOT1) GO TO 760
  750 IF (TYPE(N) .NE.    0) GO TO 1020
      BLKON = .TRUE.
      GO TO 730
C
  760 DECIML = .TRUE.
      NPOINT = NPOINT + 1
      GO TO 730
C
  770 IF (TYPE(N)) 1020,1020,780
C
  780 DECIML = .FALSE.
      GO TO 720
C
  790 IF (CHR1(N).EQ.DOT1 .AND. TYPE(N).LT.0) GO TO 760
      GO TO 750
C
C     READY TO COMPUTE INTEGER VALUE OF SPECIAL SEQGP/SEQEP INTEGER
C
  800 NPOINT = 3 - NPOINT
      IF (NPOINT) 1020,830,810
  810 DO 820 K = 1,NPOINT
      IT = IT + 1
  820 NT(IT) = 0
C
C     COMPUTE NUMBER.  NASTRAN INTEGER LIMIT = 10*A67777
C
  830 NUMBER = 0
      IF (IT) 840,420,840
  840 DO 850 K = 1,IT
      IF (NUMBER .GT. A67777) GO TO 1040
      NUMBER = NUMBER*10 + NT(K)
  850 CONTINUE
      GO TO 420
C
C     ALL FIELDS PROCESSED
C
  860 NFLAG = IOUT
      FMT(IFMT+1) = -1
C
C     CONVERT CHARACTERS TO BCD, AND INSERT NUMERIC VALUES IF
C     APPLICABLE
C
      N = 1
      DO 890 I = 1,NFLAG,25
      K = I + 24
      TMP100 = OUT100(N)
C     READ   (TMP100,870) (OUT(J),J=I,K)
C 870 FORMAT (25A4)
      CALL KHRBC1 (TMP100,OUT(I))
      DO 880 J = I,K
      IF (OUTX(J) .NE. BLANK) OUT(J)=OUTX(J)
  880 CONTINUE
  890 N = N + 1
      RETURN
C
C     ERROR
C
  900 WRITE  (NOUT,910) UFM
  910 FORMAT (A23,' 300, DATA ERROR IN FIELD UNDERLINED.')
      WRITE  (NOUT,920)
  920 FORMAT (10X,'FLOATING POINT NUMBER OUT OF MACHINE RANGE')
      WRITE  (NOUT,925) POWER,IT,CHECK,LOWPW,HIGHPW
  925 FORMAT (10X,'POWER,IT,CHECK,LOWPW,HIGHPW =',5I5)
      GO TO  1060
  930 WRITE  (NOUT,910) UFM
      WRITE  (NOUT,940)
  940 FORMAT (10X,'INTEGER MAGNITUDE OUT OF MACHINE RANGE')
      GO TO  1060
  950 IF (XSORT2 .EQ. 2) GO TO 50
      WRITE  (NOUT,910) UFM
      WRITE  (NOUT,960)
  960 FORMAT (10X,'DATA NOT RECOGNIZEABLE')
      GO TO  1060
  970 EXPONT = .FALSE.
      IF (XSORT2 .EQ. 2) GO TO 50
      WRITE  (NOUT,910) UFM
      WRITE  (NOUT,980)
  980 FORMAT (10X,'POSSIBLE ERROR IN EXPONENT')
      GO TO  1060
  990 IF (XSORT2 .EQ. 2) GO TO 50
      WRITE  (NOUT,910) UFM
      WRITE  (NOUT,1000)
 1000 FORMAT (10X,'POSSIBLE IMBEDDED BLANK')
      GO TO  1060
 1020 IF (XSORT2 .EQ. 2) GO TO 50
      WRITE  (NOUT,910) UFM
      WRITE  (NOUT,1030)
 1030 FORMAT (10X,'INCORRECT DEWEY DECIMAL NUMBER')
      GO TO  1060
 1040 IF (XSORT2 .EQ. 2) GO TO 50
      WRITE  (NOUT,910) UFM
      WRITE  (NOUT,1050)
 1050 FORMAT (10X,'INTERNAL CONVERSION OF DEWEY DECIMAL IS TOO LARGE')
 1060 DO 1070 J = 1,20
      IF (OUTX(J) .NE. STARS) OUTX(J) = BLANK
 1070 CONTINUE
      WORD = (FIELD-1)*NWORDS + 2
      K = STARS
 1080 OUTX(WORD  ) = K
      OUTX(WORD-1) = K
      IF (NWORDS.EQ.2 .OR. FIELD.EQ.1) GO TO 1090
      OUTX(WORD-2) = K
      OUTX(WORD-3) = K
 1090 IF (K .EQ. 0) GO TO 1150
      IF (NWORDS .EQ. 4) GO TO 1110
      WRITE  (NOUT,1100)
 1100 FORMAT (10X,'---1--- +++2+++ ---3--- +++4+++ ---5--- +++6+++ ',
     1            '---7--- +++8+++ ---9--- +++10+++')
      GO TO  1130
 1110 WRITE  (NOUT,1120)
 1120 FORMAT (10X,'---1--- +++++2+&+3+++++ -----4-&-5----- +++++6+&',
     1            '+7+++++ -----8-&-9----- +++10+++')
C1120 FORMAT (10X,'.   1  ..   2  AND  3  ..   4  AND  5  ..   6  A',
C    1            'ND  7  ..   8  AND  9  ..  10  .')
 1130 WRITE  (NOUT,1140) (IN4(I),I=1,20),OUTX
 1140 FORMAT (10X,20A4)
      NLINES = NLINES + 7
      K = 0
      GO TO  1080
 1150 IOUT = IOUT + 1
      OUTX(IOUT) = 0
      IFMT = IFMT + 1
      FMT(IFMT) = -1
      NOGO =.TRUE.
      GO TO 50
C
      END
