class Z_APC_WSP_EXT_ZICF_DUNNING_APC definition
  public
  inheriting from CL_APC_WSP_EXT_STATELESS_BASE
  final
  create public .

public section.

  methods IF_APC_WSP_EXTENSION~ON_ACCEPT
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_CLOSE
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_MESSAGE
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_START
    redefinition .
  methods IF_APC_WSP_EXTENSION~ON_ERROR
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS Z_APC_WSP_EXT_ZICF_DUNNING_APC IMPLEMENTATION.


METHOD if_apc_wsp_extension~on_accept .

  CALL METHOD super->if_apc_wsp_extension~on_accept
    EXPORTING  i_context_base = i_context_base
    IMPORTING  e_connect_mode = e_connect_mode .

ENDMETHOD .


METHOD if_apc_wsp_extension~on_close .

  CALL METHOD super->if_apc_wsp_extension~on_close
    EXPORTING  i_reason       = i_reason
               i_code         = i_code
               i_context_base = i_context_base .

ENDMETHOD .


METHOD if_apc_wsp_extension~on_error .

  CALL METHOD super->if_apc_wsp_extension~on_error
    EXPORTING  i_reason       = i_reason
               i_code         = i_code
               i_context_base = i_context_base .

ENDMETHOD .


METHOD if_apc_wsp_extension~on_message .

*  CALL METHOD super->if_apc_wsp_extension~on_message
*    EXPORTING  i_message         = i_message
*               i_message_manager = i_message_manager
*               i_context         = i_context .

ENDMETHOD .


METHOD if_apc_wsp_extension~on_start .

*  CALL METHOD super->if_apc_wsp_extension~on_start
*    EXPORTING  i_context         = i_context
*               i_message_manager = i_message_manager .

*********************************************************************************
* Code which bind AMC with APC
*********************************************************************************
DATA:
  lo_binding                           TYPE REF TO if_apc_ws_binding_manager .
DATA:
  lx_error                             TYPE REF TO cx_apc_error .
DATA:
  lv_message                           TYPE string .

* bind the APC WebSocket connection to an AMC channel
  TRY .
    lo_binding = i_context->get_binding_manager( ) .
    lo_binding->bind_amc_message_consumer(
      i_application_id = 'ZICF_DUNNING_AMC'
      i_channel_id = '/dunning_level_change'
    ) .

  CATCH cx_apc_error INTO lx_error .
    lv_message = lx_error->get_text( ) .

  ENDTRY .

*********************************************************************************


ENDMETHOD .
ENDCLASS.
