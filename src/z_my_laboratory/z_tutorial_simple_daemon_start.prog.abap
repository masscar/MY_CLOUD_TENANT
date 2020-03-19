*&---------------------------------------------------------------------*
*& Report z_tutorial_simple_daemon_start
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_tutorial_simple_daemon_start .

START-OF-SELECTION .
  z_tutorial_simple_daemon=>start( iv_daemon_name = 'simple_daemon' iv_timeout = 10000 ) .
