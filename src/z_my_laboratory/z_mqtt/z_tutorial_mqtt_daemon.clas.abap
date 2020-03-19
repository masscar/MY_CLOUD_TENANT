CLASS z_tutorial_mqtt_daemon DEFINITION
  public
  inheriting from CL_ABAP_DAEMON_EXT_BASE
  final
  create public .

public section.

  INTERFACES if_mqtt_event_handler .
  INTERFACES if_amc_message_receiver_pcp .

  METHODS if_abap_daemon_extension~on_accept
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_before_restart_by_system
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_error
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_message
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_restart
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_server_shutdown
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_start
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_stop
    REDEFINITION .
  METHODS if_abap_daemon_extension~on_system_shutdown
    REDEFINITION .

  CLASS-METHODS start
    IMPORTING  iv_daemon_name          TYPE string
               iv_subscription_topic   TYPE string
               iv_publish_topic        TYPE string
    RAISING    cx_abap_daemon_error
               cx_ac_message_type_pcp_error .

  CLASS-METHODS stop
    IMPORTING  iv_daemon_name          TYPE string
    RAISING    cx_abap_daemon_error .

PROTECTED SECTION .

PRIVATE SECTION .
DATA:
  mv_subscription_topic                TYPE string,
  mv_publish_topic                     TYPE string,
  mo_client                            TYPE REF TO if_mqtt_client .

ENDCLASS.



CLASS z_tutorial_mqtt_daemon IMPLEMENTATION.


  METHOD if_abap_daemon_extension~on_accept .

    TRY .
      DATA lv_program_name TYPE program .
      lv_program_name = cl_oo_classname_service=>get_classpool_name( 'Z_TUTORIAL_MQTT_DAEMON' ) .

      IF i_context_base->get_start_caller_info( )-program = lv_program_name .
        e_setup_mode = co_setup_mode-accept .
      ELSE .
        e_setup_mode = co_setup_mode-reject .
      ENDIF .
    CATCH cx_abap_daemon_error .
      " to do: error handling, e.g. write error log!
      e_setup_mode = co_setup_mode-reject .
    ENDTRY .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_BEFORE_RESTART_BY_SYSTEM .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_ERROR .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_MESSAGE .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_RESTART .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_SERVER_SHUTDOWN .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~on_start .

    TRY .
      " retrieve PCP parameters from start parameters
      DATA(i_message)       = i_context->get_start_parameter( ) .
      mv_subscription_topic = i_message->get_field( 'sub_topic' ) .
      mv_publish_topic      = i_message->get_field( 'pub_topic' ) .

      " specify which MQTT broker to connect to
      cl_mqtt_client_manager=>create_by_url(
        EXPORTING  i_url            = 'ws://broker.hivemq.com:8000/mqtt'
                   i_event_handler  = me
        RECEIVING  r_client        =  mo_client
      ) .

      " establish the connection
      mo_client->connect( ) .

      " subscribe to MQTT topic with a certain quality of service
      DATA(lt_mqtt_topic_filter_qos) =
            VALUE if_mqtt_types=>tt_mqtt_topic_filter_qos(
                         ( topic_filter = mv_subscription_topic
                           qos          = if_mqtt_types=>qos-at_least_once ) ) .

      mo_client->subscribe( i_topic_filter_qos = lt_mqtt_topic_filter_qos ) .

      " subscribe to the AMC channel for receiving messages
      cl_amc_channel_manager=>create_message_consumer(
            i_application_id = 'Z_AMC_TUTORIAL_CHANNEL'
            i_channel_id     = '/mqtt_forward'
            )->start_message_delivery( i_receiver = me ) .

    CATCH  cx_abap_daemon_error cx_ac_message_type_pcp_error cx_mqtt_error cx_amc_error .
      " to do: error handling, e.g. write error log!
    ENDTRY .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~on_stop .

    TRY .
      " unsubscribe from the MQTT topic
      DATA(lt_mqtt_topic_filter) = VALUE if_mqtt_types=>tt_mqtt_topic_filter( ( topic_filter =  mv_subscription_topic ) ) .
      mo_client->unsubscribe( i_topic_filter = lt_mqtt_topic_filter ) .

    CATCH cx_mqtt_error cx_ac_message_type_pcp_error cx_abap_daemon_error .
      " to do: error handling, e.g. write error log!
    ENDTRY .

  ENDMETHOD .

