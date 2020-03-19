*&---------------------------------------------------------------------*
*& Report z_tutorial_simple_daemon_stop
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_tutorial_simple_daemon_stop .

START-OF-SELECTION .
  z_tutorial_simple_daemon=>stop( iv_daemon_name = 'simple_daemon' ) .
