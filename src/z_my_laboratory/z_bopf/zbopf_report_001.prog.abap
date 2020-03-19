*&---------------------------------------------------------------------*
*& Report ZBOPF_REPORT_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBOPF_REPORT_001 .

*&Purpose: This report will help management to track the usage of Forwarding agreements
*&during invoicing for shipments created globally
*&Report output contain: Sales organization, Forwarding order, FWO Type, country, File Number,
*&Order creation date, Invoice amount, agreement
*&---------------------------------------------------------------------*

TYPE-POOLS:
  abap .

TABLES:
  syst ,
  zbopf_cust_md .

*** TYPES
TYPES:
  BEGIN OF ty_final,
    kunnr                              TYPE zbopf_cust_master_data_ps-kunnr,
    name1                              TYPE zbopf_cust_master_data_ps-name1,
    land1                              TYPE zbopf_cust_master_data_ps-land1,
  END OF ty_final .


***Data declaration
DATA:
  ls_selpar                            TYPE          /bobf/s_frw_query_selparam,
  lt_selpar                            TYPE TABLE OF /bobf/s_frw_query_selparam,
  lt_trq_key                           TYPE          /bobf/t_frw_key,
  lt_trq_root                          TYPE          ztroot1,
  ls_trq_root                          LIKE LINE OF  lt_trq_root .

DATA:
  ls_cfir_root                         TYPE          zbopf_cust_master_data_ts,
  lt_cfir_root                         TYPE          zbopf_cust_master_data_ts_tt,
  lo_trq_srvmgr                        TYPE REF TO   /bobf/if_tra_service_manager,
  lt_cfir_root_key                     TYPE          /bobf/t_frw_key,
  ls_cfir_root_key                     TYPE          /bobf/s_frw_key,
  lt_tcc_root                          TYPE          zbopf_cust_master_data_ps_keyt,
  lt_tcc_root_key                      TYPE          /bobf/t_frw_key,
  ls_tcc_root_key                      LIKE LINE OF  lt_tcc_root_key,
  ls_tcc_root                          TYPE          zbopf_cust_master_data_ps_key,
  lo_srvmgr_cfir                       TYPE REF TO   /bobf/if_tra_service_manager,
*  ls_tcc_charge_item                   TYPE          /scmtms/s_tcc_chrgitem_k,
*  lt_tcc_charge_item                   TYPE TABLE OF /scmtms/s_tcc_chrgitem_k,
  lt_trq_cfir_link                     TYPE          /bobf/t_frw_key_link,
  ls_trq_cfir_link                     LIKE LINE OF  lt_trq_cfir_link,
  lv_chrg_it_assoc_key                 TYPE /bobf/obm_assoc_key .


DATA:
  ls_final                             TYPE ty_final,
  lt_final                             TYPE TABLE OF ty_final .

FIELD-SYMBOLS:
  <fs_root>                            LIKE LINE OF lt_cfir_root,
  <fs_tcc_root_key>                    TYPE zbopf_cust_master_data_ps_key .

SELECT-OPTIONS:
  s_land1                              FOR zbopf_cust_md-land1 OBLIGATORY NO-EXTENSION,
  s_regio                              FOR zbopf_cust_md-regio OBLIGATORY NO INTERVALS .


START-OF-SELECTION .

*Get instance of service manager for TRQ
  lo_trq_srvmgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( zif_customer_master_data1_c=>sc_bo_key ) .

  CLEAR: ls_selpar, lt_selpar .
  ls_selpar-attribute_name = 'LAND1' . "zif_customer_master_data1_c=>sc_node_attribute–root-land1 .
  MOVE-CORRESPONDING s_land1 TO ls_selpar .
  APPEND ls_selpar TO lt_selpar .

  CLEAR: ls_selpar .
  DATA: ls_regio LIKE LINE OF s_regio[] .

  LOOP AT s_regio[] INTO ls_regio .
    ls_selpar-attribute_name = 'REGIO' . "zif_customer_master_data1_c=>sc_node_attribute–root–regio .
    MOVE-CORRESPONDING ls_regio TO ls_selpar .
    APPEND ls_selpar TO lt_selpar .
    CLEAR: ls_selpar, ls_regio .
  ENDLOOP .

