*&---------------------------------------------------------------------*
*& Report ZICF_DUNNING_LEVEL_CHANGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zicf_dunning_level_change .


*********************************************************************************
* Code which changes the dunning level
*********************************************************************************
DATA(mo_dunning_engine) = NEW cl_oia_dunning_engine( ) .

  mo_dunning_engine->get_dunning_list( RECEIVING rt_dunning_info = DATA(lt_dunning_info) ) .
  mo_dunning_engine->execute_dunning( it_dunning_info = lt_dunning_info ) .

*********************************************************************************
* Code to invoke the APC to notify the dunning level change
*********************************************************************************
DATA:
  lo_producer                          TYPE REF TO if_amc_message_producer_text ,
  lv_message                           TYPE string .

  lv_message = |Dunning level has been changed. Reload the page to view the updated dunning levels| .

  TRY .
    lo_producer ?= cl_amc_channel_manager=>create_message_producer(
      i_application_id = 'ZICF_DUNNING_AMC'
      i_channel_id = '/dunning_level_change'
    ) .
    lo_producer->send( i_message = lv_message ) .

  CATCH cx_amc_error INTO DATA(lx_amc_error) .
    RETURN .

  ENDTRY .

*********************************************************************************
  WRITE : / 'Dunning Level Has been updated successfully' .
