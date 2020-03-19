*&---------------------------------------------------------------------*
*& Report Z_APC_MESSAGE_PUSH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_APC_MESSAGE_PUSH_TEXT.

*********************************************************************************
* Code which changes the dunning level
*********************************************************************************
DATA(mo_dunning_engine) = NEW cl_oia_dunning_engine( ) .

*  mo_dunning_engine->get_dunning_list(
*    RECEIVING rt_dunning_info = DATA(lt_dunning_info)
*  ) .
*
* mo_dunning_engine->execute_dunning(
*   it_dunning_info = lt_dunning_info
* ) .

*********************************************************************************
* Code to invoke the APC to notify the dunning level change
*********************************************************************************
*  BREAK i025305 .

DATA:
*  lo_producer_pcp                      TYPE REF TO cl_amc_message_type_pcp , "if_amc_message_producer_pcp , "if_amc_message_producer ,if_amc_message_producer_text ,
  lo_producer_text                     TYPE REF TO if_amc_message_producer_text ,
  lx_amc_error                         TYPE REF TO cx_amc_error ,
  lo_pcp_message                       TYPE REF TO cl_ac_message_type_pcp , "if_ac_message_type_pcp ,
  lv_message                           TYPE string .

  lv_message = |Dunning level has been changed. Reload the page to view the updated dunning levels|.

  TRY .
    lo_producer_text ?= cl_amc_channel_manager=>create_message_producer(
      i_application_id = 'Z_AMC_MESSAGE'
      i_channel_id     = '/message_from_backend_text'
    ) .

    lo_producer_text->send( i_message = lv_message ) .


  CATCH cx_amc_error INTO lx_amc_error .
    lv_message = lx_amc_error->get_text( ) .
    RETURN .

  ENDTRY .

*********************************************************************************
WRITE : / 'Dunning Level Has been updated successfully' .
