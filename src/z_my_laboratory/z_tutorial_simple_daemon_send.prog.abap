*&---------------------------------------------------------------------*
*& Report z_tutorial_simple_daemon_send
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_tutorial_simple_daemon_send .

START-OF-SELECTION .
  DATA(lv_text) = `This is a simple ABAP Daemon message sent via PCP.`.
  z_tutorial_simple_daemon=>send( iv_daemon_name = 'simple_daemon'
                                  iv_text        = lv_text
                                ) .
