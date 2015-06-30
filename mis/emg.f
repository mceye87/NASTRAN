      SUBROUTINE EMG
C
C     ELEMENT-MATRIX-GENERATOR MAIN DRIVING ROUTINE.
C
C     DMAP SEQUENCE
C
C     EMG, EST,CSTM,MPT,DIT,GEOM2, /KMAT,KDICT, MMAT,MDICT, BMAT,BDICT/
C          V,N,NOKGG/V,N,NOMGG/V,N,NOBGG/V,N,NOK4GG/V,N,NOKDGG/
C          C,Y,COUPMASS/C,Y,CPBAR/C,Y,CPROD/C,Y,CPQUAD1/C,Y,CPQUAD2/
C          C,Y,CPTRIA1/C,Y,CPTRIA2/C,Y,CPTUBE/C,Y,CQDPLT/C,Y,CPTRPLT/
C          C,Y,CPTRBSC/V,Y,VOLUME/V,Y,SURFACE $
C
      LOGICAL         ERROR, ANYCON, NOGO, HEAT, LINEAR
      INTEGER         Z, EST, CSTM, DIT, GEOM2, DICTN
      INTEGER         PRECIS, CMASS, FLAGS, NAME(2)
      DIMENSION       IBUF(7),MCB(7)
      COMMON /BLANK / NOK, NOM, NOB, NOK4GG, NOKDGG, CMASS
      COMMON /EMGPRM/ ICORE, JCORE, NCORE, ICSTM, NCSTM, IMAT, NMAT,
     1                IHMAT, NHMAT, IDIT, NDIT, ICONG, NCONG, LCONG,
     2                ANYCON, FLAGS(3), PRECIS, ERROR, HEAT, ICMBAR,
     3                LCSTM, LMAT, LHMAT, KFLAGS(3), L38
CZZ   COMMON /ZZEMGX/ Z(1)
      COMMON /ZZZZZZ/ Z(1)
      COMMON /EMGFIL/ EST, CSTM, MPT, DIT, GEOM2, MATS(3), DICTN(3)
      COMMON /HMATDD/ SKP(4), LINEAR
      COMMON /SYSTEM/ KSYSTM(65)
      COMMON /MACHIN/ MACH
      EQUIVALENCE     (KSYSTM(3),NOGO), (KSYSTM(55),IPRECI),
     1                (KSYSTM(2),NOUT), (KSYSTM(56),NOHEAT)
      DATA    NAME  / 4HEMG ,4H     /
C
C     SET EMG PRECISION FLAG TO SYSTEM PRECISION FLAG
C
      PRECIS = IPRECI
C
C     IF .NOT.1 .AND. .NOT.2 DEFAULT EMG PRECISION TO SINGLE
C
      IF (PRECIS.LT.1 .OR. PRECIS.GT.2) PRECIS = 1
C
C     HEAT  FORMULATION
C
      HEAT   = .FALSE.
      IF (NOHEAT .LE. 0) GO TO 2
      HEAT   = .TRUE.
      LINEAR = .TRUE.
      NOKDGG = -1
C
C     TEST FOR NO SIMPLE ELEMENTS
C
    2 NOGO   = .FALSE.
      MCB(1) = 101
      CALL RDTRL (MCB)
      IF (MCB(1) .LT. 0) GO TO 3
      IF (MCB(2).NE.0 .OR. MCB(5).NE.0 .OR. MCB(6).NE.0 .OR.
     1    MCB(7).NE.0) GO TO 5
    3 NOK = -1
      NOM = -1
      NOB = -1
      NOK4GG = -1
      RETURN
C
C     SET OPEN CORE
C
    5 NCORE = KORSZ(Z(1))
      ICORE = 3
      IF (MACH.EQ.3 .OR. MACH.EQ.4) CALL EMGSOC (ICORE,NCORE,HEAT)
      NCORE = NCORE - 1
      JCORE = ICORE
C
C     SET WORKING CORE TO ALL ZEROS
C
      DO 10 I = ICORE,NCORE
      Z(I) = 0
   10 CONTINUE
C
C     THIS MODULE WILL SET NOK4GG = -1 . IF DURING EXECUTION A NON-ZERO
C     DAMPING CONSTANT IS DETECTED IN A DICTIONARY BY EMGOUT, NOK4GG
C     WILL BE SET TO 1
C
C     A DMAP DETERMINATION CAN THEN BE MADE WHETHER OR NOT TO HAVE EMA
C     FORM THE K4GG MATRIX
C
      NOK4GG = -1
C
C     SET GINO FILE NUMBERS
C
      EST    = 101
      CSTM   = 102
      MPT    = 103
      DIT    = 104
      GEOM2  = 105
      DO 20 I = 1,3
      MATS(I) = 199 + 2*I
      DICTN(I) = MATS(I) + 1
   20 CONTINUE
      ERROR = .FALSE.
C
C     IF DIAG 38 IS ON, PRINT TOTAL TIME (IN SECONDS) USED BY EMGPRO
C     AND MESSAGES 3113 AND 3107  WHILE PRPCESSING ELEMENTS
C
      CALL SSWTCH (38,L38)
C
C     READ AND SETUP INTO CORE MISC. TABLES.
C     E.G. MPT, CSTM, DIT, ETC.
C
      CALL EMGTAB
C
C     PROCESS ANY CONGRUENT DATA CARDS AND BUILD TABLE IN OPEN CORE.
C
      CALL EMGCNG
C
C     SETUP BALANCE OF CORE WITH REQUIRED BUFFERS AND OPEN
C     REQUIRED DATA BLOCKS.
C
      CALL EMGCOR (IBUF)
C
C     PASS THE EST AND WRITE THE OUTPUT DATA BLOCKS.
C
      IF (L38 .EQ. 1) CALL KLOCK (I)
      CALL EMGPRO (IBUF)
      IF (L38 .EQ. 0) GO TO 40
      CALL KLOCK (J)
      J = J - I
      WRITE  (NOUT,30) J
   30 FORMAT (///,34H *** EMG ELEMENT PROCESSING TIME =,I10,8H SECONDS)
C
C     WRAP-UP OPERATIONS.
C
   40 CALL EMGFIN
      IF (NOGO .OR. ERROR) CALL MESAGE (-37,0,NAME)
      RETURN
      END
