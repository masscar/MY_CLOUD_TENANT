class Z_SAPUI5_DATA_MODEL_RESOURCE definition
  public
  inheriting from CL_REST_RESOURCE
  create public .

public section.

  methods IF_REST_RESOURCE~GET
    redefinition .
protected section.
private section.

  data MO_CONTACT type ref to Z_SAPUI5_DATA_MODEL .
  data MR_CONTACT type ref to ZTB_SCNBLOG2 .
ENDCLASS.



CLASS Z_SAPUI5_DATA_MODEL_RESOURCE IMPLEMENTATION.


METHOD if_rest_resource~get .
*  CALL METHOD SUPER->IF_REST_RESOURCE~GET
*      .

DATA:
  lt_contacts                          TYPE ztt_scnblog2 .

  IF mr_contact IS NOT BOUND .
    CREATE DATA mr_contact .
    CREATE OBJECT mo_contact .
  ENDIF .


  DATA(lo_entity)       = mo_response->create_entity( ) .
  mr_contact->email     = mo_request->get_uri_attribute( iv_name = 'email' ) .
  mr_contact->lastname  = mo_request->get_uri_attribute( iv_name = 'lastname' ) .
  mr_contact->firstname = mo_request->get_uri_attribute( iv_name = 'firstname' ) .
  DATA(lv_format)       = mo_request->get_uri_attribute( iv_name = 'format' ) .

* Read Contact's data
  CALL METHOD mo_contact->read
    EXPORTING  i_s_contact  = mr_contact->*
    IMPORTING  e_t_contacts = lt_contacts .


  CASE lv_format .
    WHEN 'json'  OR '' .
* Transform data to JSON
      DATA(lo_json_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ) .
*"contacts" name specified in "SOURCE" clause of CALL TRANSFORMATION has to be used in SAPUI5 data binding as follow:
*oModel.setData({modelData : data.CONTACTS});
      CALL TRANSFORMATION ID
        SOURCE contacts = lt_contacts
        RESULT xml lo_json_writer .
      lo_entity->set_content_type( if_rest_media_type=>gc_appl_json ) .
      lo_entity->set_binary_data( lo_json_writer->get_output( ) ) .
*DATA:
*  lv_entity_xstring type xstring ,
*  lv_entity_string  type string .
*      lv_entity_xstring = lo_json_writer->get_output( ) .
*
*      lo_entity->set_binary_data( lv_entity_xstring ) .
*      lv_entity_string = lo_entity->get_string_data( ) .
*      lo_entity->set_string_data( lv_entity_string ) .


    WHEN 'xml' .
* Transform data to XML
      CALL TRANSFORMATION ID
        SOURCE itab = lt_contacts
        RESULT xml data(lv_xml) .
      lo_entity->set_content_type( if_rest_media_type=>gc_appl_xml ) .
      lo_entity->set_binary_data( lv_xml ) .

    WHEN 'atom' .
* Transform data to Atom
      DATA: ls_feed   TYPE if_atom_types=>feed_s ,
            ls_entry  TYPE if_atom_types=>entry_s .
      FIELD-SYMBOLS <f> LIKE LINE OF lt_contacts .
      ls_feed-id-uri = 'http://www.sap.com' .
      GET TIME STAMP FIELD ls_feed-updated-datetime .
      LOOP AT lt_contacts ASSIGNING <f> .
        ls_entry-title-text = | { <f>-lastname }-{ <f>-firstname }| .
*        CONVERT DATE <f>-fldate
*          INTO TIME STAMP ls_entry-updated-datetime
*          TIME ZONE 'UTC' .
        ls_entry-title-type = if_atom_types=>gc_content_text .
        APPEND ls_entry TO ls_feed-entries .
      ENDLOOP .
      DATA(lo_provider) = NEW cl_atom_feed_prov( ) .
      lo_provider->set_feed( ls_feed ) .
      lo_provider->write_to( lo_entity ).

  ENDCASE .
  mo_response->set_status( cl_rest_status_code=>gc_success_ok ) .

ENDMETHOD .
ENDCLASS.
