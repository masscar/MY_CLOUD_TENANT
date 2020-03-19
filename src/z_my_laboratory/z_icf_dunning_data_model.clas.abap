class Z_ICF_DUNNING_DATA_MODEL definition
  public
  final
  create public .

public section.

  methods CREATE
    importing
      !I_S_DUNNING type SEPMAPPS_OPENINV
    exporting
      !E_RC type INT4 .
  methods READ
    importing
      !I_S_DUNNING type SEPMAPPS_OPENINV
    exporting
      !E_T_DUNNINGS type Z_SEPMAPPS_OPENINV_TT .
  methods UPDATE
    importing
      !I_S_DUNNING type SEPMAPPS_OPENINV
    exporting
      !E_RC type INT4 .
  methods DELETE
    importing
      !I_S_DUNNING type SEPMAPPS_OPENINV
    exporting
      !E_RC type INT4 .
  methods GET_MESSAGE
    returning
      value(R_MSG) type STRING .
protected section.
private section.

  data STATUS type STRING .

ENDCLASS.



CLASS Z_ICF_DUNNING_DATA_MODEL IMPLEMENTATION.


METHOD create .

*  DATA: l_email TYPE ztb_scnblog2-email .
*
** Check if the contact already exist
*  SELECT SINGLE email FROM ztb_scnblog2
*    INTO l_email
*    WHERE email = i_s_contact-email .
*
*  IF sy-subrc = 0 .
*    e_rc = 4 .
*    me->status = text-001 . "Contact already exist
*    EXIT .
*  ENDIF .
*
** Create contact
*  INSERT ztb_scnblog2 FROM i_s_contact .

  e_rc = sy-subrc .

ENDMETHOD .


METHOD delete .

*  DELETE FROM ztb_scnblog2 WHERE email = i_s_contact-email .

ENDMETHOD .


METHOD GET_MESSAGE .

  r_msg = me->status .

ENDMETHOD .


METHOD read .

*  DATA: l_cond(72) TYPE c ,
*        lt_cond LIKE STANDARD TABLE OF l_cond .
*
*  CLEAR: l_cond, lt_cond[] .
*
*  IF i_s_contact-email IS NOT INITIAL .
*    CONCATENATE 'EMAIL = ''' i_s_contact-email '''' INTO l_cond .
*    APPEND l_cond TO lt_cond .
*  ENDIF .
*
*  IF i_s_contact-firstname IS NOT INITIAL .
*    IF l_cond IS INITIAL .
*      CONCATENATE 'FIRSTNAME LIKE ''%' i_s_contact-firstname '%''' INTO l_cond .
*    ELSE .
*      CONCATENATE 'OR FIRSTNAME LIKE ''%' i_s_contact-firstname '%''' INTO l_cond .
*    ENDIF .
*    APPEND l_cond TO lt_cond .
*  ENDIF .
*
*  IF i_s_contact-lastname IS NOT INITIAL .
*    IF l_cond IS INITIAL .
*      CONCATENATE 'LASTNAME = ''%' i_s_contact-lastname '%''' INTO l_cond .
*    ELSE .
*      CONCATENATE 'OR LASTNAME = ''%' i_s_contact-lastname '%''' INTO l_cond .
*    ENDIF .
*    APPEND l_cond TO lt_cond .
*  ENDIF .
*
*  IF lt_cond[] IS NOT INITIAL .
*
*    SELECT email firstname lastname FROM ztb_scnblog2
*    INTO CORRESPONDING FIELDS OF TABLE e_t_contacts
*    WHERE (lt_cond) .
*
*  ELSE .
*
*    SELECT email firstname lastname FROM ztb_scnblog2
*    INTO CORRESPONDING FIELDS OF TABLE e_t_contacts .
*
*  ENDIF .

FIELD-SYMBOLS:
  <dunning>                            LIKE LINE OF e_t_dunnings .

  APPEND INITIAL LINE TO e_t_dunnings ASSIGNING <dunning> .
  <dunning>-invoice_guid            = '00000000000000000000000000000001' .
  <dunning>-so_id                   = '0000000001' .
  <dunning>-bupa_id                 = '0000001000' .
  <dunning>-company_name            = 'COMPANY 01' .
  <dunning>-days_open               = 10 .
  <dunning>-gross_amount            = '15000.30' .
  <dunning>-currency_code           = 'EUR' .
  <dunning>-bupa_rank               = 10 .
  <dunning>-current_dunning_level   = 'A' .
  CONVERT DATE sy-datum
          TIME sy-uzeit
          INTO TIME STAMP <dunning>-invoice_created_at
          TIME ZONE 'CET' .
  <dunning>-invoice_created_at_date = sy-datum .


  APPEND INITIAL LINE TO e_t_dunnings ASSIGNING <dunning> .
  <dunning>-invoice_guid            = '00000000000000000000000000000002' .
  <dunning>-so_id                   = '0000000020' .
  <dunning>-bupa_id                 = '0000001000' .
  <dunning>-company_name            = 'COMPANY 01' .
  <dunning>-days_open               = 50 .
  <dunning>-gross_amount            = '76000.31' .
  <dunning>-currency_code           = 'EUR' .
  <dunning>-bupa_rank               = 10 .
  <dunning>-current_dunning_level   = 'A' .
  CONVERT DATE sy-datum
          TIME sy-uzeit
          INTO TIME STAMP <dunning>-invoice_created_at
          TIME ZONE 'CET' .
  <dunning>-invoice_created_at_date = sy-datum .


  APPEND INITIAL LINE TO e_t_dunnings ASSIGNING <dunning> .
  <dunning>-invoice_guid            = '00000000000000000000000000000003' .
  <dunning>-so_id                   = '0000000300' .
  <dunning>-bupa_id                 = '0000001000' .
  <dunning>-company_name            = 'COMPANY 01' .
  <dunning>-days_open               = 8 .
  <dunning>-gross_amount            = '2300.80' .
  <dunning>-currency_code           = 'EUR' .
  <dunning>-bupa_rank               = 10 .
  <dunning>-current_dunning_level   = 'A' .
  CONVERT DATE sy-datum
          TIME sy-uzeit
          INTO TIME STAMP <dunning>-invoice_created_at
          TIME ZONE 'CET' .
  <dunning>-invoice_created_at_date = sy-datum .


  APPEND INITIAL LINE TO e_t_dunnings ASSIGNING <dunning> .
  <dunning>-invoice_guid            = '00000000000000000000000000000004' .
  <dunning>-so_id                   = '0000000101' .
  <dunning>-bupa_id                 = '0000002300' .
  <dunning>-company_name            = 'COMPANY 23' .
  <dunning>-days_open               = 35 .
  <dunning>-gross_amount            = '67000.30' .
  <dunning>-currency_code           = 'EUR' .
  <dunning>-bupa_rank               = 10 .
  <dunning>-current_dunning_level   = 'B' .
  CONVERT DATE sy-datum
          TIME sy-uzeit
          INTO TIME STAMP <dunning>-invoice_created_at
          TIME ZONE 'CET' .
  <dunning>-invoice_created_at_date = sy-datum .


ENDMETHOD .


METHOD update .

* Perform validations
*  UPDATE sepmapps_openinv FROM i_s_dunning .

  e_rc = sy-subrc .

ENDMETHOD .
ENDCLASS.
