*&---------------------------------------------------------------------*
*&  Include           Z_ABAP_SCAN_CODE_DATA
*&---------------------------------------------------------------------*

DATA:
  gt_abap_lines                        TYPE sci_include ,
  gt_order_by_lines                    TYPE sci_include ,
*main module
  gt_tokens_main                       TYPE stokesx_tab ,
  gt_statements_main                   TYPE sstmnt_tab ,
*includes
  gt_keywords                          TYPE TABLE OF char30 ,
  gt_tokens                            TYPE stokesx_tab ,
  gt_statements                        TYPE sstmnt_tab ,
  gt_levels                            TYPE slevel_tab ,
  gt_structures                        TYPE sstruc_tab ,

  gv_fugr_root_name                    TYPE progname ,
  gv_function_name                     TYPE rs38l_fnam ,
  gv_message                           TYPE sychar200 ,
  gv_include                           TYPE program ,
  gv_line                              TYPE i ,
  gv_word                              TYPE sychar30 .

DATA:
  gv_return_code                       TYPE sysubrc .
DATA:
  gv_current_row_scan                  TYPE i ,
  gv_current_row_index                 TYPE i .
DATA:
  gv_into_table_token_line             TYPE i ,
  gv_tablename_token_line              TYPE i ,
  gv_alias_token_line                  TYPE i ,
  gv_alias                             TYPE string ,
  gv_tablename                         TYPE objectname ,
  gv_internal_tablename                TYPE objectname ,
  gs_table_info                        TYPE dd02v ,
  gv_select_end_statement              TYPE i ,
  gv_end_statement_length              TYPE i ,
  gv_end_statement_character           TYPE i ,
  gv_end_statement_offset              TYPE i ,
*  gv_statement_from                    TYPE i ,
*  gv_statement_to                      TYPE i ,
  gv_statement_shift                   TYPE i .

FIELD-SYMBOLS:
  <abap_line>                          LIKE LINE OF gt_abap_lines ,
  <order_by_line>                      LIKE LINE OF gt_order_by_lines ,
  <token_main>                         LIKE LINE OF gt_tokens_main ,
  <token_include>                      LIKE LINE OF gt_tokens ,
  <token>                              LIKE LINE OF gt_tokens ,
  <level>                              LIKE LINE OF gt_levels ,
  <select_start_row>                   LIKE LINE OF gt_tokens ,
  <select_end_row>                     LIKE LINE OF gt_tokens ,
  <token_nested>                       LIKE LINE OF gt_tokens ,
  <token_join>                         LIKE LINE OF gt_tokens ,
  <alias_of_primary_table>             LIKE LINE OF gt_tokens ,
  <statement_main>                     LIKE LINE OF gt_statements_main ,
  <statement>                          LIKE LINE OF gt_statements ,
  <structure>                          LIKE LINE OF gt_structures .
DATA:
  gs_order_by_statement                LIKE LINE OF gt_abap_lines .
DATA:
  gt_table_columns                     TYPE extdfiest .
FIELD-SYMBOLS:
  <table_column>                       LIKE LINE OF gt_table_columns .

TYPES:
  BEGIN OF ty_key_field ,
    fieldname                          TYPE fieldname ,
  END OF ty_key_field .
DATA:
  gt_key_fields                        TYPE TABLE OF ty_key_field .
FIELD-SYMBOLS:
  <key_field>                          TYPE fieldname .
