*&---------------------------------------------------------------------*
*& Report z_tutorial_mqtt_daemon_send
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_tutorial_mqtt_daemon_send .

START-OF-SELECTION .
" create a PCP message
  DATA(lo_pcp)     = cl_ac_message_type_pcp=>create( ) .
  lo_pcp->set_text( 'This is a test message.' ) .

  " send message via AMC
  CAST if_amc_message_producer_pcp(
       cl_amc_channel_manager=>create_message_producer(
         i_application_id = 'Z_AMC_TUTORIAL_CHANNEL'
         i_channel_id     =  '/mqtt_forward'
         i_suppress_echo  = abap_true )
    )->send( i_message = lo_pcp ) .
