class Z_APC_MESSAGE definition
  public
  inheriting from CL_APC_WSP_EXT_STATELESS_PCP_B
  final
  create public .

public section.

  methods IF_APC_WSP_EXT_PCP~ON_START
    redefinition .
  methods IF_APC_WSP_EXT_PCP~ON_MESSAGE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS Z_APC_MESSAGE IMPLEMENTATION.


METHOD if_apc_wsp_ext_pcp~on_message .

*CALL METHOD SUPER->IF_APC_WSP_EXT_PCP~ON_MESSAGE
*  EXPORTING
*    I_MESSAGE         =
*    I_MESSAGE_MANAGER =
*    I_CONTEXT         =
*    .

*Data received from UI (feed input)
DATA(lv_text_str) = i_message->get_text( ) .

*Set text and send message back
  i_message->set_text( lv_text_str ) .

*  ATTENTION: for collaboration scenario comment out the following
  i_message_manager->send( i_message ) .

ENDMETHOD .


METHOD if_apc_wsp_ext_pcp~on_start .

*CALL METHOD SUPER->IF_APC_WSP_EXT_PCP~ON_START
*  EXPORTING
*    I_CONTEXT         =
*    I_MESSAGE_MANAGER =
*    .

*********************************************************************************
* Code which bind AMC with APC
*********************************************************************************
DATA:
  lo_binding                           TYPE REF TO if_apc_ws_binding_manager ,
  lx_error                             TYPE REF TO cx_apc_error ,
  lv_message                           TYPE string .

* bind the APC WebSocket connection to an AMC channel
 TRY .
   lo_binding = i_context->get_binding_manager( ) .

   lo_binding->bind_amc_message_consumer(
     i_application_id = 'Z_AMC_MESSAGE'
     i_channel_id     = '/message_from_backend'
   ) .

 CATCH cx_apc_error INTO lx_error .
   lv_message = lx_error->get_text( ) .

 ENDTRY .
*********************************************************************************

ENDMETHOD .
ENDCLASS.
