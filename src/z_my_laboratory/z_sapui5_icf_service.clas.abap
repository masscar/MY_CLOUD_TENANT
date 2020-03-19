class Z_SAPUI5_ICF_SERVICE definition
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



CLASS Z_SAPUI5_ICF_SERVICE IMPLEMENTATION.


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

  lo_router->attach( iv_template = '/contacts'                        iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts.{format}'               iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{email}'                iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{email}.{format}'       iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{firstname}'            iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{firstname}.{format}'   iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{lastname}'             iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .
  lo_router->attach( iv_template = '/contacts/{lastname}.{format}'    iv_handler_class = 'Z_SAPUI5_DATA_MODEL_RESOURCE' ) .

  ro_root_handler = lo_router .

ENDMETHOD .


METHOD _HANDLE_REQUEST .

TYPES:
  BEGIN OF local_type_response ,
    success                            TYPE string ,
    msg                                TYPE string ,
    data                               TYPE ztt_scnblog2 ,
  END OF local_type_response .

* Objects
DATA:
  lo_contact                           TYPE REF TO z_sapui5_data_model ,
*  lo_json_serializer TYPE REF TO zcl_json_serializer. " Copy of the standard class CL_TREX_JSON_SERIALIZER
  lo_json_serializer                   TYPE REF TO cl_trex_json_serializer .

* Internal tables
DATA:
  lt_contacts                          TYPE STANDARD TABLE OF ztb_scnblog2 .

* Structures
DATA:
  ls_contact                           TYPE ztb_scnblog2 ,
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

      CLEAR: ls_contact ,
             ls_response ,
             lv_rc .

* Retrieve form data
      ls_contact-email     = server->request->get_form_field('email') .
      ls_contact-firstname = server->request->get_form_field('firstname') .
      ls_contact-lastname  = server->request->get_form_field('lastname') .

* Create an instance of the class to persist the Contact data in the database
      CREATE OBJECT lo_contact .

* Create the Contact
      CALL METHOD lo_contact->create
        EXPORTING  i_s_contact = ls_contact
        IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'User created successfully!' .   "hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_contact->get_message( ) .
      ENDIF .

* Return the form data received back to the client
      APPEND ls_contact TO ls_response-data .



    WHEN 'GET'.   " R (Read)

      CLEAR: ls_contact ,
             ls_response .

      CREATE OBJECT lo_contact .

* Retrieve the Contact's email passed in the URL
      ls_contact-email = lv_param_1 .

* Retrieve querystring data
      ls_contact-firstname = server->request->get_form_field('firstname') .
      ls_contact-lastname  = server->request->get_form_field('lastname') .

* Read Contact's data
      CALL METHOD lo_contact->read
        EXPORTING  i_s_contact  = ls_contact
        IMPORTING  e_t_contacts = lt_contacts .

      IF NOT lt_contacts[] IS INITIAL .
        ls_response-success = 'true' .
        ls_response-data[]  = lt_contacts[] .
      ELSE.
        ls_response-success = 'false' .
        ls_response-msg     = lo_contact->get_message( ) .
      ENDIF .


    WHEN 'PUT'. " U (Update)

      CLEAR: ls_contact ,
             ls_response ,
             lv_rc .

* Retrieve the Contact's email passed in the URL
      ls_contact-email = lv_param_1 .

* Retrieve form data
      ls_contact-firstname = server->request->get_form_field('firstname') .
      ls_contact-lastname  = server->request->get_form_field('lastname') .

      CREATE OBJECT lo_contact .

* Update the Contact
      CALL METHOD lo_contact->update
        EXPORTING  i_s_contact = ls_contact
        IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'Contact updated successfully!' .  "Hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_contact->get_message( ) .
      ENDIF .

* Return the form data received to the client
      APPEND ls_contact TO ls_response-data .



    WHEN 'DELETE'. " D (Delete)

      CLEAR: ls_contact ,
             ls_response ,
             lv_rc .

      CREATE OBJECT lo_contact .

*     Retrieve the Contact's email passed in the URL
      ls_contact-email = lv_param_1 .

*     Delete the Contact
      CALL METHOD lo_contact->delete
      EXPORTING  i_s_contact = ls_contact
      IMPORTING  e_rc        = lv_rc .

      IF lv_rc IS INITIAL .
        ls_response-success = 'true' .
        ls_response-msg     = 'Contact deleted successfully!' .   "Hardcoded here intentionally
      ELSE .
        ls_response-success = 'false' .
        ls_response-msg     = lo_contact->get_message( ) .
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
