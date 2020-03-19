class Z_ICF_DUNNING definition
  public
  inheriting from CL_REST_HTTP_HANDLER
  create public .

public section.

  methods IF_REST_APPLICATION~GET_ROOT_HANDLER
    redefinition .
protected section.
private section.

  methods _HANDLE_REQUEST
    importing
      !SERVER type ref to IF_HTTP_SERVER .
ENDCLASS.



CLASS Z_ICF_DUNNING IMPLEMENTATION.


METHOD if_rest_application~get_root_handler .

*  CALL METHOD SUPER->IF_REST_APPLICATION~GET_ROOT_HANDLER
*    RECEIVING
*      RO_ROOT_HANDLER =
*      .

DATA:
  lo_router                            TYPE REF TO cl_rest_router .

  lo_router = NEW cl_rest_router( ) .

*  lo_router->attach( iv_template = '/flights'                                     iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights.{format}'                            iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}'                            iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}.{format}'                   iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}/{connid}'                   iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}/{connid}.{format}'          iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}/{connid}/{fldate}'          iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .
*  lo_router->attach( iv_template = '/flights/{carrid}/{connid}/{fldate}.{format}' iv_handler_class = 'ZCL_SCN_BLOG_FLIGHT_RESOURCE' ) .

  lo_router->attach( iv_template = '/dunnings'                                     iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings.{format}'                            iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .

  lo_router->attach( iv_template = '/dunnings/{invoice_guid}'                      iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{invoice_guid}.{format}'             iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{so_id}'                             iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{so_id}.{format}'                    iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{bupa_id}'                           iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{bupa_id}.{format}'                  iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{company_name}'                      iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{company_name}.{format}'             iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{days_open}'                         iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{days_open}.{format}'                iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{gross_amount}'                      iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{gross_amount}.{format}'             iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{currency_code}'                     iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{currency_code}.{format}'            iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{bupa_rank}'                         iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{bupa_rank}.{format}'                iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{current_dunning_level}'             iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{current_dunning_level}.{format}'    iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{invoice_created_at}'                iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{invoice_created_at}.{format}'       iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{invoice_created_at_date}'           iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/dunnings/{invoice_created_at_date}.{format}'  iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .

  lo_router->attach( iv_template = '/DunningLevelDetails'                          iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/DunningLevelDetails.{format}'                 iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/DunningLevelDetails/{DunningLevel}'           iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/DunningLevelDetails/{DunningLevel}.{format}'  iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/DunningLevelDetails/{NoSalesOrders}'          iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/DunningLevelDetails/{NoSalesOrders}.{format}' iv_handler_class = 'Z_ICF_DUNNING_MODEL_RESOURCE' ) .

  ro_root_handler = lo_router .

ENDMETHOD .


METHOD _handle_request .


TYPES:
  BEGIN OF local_type_response ,
    success                            TYPE string ,
    msg                                TYPE string ,
    data                               TYPE z_sepmapps_openinv_tt ,
  END OF local_type_response .

* Objects
DATA:
  lo_dunning                           TYPE REF TO z_icf_dunning_data_model ,
*  lo_json_serializer TYPE REF TO zcl_json_serializer. " Copy of the standard class CL_TREX_JSON_SERIALIZER
  lo_json_serializer                   TYPE REF TO cl_trex_json_serializer .

* Internal tables
DATA:
  lt_dunnings                          TYPE STANDARD TABLE OF sepmapps_openinv .

* Structures
DATA:
  ls_dunning                           TYPE sepmapps_openinv ,
  ls_response                          TYPE local_type_response.

* Variables
DATA:
  lv_rc                                TYPE i ,
  lv_json                              TYPE string .

* Variables
DATA:
  lv_verb                              TYPE string ,
  lv_path_info                         TYPE string ,
  lv_resource                          TYPE string ,
  lv_param_1                           TYPE string ,
  lv_param_2                           TYPE string .



*http://lu60277065.dhcp.rom.sap.corp:48000/sap/bc/zicf_dunning/DunningLevelDetails?sap-client=900&format=json


* Retrieving the request method (POST, GET, PUT, DELETE)
  lv_verb = server->request->get_header_field(
    name = '~request_method'
  ) .

* Retrieving the parameters passed in the URL
  lv_path_info = server->request->get_header_field(
    name = '~path_info'
  ) .

  SHIFT lv_path_info LEFT BY 1 PLACES .

  SPLIT lv_path_info
    AT '/'
    INTO lv_resource
         lv_param_1
         lv_param_2 .

* Only methods GET, POST, PUT, DELETE are allowed
  IF ( lv_verb NE 'GET' ) AND ( lv_verb NE 'POST' ) AND
     ( lv_verb NE 'PUT' ) AND ( lv_verb NE 'DELETE' ) .

    " For any other method the service should return the error code 405
    CALL METHOD server->response->set_status(
      code = '405'
      reason = 'Method not allowed'
    ) .

    CALL METHOD server->response->set_header_field(
      name = 'Allow'
      value = 'POST, GET, PUT, DELETE'
    ) .
    EXIT .

  ENDIF .



  CASE lv_verb .

    WHEN 'POST'.   " C (Create)

      CLEAR: ls_dunning ,
             ls_response ,
             lv_rc .

* Retrieve form data
*      ls_dunning-email     = server->request->get_form_field('email') .
*      ls_dunning-firstname = server->request->get_form_field('firstname') .
*      ls_dunning-lastname  = server->request->get_form_field('lastname') .

* Create an instance of the class to persist the Contact data in the database
      CREATE OBJECT lo_dunning .

* Create the Contact
      CALL METHOD lo_dunning->create
        EXPORTING  i_s_dunning = ls_dunning
        IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'User created successfully!' .   "hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_dunning->get_message( ) .
      ENDIF .

* Return the form data received back to the client
      APPEND ls_dunning TO ls_response-data .



    WHEN 'GET'.   " R (Read)

      CLEAR: ls_dunning ,
             ls_response .

      CREATE OBJECT lo_dunning .

* Retrieve the Contact's email passed in the URL
*      ls_dunning-email = lv_param_1 .

* Retrieve querystring data
*      ls_dunning-firstname = server->request->get_form_field('firstname') .
*      ls_dunning-lastname  = server->request->get_form_field('lastname') .

* Read Contact's data
      CALL METHOD lo_dunning->read
        EXPORTING  i_s_dunning  = ls_dunning
        IMPORTING  e_t_dunnings = lt_dunnings .

      IF NOT lt_dunnings[] IS INITIAL .
        ls_response-success = 'true' .
        ls_response-data[]  = lt_dunnings[] .
      ELSE.
        ls_response-success = 'false' .
        ls_response-msg     = lo_dunning->get_message( ) .
      ENDIF .


    WHEN 'PUT'. " U (Update)

      CLEAR: ls_dunning ,
             ls_response ,
             lv_rc .

* Retrieve the Contact's email passed in the URL
*      ls_dunning-email = lv_param_1 .

* Retrieve form data
*      ls_dunning-firstname = server->request->get_form_field('firstname') .
*      ls_dunning-lastname  = server->request->get_form_field('lastname') .

      CREATE OBJECT lo_dunning .

* Update the Contact
      CALL METHOD lo_dunning->update
        EXPORTING  i_s_dunning = ls_dunning
        IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'Contact updated successfully!' .  "Hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_dunning->get_message( ) .
      ENDIF .

* Return the form data received to the client
      APPEND ls_dunning TO ls_response-data .



    WHEN 'DELETE'. " D (Delete)

      CLEAR: ls_dunning ,
             ls_response ,
             lv_rc .

      CREATE OBJECT lo_dunning .

*     Retrieve the Contact's email passed in the URL
*      ls_dunning-email = lv_param_1 .

*     Delete the Contact
      CALL METHOD lo_dunning->delete
      EXPORTING  i_s_dunning = ls_dunning
      IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'Contact deleted successfully!' .   "Hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_dunning->get_message( ) .
      ENDIF .

  ENDCASE .


  CREATE OBJECT lo_json_serializer
    EXPORTING  data = ls_response . " Data to be serialized

* Serialize ABAP data to JSON
  CALL METHOD lo_json_serializer->serialize .

* Get JSON string
  CALL METHOD lo_json_serializer->get_data
    RECEIVING  rval = lv_json .

* Sets the content type of the response
  CALL METHOD server->response->set_header_field(
    name = 'Content-Type'
    value = 'application/json; charset=iso-8859-1'
  ) .

* Returns the results in JSON format
  CALL METHOD server->response->set_cdata( data = lv_json ) .


ENDMETHOD .
ENDCLASS.
