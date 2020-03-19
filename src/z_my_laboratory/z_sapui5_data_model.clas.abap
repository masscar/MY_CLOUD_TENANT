class Z_SAPUI5_DATA_MODEL definition
  public
  final
  create public .

public section.

  methods CREATE
    importing
      !I_S_CONTACT type ZTB_SCNBLOG2
    exporting
      !E_RC type INT4 .
  methods READ
    importing
      !I_S_CONTACT type ZTB_SCNBLOG2
    exporting
      !E_T_CONTACTS type ZTT_SCNBLOG2 .
  methods UPDATE
    importing
      !I_S_CONTACT type ZTB_SCNBLOG2
    exporting
      !E_RC type INT4 .
  methods DELETE
    importing
      !I_S_CONTACT type ZTB_SCNBLOG2
    exporting
      !E_RC type INT4 .
  methods GET_MESSAGE
    returning
      value(R_MSG) type STRING .
protected section.
private section.

  data STATUS type STRING .

ENDCLASS.



CLASS Z_SAPUI5_DATA_MODEL IMPLEMENTATION.


METHOD CREATE .

  DATA: l_email TYPE ztb_scnblog2-email .

* Check if the contact already exist
  SELECT SINGLE email FROM ztb_scnblog2
    INTO l_email
    WHERE email = i_s_contact-email .

  IF sy-subrc = 0 .
    e_rc = 4 .
    me->status = text-001 . "Contact already exist
    EXIT .
  ENDIF .

* Create contact
  INSERT ztb_scnblog2 FROM i_s_contact .

  e_rc = sy-subrc .

ENDMETHOD .


METHOD DELETE .

  DELETE FROM ztb_scnblog2 WHERE email = i_s_contact-email .

ENDMETHOD .


METHOD GET_MESSAGE .

  r_msg = me->status .

ENDMETHOD .


METHOD READ .

  DATA: l_cond(72) TYPE c ,
        lt_cond LIKE STANDARD TABLE OF l_cond .

  CLEAR: l_cond, lt_cond[] .

  IF i_s_contact-email IS NOT INITIAL .
    CONCATENATE 'EMAIL = ''' i_s_contact-email '''' INTO l_cond .
    APPEND l_cond TO lt_cond .
  ENDIF .

  IF i_s_contact-firstname IS NOT INITIAL .
    IF l_cond IS INITIAL .
      CONCATENATE 'FIRSTNAME LIKE ''%' i_s_contact-firstname '%''' INTO l_cond .
    ELSE .
      CONCATENATE 'OR FIRSTNAME LIKE ''%' i_s_contact-firstname '%''' INTO l_cond .
    ENDIF .
    APPEND l_cond TO lt_cond .
  ENDIF .

  IF i_s_contact-lastname IS NOT INITIAL .
    IF l_cond IS INITIAL .
      CONCATENATE 'LASTNAME = ''%' i_s_contact-lastname '%''' INTO l_cond .
    ELSE .
      CONCATENATE 'OR LASTNAME = ''%' i_s_contact-lastname '%''' INTO l_cond .
    ENDIF .
    APPEND l_cond TO lt_cond .
  ENDIF .

  IF lt_cond[] IS NOT INITIAL .

    SELECT email firstname lastname FROM ztb_scnblog2
    INTO CORRESPONDING FIELDS OF TABLE e_t_contacts
    WHERE (lt_cond) .

  ELSE .

    SELECT email firstname lastname FROM ztb_scnblog2
    INTO CORRESPONDING FIELDS OF TABLE e_t_contacts .

  ENDIF .

ENDMETHOD .


METHOD UPDATE .

* Perform validations
  UPDATE ztb_scnblog2 FROM i_s_contact .

  e_rc = sy-subrc .

ENDMETHOD .
ENDCLASS.
