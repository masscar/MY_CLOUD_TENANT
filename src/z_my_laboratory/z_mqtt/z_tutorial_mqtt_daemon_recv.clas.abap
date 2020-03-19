CLASS z_tutorial_mqtt_daemon_recv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

  INTERFACES if_oo_adt_classrun .
  INTERFACES if_amc_message_receiver .
  INTERFACES if_amc_message_receiver_pcp .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: "mo_out     TYPE REF TO if_oo_adt_classrun_out,
          mo_out     TYPE REF TO if_oo_adt_intrnl_classrun ,
          mv_message TYPE string.
ENDCLASS.



CLASS Z_TUTORIAL_MQTT_DAEMON_RECV IMPLEMENTATION.


  METHOD if_amc_message_receiver_pcp~receive .
    TRY.
        " retrieve the received AMC message text
        mv_message = i_message->get_text( ).
      CATCH cx_ac_message_type_pcp_error.
        " to do: error handling, e.g. write error log!
    ENDTRY.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main .

    " create new instance of this class for receiving AMC messages
    DATA(lo_receiver) = NEW z_tutorial_mqtt_daemon_recv( ).
    lo_receiver->mo_out = out.
    lo_receiver->mv_message = ''.

    " subscribe to the channel
    TRY.
        cl_amc_channel_manager=>create_message_consumer(
              i_application_id = 'Z_AMC_TUTORIAL_CHANNEL'
              i_channel_id     = '/mqtt_forward'
          )->start_message_delivery( i_receiver = lo_receiver ).
      CATCH cx_amc_error.
        " to do: error handling, e.g. write error log!
    ENDTRY.

    " wait until an AMC message has been received
    WAIT FOR MESSAGING CHANNELS UNTIL lo_receiver->mv_message IS NOT INITIAL UP TO 60 SECONDS.

      " log any received message to the console
    IF lo_receiver->mv_message IS NOT INITIAL.
      out->write( |AMC message received: { lo_receiver->mv_message }| ).
    ELSE.
      out->write( 'No message received.' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
