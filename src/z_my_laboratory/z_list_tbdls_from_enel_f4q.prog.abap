*&---------------------------------------------------------------------*
*& Report Z_LIST_TBDLS_FROM_ENEL_F4Q
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_LIST_TBDLS_FROM_ENEL_F4Q.

DATA:
  lt_tbdls                             TYPE TABLE OF tbdls .
FIELD-SYMBOLS:
  <tbdls>                              LIKE LINE OF lt_tbdls .


  SELECT *
    FROM tbdls   "CLIENT SPECIFIED
    INTO TABLE lt_tbdls
*   WHERE mandt = '100' .
    .

  LOOP AT lt_tbdls ASSIGNING <tbdls> .
    WRITE:/001 <tbdls>-logsys .
  ENDLOOP .