****
  METHOD if_abap_daemon_extension~ON_SYSTEM_SHUTDOWN.

  ENDMETHOD.

****
  METHOD start .
    " set ABAP Daemon start parameters
    DATA(lo_pcp) = cl_ac_message_type_pcp=>create( ) .
    lo_pcp->set_field( i_name = 'name' i_value = iv_daemon_name ) .
    lo_pcp->set_field( i_name = 'sub_topic' i_value = iv_subscription_topic ) .
    lo_pcp->set_field( i_name = 'pub_topic' i_value = iv_publish_topic ) .

    " start the daemon application using the ABAP Daemon Manager
    cl_abap_daemon_client_manager=>start(
        i_class_name = 'Z_TUTORIAL_MQTT_DAEMON'
        i_name       = CONV #( iv_daemon_name )
        i_priority   = cl_abap_daemon_client_manager=>co_session_priority_low
        i_parameter  = lo_pcp
    ) .

  ENDMETHOD .

****
  METHOD stop .
    " retrieve the list of ABAP Daemon instances
    DATA(lt_ad_info) = cl_abap_daemon_client_manager=>get_daemon_info( i_class_name = 'Z_TUTORIAL_MQTT_DAEMON') .

    " for each running daemon instance of this class
    LOOP AT lt_ad_info ASSIGNING FIELD-SYMBOL(<ls_info>) .

      " stop the daemon if the names match
      IF iv_daemon_name = <ls_info>-name .
        cl_abap_daemon_client_manager=>stop( i_instance_id = <ls_info>-instance_id ) .
     ENDIF .

    ENDLOOP .
  ENDMETHOD .

****
  METHOD if_mqtt_event_handler~ON_CONNECT.

  ENDMETHOD.

****
  METHOD if_mqtt_event_handler~ON_DISCONNECT.

  ENDMETHOD.

****
  METHOD if_mqtt_event_handler~on_message .
    TRY .
      " retrieve message text and put received message into PCP format
      DATA(lv_message) = i_message->get_text( ) .
      DATA(lo_pcp)     = cl_ac_message_type_pcp=>create( ) .
      lo_pcp->set_text( lv_message ) .

      " forward message via AMC
      CAST if_amc_message_producer_pcp(
             cl_amc_channel_manager=>create_message_producer(
               i_application_id = 'Z_AMC_TUTORIAL_CHANNEL'
               i_channel_id     =  '/mqtt_forward'
               i_suppress_echo  = abap_true )
        )->send( i_message = lo_pcp ) .
      CATCH cx_mqtt_error cx_ac_message_type_pcp_error cx_amc_error .
        " to do: error handling, e.g. write error log!
    ENDTRY .
  ENDMETHOD .

****
  METHOD if_mqtt_event_handler~ON_PUBLISH .

  ENDMETHOD .

****
  METHOD if_mqtt_event_handler~ON_SUBSCRIBE .

  ENDMETHOD .

****
  METHOD if_mqtt_event_handler~ON_UNSUBSCRIBE .

  ENDMETHOD .

****
  METHOD if_amc_message_receiver_pcp~receive .
    TRY .
      " get message sent to the daemon via AMC
      DATA(lv_message) = i_message->get_text( ) .

      " forward the message on the specified MQTT channel
      DATA(lo_mqtt_message) = cl_mqtt_message=>create( ) .
      lo_mqtt_message->set_qos( if_mqtt_types=>qos-at_least_once ) .
      lo_mqtt_message->set_text( lv_message ) .

      mo_client->publish( i_topic_name = mv_publish_topic
                          i_message    = lo_mqtt_message
      ) .

    CATCH cx_ac_message_type_pcp_error cx_mqtt_error .
      " to do: error handling, e.g. write error log!
  ENDTRY .

ENDMETHOD .

ENDCLASS.