***Here we can not call RETRIEVE method because we do not have TRQ node keys on hand .
***For this requirement it is recommended to call QUERY since RETRIEVE does not aligned with the selection screen parameters

  CLEAR: lt_trq_key, lt_trq_root .
  lo_trq_srvmgr->query(
    EXPORTING  iv_query_key            = zif_customer_master_data1_c=>sc_query–root–query_by_attributes
               it_selection_parameters = lt_selpar
               iv_fill_data            = abap_true
    IMPORTING  et_data                 = lt_trq_root
               et_key                  = lt_trq_key
    ) .

**If no data exist in database table then raise error message .
  IF lt_trq_key IS NOT INITIAL .
    CLEAR: lt_cfir_root, lt_trq_cfir_link .
    lo_trq_srvmgr->retrieve_by_association(
      EXPORTING  iv_node_key    = zif_customer_master_data1_c=>sc_node–root                     ” Node Name
                 it_key         = lt_trq_key                                         ” Key Table
                 iv_association = zif_customer_master_data1_c=>sc_association–root–cfir_root    ” Name of Association
                 iv_fill_data   = abap_true
      IMPORTING  et_data        = lt_cfir_root    ” Data Return Structure
                 et_key_link    = lt_trq_cfir_link
    ) .

    LOOP AT lt_cfir_root ASSIGNING <fs_root> .
      ls_cfir_root_key–key = <fs_root>–key .
      INSERT ls_cfir_root_key INTO TABLE lt_cfir_root_key .
      CLEAR: ls_cfir_root_key .
    ENDLOOP .

    IF lt_cfir_root_key IS NOT INITIAL .

      lo_srvmgr_cfir = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_custfreightinvreq_c=>sc_bo_key ) .

      CLEAR: lt_tcc_root .
      lo_srvmgr_cfir->retrieve_by_association(
        EXPORTING  iv_node_key    = /scmtms/if_custfreightinvreq_c=>sc_node–trnspcharges
                   it_key         = lt_cfir_root_key
                   iv_association = /scmtms/if_custfreightinvreq_c=>sc_association–root–trnspcharges
                   iv_fill_data   = abap_true
        IMPORTING  et_data        = lt_tcc_root ) .
    ENDIF .

    CLEAR: ls_tcc_root_key .
    LOOP AT lt_tcc_root ASSIGNING <fs_tcc_root_key> .
      ls_tcc_root_key–key = <fs_tcc_root_key>–key .
      INSERT ls_tcc_root_key INTO TABLE lt_tcc_root_key .
      CLEAR: ls_tcc_root_key .
    ENDLOOP .

    IF lt_tcc_root_key IS NOT INITIAL .
* Get Charge Item node key and Charge<->Charge Item Association key
      CALL METHOD /scmtms/cl_common_helper=>get_do_keys_4_rba
        EXPORTING  iv_host_bo_key      = /scmtms/if_custfreightinvreq_c=>sc_bo_key
                   iv_host_do_node_key = /scmtms/if_custfreightinvreq_c=>sc_node–trnspcharges
                   iv_do_node_key      = /scmtms/if_tcc_trnsp_chrg_c=>sc_node–chargeitem
                   iv_do_assoc_key     = /scmtms/if_tcc_trnsp_chrg_c=>sc_association–root–chargeitem
        IMPORTING  ev_assoc_key        = lv_chrg_it_assoc_key .

