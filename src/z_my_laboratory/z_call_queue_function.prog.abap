*&---------------------------------------------------------------------*
*& Report Z_CALL_QUEUE_FUNCTION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CALL_QUEUE_FUNCTION.

data gv_result type sysubrc.
data gt_messages type bapiret2_t.


call function 'TRFC_SET_QIN_PROPERTIES'
     exporting
          qin_name   = 'FUNCTION_QUEUE'
          no_execute = abap_false.
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'Z_REMOTE_FUNCTION'
  IN BACKGROUND TASK
  EXPORTING
    IV_CODE           = '1'
  IMPORTING
    EV_RESULT         = gv_result
    ET_MESSAGES       = gt_messages
          .

COMMIT WORK.
WRITE 'OK'.
