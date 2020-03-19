class Z_ICF_DUNNING_MODEL_RESOURCE definition
  public
  inheriting from CL_REST_RESOURCE
  create public .

public section.

  methods IF_REST_RESOURCE~GET
    redefinition .
protected section.
private section.

  data MO_DUNNING type ref to Z_ICF_DUNNING_DATA_MODEL .
  data MR_DUNNING type ref to SEPMAPPS_OPENINV .
ENDCLASS.



CLASS Z_ICF_DUNNING_MODEL_RESOURCE IMPLEMENTATION.


METHOD if_rest_resource~get .
*  CALL METHOD SUPER->IF_REST_RESOURCE~GET
*      .

TYPES:
  BEGIN OF ty_dunning_levels ,
    current_dunning_level              TYPE c LENGTH 1 ,  "DunningLevel
    sales_orders_counter               TYPE i ,           "NoSalesOrders
  END OF ty_dunning_levels .
DATA:
  lv_path                              TYPE string ,
  lt_dunnings                          TYPE z_sepmapps_openinv_tt ,
  lt_dunnings_level                    TYPE TABLE OF ty_dunning_levels ,
  ls_dunning_level                     TYPE ty_dunning_levels .
FIELD-SYMBOLS:
  <dunning>                            LIKE LINE OF lt_dunnings .


  IF mr_dunning IS NOT BOUND .
    CREATE DATA mr_dunning .
    CREATE OBJECT mo_dunning .
  ENDIF .


  DATA(lo_entity)       = mo_response->create_entity( ) .
*  mr_dunning->email     = mo_request->get_uri_attribute( iv_name = 'email' ) .
*  mr_dunning->lastname  = mo_request->get_uri_attribute( iv_name = 'lastname' ) .
*  mr_dunning->firstname = mo_request->get_uri_attribute( iv_name = 'firstname' ) .
  DATA(lv_format)       = mo_request->get_uri_attribute( iv_name = 'format' ) .

*mo_request->MT_QUERY_PARAMETER_ENCODED[]

*get path requested
  lv_path = mo_request->get_uri_path( ) .


* Read dunning's data
  CALL METHOD mo_dunning->read
    EXPORTING  i_s_dunning  = mr_dunning->*
    IMPORTING  e_t_dunnings = lt_dunnings .

  CASE lv_path .
    WHEN '/DunningLevelDetails'.
      LOOP AT lt_dunnings ASSIGNING <dunning> .
        CLEAR ls_dunning_level .
        ls_dunning_level-current_dunning_level = <dunning>-current_dunning_level .
        ls_dunning_level-sales_orders_counter  = 1 .
        COLLECT ls_dunning_level INTO lt_dunnings_level .
      ENDLOOP .

* Transform data to JSON
      DATA(lo_json_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ) .
*"dunnings" name specified in "SOURCE" clause of CALL TRANSFORMATION has to be used in SAPUI5 data binding as follow:
*oModel.setData({modelData : data.DunningLevelDetails});
      CALL TRANSFORMATION ID
        SOURCE local_table = lt_dunnings_level
        RESULT xml lo_json_writer .

      lo_entity->set_content_type( if_rest_media_type=>gc_appl_json ) .
      lo_entity->set_binary_data( lo_json_writer->get_output( ) ) .
DATA:
*  lv_entity_xstring type xstring ,
  lv_entity_string  type string .
*      lv_entity_xstring = lo_json_writer->get_output( ) .
*
*      lo_entity->set_binary_data( lv_entity_xstring ) .
      lv_entity_string = lo_entity->get_string_data( ) .
      REPLACE '/' WITH '' INTO lv_path . CONDENSE lv_path .
      REPLACE ALL OCCURRENCES OF 'LOCAL_TABLE'            IN lv_entity_string  WITH lv_path         .
      REPLACE ALL OCCURRENCES OF 'CURRENT_DUNNING_LEVEL'  IN lv_entity_string  WITH 'DunningLevel'  .
      REPLACE ALL OCCURRENCES OF 'SALES_ORDERS_COUNTER'   IN lv_entity_string  WITH 'NoSalesOrders' .
      lo_entity->set_string_data( lv_entity_string ) .

      mo_response->set_status( cl_rest_status_code=>gc_success_ok ) .
      RETURN .
    WHEN Others .
  ENDCASE .

*  CASE lv_format .
*    WHEN 'json'  OR '' .
** Transform data to JSON
*      DATA(lo_json_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ) .
**"dunnings" name specified in "SOURCE" clause of CALL TRANSFORMATION has to be used in SAPUI5 data binding as follow:
**oModel.setData({modelData : data.dunningS});
*      CALL TRANSFORMATION ID
*        SOURCE local_table = lt_dunnings
*        RESULT xml lo_json_writer .
*
*      lo_entity->set_content_type( if_rest_media_type=>gc_appl_json ) .
*      lo_entity->set_binary_data( lo_json_writer->get_output( ) ) .
*DATA:
**  lv_entity_xstring type xstring ,
*  lv_entity_string  type string .
**      lv_entity_xstring = lo_json_writer->get_output( ) .
**
**      lo_entity->set_binary_data( lv_entity_xstring ) .
*      lv_entity_string = lo_entity->get_string_data( ) .
*      REPLACE '/' WITH '' INTO lv_path . CONDENSE lv_path .
*      REPLACE 'LOCAL_TABLE' WITH lv_path INTO lv_entity_string .
*
*      lo_entity->set_string_data( lv_entity_string ) .
*
*
*    WHEN 'xml' .
** Transform data to XML
*      CALL TRANSFORMATION ID
*        SOURCE itab = lt_dunnings
*        RESULT xml data(lv_xml) .
*      lo_entity->set_content_type( if_rest_media_type=>gc_appl_xml ) .
*      lo_entity->set_binary_data( lv_xml ) .
*
*    WHEN 'atom' .
** Transform data to Atom
*      DATA: ls_feed   TYPE if_atom_types=>feed_s ,
*            ls_entry  TYPE if_atom_types=>entry_s .
*      FIELD-SYMBOLS <f> LIKE LINE OF lt_dunnings .
*      ls_feed-id-uri = 'http://www.sap.com' .
*      GET TIME STAMP FIELD ls_feed-updated-datetime .
*      LOOP AT lt_dunnings ASSIGNING <f> .
**        ls_entry-title-text = | { <f>-lastname }-{ <f>-firstname }| .
**        CONVERT DATE <f>-fldate
**          INTO TIME STAMP ls_entry-updated-datetime
**          TIME ZONE 'UTC' .
*        ls_entry-title-type = if_atom_types=>gc_content_text .
*        APPEND ls_entry TO ls_feed-entries .
*      ENDLOOP .
*      DATA(lo_provider) = NEW cl_atom_feed_prov( ) .
*      lo_provider->set_feed( ls_feed ) .
*      lo_provider->write_to( lo_entity ).
*
*  ENDCASE .
  mo_response->set_status( cl_rest_status_code=>gc_success_ok ) .

ENDMETHOD .
ENDCLASS.