*& –> Get the DO transportcharges chargeitem data …
*&---------------------------------------------------------------------*

      CALL METHOD lo_srvmgr_cfir->retrieve_by_association
        EXPORTING  iv_node_key    = /scmtms/if_custfreightinvreq_c=>sc_node–trnspcharges
                   iv_association = lv_chrg_it_assoc_key
                   it_key         = lt_tcc_root_key
                   iv_fill_data   = abap_true
        IMPORTING  et_data        = lt_tcc_charge_item .

    ENDIF .
  ENDIF .

  CLEAR: ls_trq_root, ls_trq_cfir_link, ls_cfir_root, ls_tcc_charge_item, ls_tcc_root, ls_final .
  LOOP AT lt_trq_root INTO ls_trq_root .
    LOOP AT lt_trq_cfir_link INTO ls_trq_cfir_link WHERE source_key = ls_trq_root–key .
      READ TABLE lt_cfir_root INTO ls_cfir_root
        WITH KEY key = ls_trq_cfir_link–target_key
        BINARY SEARCH .
      IF sy–subrc EQ 0 .
        READ TABLE lt_tcc_charge_item INTO ls_tcc_charge_item
          WITH KEY root_key = ls_cfir_root–key
          BINARY SEARCH .
        IF sy–subrc EQ 0 .
          ls_final–fileno         = ls_trq_root-zfileno .
          ls_final–sales_org_id   = ls_trq_root–sales_org_id .
          ls_final–trq_type       = ls_trq_root–trq_type .
          ls_final–fagrmntid044   = ls_tcc_charge_item–fagrmntid044 .
          ls_final–order_date     = ls_trq_root–order_date .

          READ TABLE lt_tcc_root INTO ls_tcc_root
            WITH KEY root_key = ls_cfir_root–key
            BINARY SEARCH .
          IF sy–subrc EQ 0 .
            ls_final–amount = ls_tcc_root–rnd_net_amount .
          ENDIF .
          APPEND ls_final TO lt_final .
        ENDIF .
      ENDIF .
      CLEAR: ls_final, ls_cfir_root, ls_tcc_charge_item, ls_trq_cfir_link .
    ENDLOOP .
    CLEAR: ls_trq_root .
  ENDLOOP .

  SORT lt_final
    BY sales_org_id
    ASCENDING fagrmntid044 order_date DESCENDING .


END-OF-SELECTION .

  PERFORM display_grid_output .


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_GRID_OUTPUT
*&---------------------------------------------------------------------*
*       text
*&---------------------------------------------------------------------*
*  –>  p1        text
*  <–  p2        text
*&---------------------------------------------------------------------*
FORM display_grid_output  .

TYPES : BEGIN OF ty_message,
  row                                  TYPE i,
  partner(30)                          TYPE c,
  msg_type                             TYPE char20,
  message(100)                         TYPE c,
END OF ty_message .

  DATA: t_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE .

  t_fieldcat–col_pos   = ‘1’ .
  t_fieldcat–fieldname = ‘SALES_ORG_ID’ .
  t_fieldcat–seltext_l = ‘House’ .
  t_fieldcat–outputlen = ’15’ .
  APPEND t_fieldcat .

  t_fieldcat–col_pos   = ‘2’ .
  t_fieldcat–fieldname = ‘FILENO’ .
  t_fieldcat–seltext_l = ‘File Number’ .
  t_fieldcat–outputlen = ’20’ .
  APPEND t_fieldcat .

  t_fieldcat–col_pos   = ‘3’ .
  t_fieldcat–fieldname = ‘TRQ_TYPE’ .
  t_fieldcat–seltext_l = ‘File Type’ .
  t_fieldcat–outputlen = ’10’ .
  APPEND t_fieldcat .

  t_fieldcat–col_pos   = ‘4’ .
  t_fieldcat–fieldname = ‘FAGRMNTID044’ .
  t_fieldcat–seltext_l = ‘Aggreement’ .
  t_fieldcat–outputlen = ’30’ .
  APPEND t_fieldcat .

  t_fieldcat–col_pos   = ‘5’ .
  t_fieldcat–fieldname = ‘ORDER_DATE’ .
  t_fieldcat–seltext_l = ‘Order creation Date’ .
  t_fieldcat–outputlen = ’20’ .
  APPEND t_fieldcat .

  t_fieldcat–col_pos   = ‘6’ .
  t_fieldcat–fieldname = ‘AMOUNT’ .
  t_fieldcat–seltext_l = ‘Amount’ .
  t_fieldcat–outputlen = ’15’ .
  APPEND t_fieldcat .

  CALL FUNCTION ‘REUSE_ALV_GRID_DISPLAY’
    EXPORTING  i_callback_program = ‘ZBOPF_REPORT_001’
*               i_grid_title       = lw_title
               it_fieldcat        = t_fieldcat[]
*               is_layout          = ls_layout
    TABLES     t_outtab           = lt_final
    EXCEPTIONS program_error      = 1
               OTHERS             = 2 .

ENDFORM .                    ” DISPLAY_GRID_OUTPUT
