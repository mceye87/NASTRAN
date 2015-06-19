      SUBROUTINE XYLOG( V1, V2, CYCLES )
      INTEGER CYCLES, POWER1, POWER2
C*****
C  THIS SUBROUTINE TAKES V1 AND V2 REGARDLESS OF THEIR VALUES
C  AND COMPUTES A LOG SCALE OF AT LEAST 1 CYCLE...
C*****
      IF( V1 .GT. 0.0E0 ) GO TO 20
      IF( V2 .GT. 0.0E0 ) GO TO 10
C
C     V1 AND V2 ARE BOTH NEGATIVE OR ZERO.  SET ARBITRARY LIMITS
C
    5 V1 = 1.0E-5
      V2 = 1.0E+5
      CYCLES = 10
      RETURN
C
C     V2 IS POSITIVE BUT V1 IS NEGATIVE OR 0
C
   10 V1 = V2 * 1.0E-5
      GO TO 40
C
   20 IF( V2 .GT. 0.0E0 ) GO TO 30
C
C     V1 IS POSITIVE BUT V2 IS NEGATIVE OR 0
C
      V2 = V1 * 1.0E+5
      GO TO 40
C
   30 IF( V2 .GT. V1 ) GO TO 40
      TEMP = V1
      V1 = V2
      V2 = TEMP
C
C     RAISE V2 TO POWER OF 10,  LOWER V1 TO POWER OF 10
C
   40 POWER1 = 0
   50 IF( V1 .LT. 0.9999998E0) GO TO 70
   60 IF( V1 .LT. 10.0E0) GO TO 80
      V1 = V1 / 10.0E0
      POWER1 = POWER1 + 1
      GO TO 60
   70 V1 = V1 * 10.0E0
      IF( V1 .LE. 0.0E0 ) GO TO 5
      POWER1 = POWER1 - 1
      GO TO 50
C
   80 V1 = 10.0E0 ** POWER1
C
      POWER2 = 1
   90 IF(V2.LE. 1.0E0) GO TO 110
  100 IF( V2 .LT. 10.00001E0) GO TO 120
      V2 = V2 / 10.0E0
      POWER2 = POWER2 + 1
      GO TO 100
  110 V2 = V2 * 10.0E0
      IF( V2 .LE. 0.0E0 ) GO TO 5
      POWER2 = POWER2 - 1
      GO TO 90
C
  120 V2 = 10.0E0 ** POWER2
C
      CYCLES = POWER2 - POWER1
      RETURN
      END