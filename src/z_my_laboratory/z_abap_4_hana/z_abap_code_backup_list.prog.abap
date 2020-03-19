*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_BACKUP_LIST                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Author      : M. CARDOSI (SAP ITALIA) -------------------------------
*& Date        : 05.06.2015 --------------------------------------------
*& Description : -------------------------------------------------------
*&
*& <description>
*&
*&
*&
*&
*&---------------------------------------------------------------------*
REPORT z_abap_code_backup_list         MESSAGE-ID z_abap_4_hana
*      NO STANDARD PAGE HEADING
       LINE-SIZE 132
       LINE-COUNT 65 .


*-----------------------------------------------------------------------
*- Modification history ------------------------------------------------
*-----------------------------------------------------------------------
*- Date------   ID---   Author------------------------------------------
*- Description----------------------------------------------------------
*-----------------------------------------------------------------------
*- XX.XX.XXXX   Mnnnn   XXXXXXX
*- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*-----------------------------------------------------------------------
*-
*-----------------------------------------------------------------------


*-----------------------------------------------------------------------
*- CONSTANTS -----------------------------------------------------------
*-----------------------------------------------------------------------
*ONSTANTS:
* TASK_DELETE VALUE 3.


*-----------------------------------------------------------------------
*- CLASSES -------------------------------------------------------------
*-----------------------------------------------------------------------
*LASS:
* cl_smw1_siteprovider DEFINITION LOAD .


*-----------------------------------------------------------------------
*- TYPE-POOLS ----------------------------------------------------------
*-----------------------------------------------------------------------
TYPE-POOLS:
  icon .


*-----------------------------------------------------------------------
*- TYPES ---------------------------------------------------------------
*-----------------------------------------------------------------------
TYPES:
  BEGIN OF ty_module_list ,
    pgmid                              TYPE pgmid ,
    object                             TYPE trobjtype ,
    obj_name                           TYPE sobj_name ,
    name                               TYPE progname ,
  END OF ty_module_list .


*-----------------------------------------------------------------------
*- TABLES --------------------------------------------------------------
*-----------------------------------------------------------------------
TABLES:
  trdir ,
  rs38m , "SE38 help value
  rs38l . "SE37 help value


*-----------------------------------------------------------------------
*- INTERNAL TABLES -----------------------------------------------------
*-----------------------------------------------------------------------
*ATA:
* tStxh                      LIKE stxh       OCCURS 0 WITH HEADER LINE .


*-----------------------------------------------------------------------
*- VARIABLES -----------------------------------------------------------
*-----------------------------------------------------------------------
INCLUDE z_abap_scan_code_data .

DATA:
  gt_includes                          LIKE gt_abap_lines .
DATA:
  gv_progname_len                      TYPE i .
DATA:
  gv_folder_name                       TYPE salfile-longname ,
  gv_file_name                         TYPE fileExtern ,
  gt_folder_files                      TYPE TABLE OF salfldir .


DATA:
  go_trkorr_entity                     TYPE REF TO cl_cts_tr_req_decorator_log ,
  gt_trkorr_team                       TYPE cl_cts_tr_req_decorator_log=>ty_users ,
  gv_trkorr_type                       TYPE cl_cts_tr_req_decorator_log=>ty_request_type ,
  gv_trkorr_status                     TYPE cl_cts_tr_req_decorator_log=>ty_status .

DATA:
  gv_source_system                     TYPE srcsystem .

DATA:
  go_abap_compiler                     TYPE REF TO cl_abap_compiler ,
  gt_refs                              TYPE cl_abap_compiler=>t_all_refs ,
  gv_error                             type sychar01 ,
  gt_errors                            type scr_errors ,
  gv_abort                             type sychar01 .
DATA:
  gt_compiler_results                  TYPE scr_refs ,
  gt_compiler_errors                   TYPE synt_errors .
FIELD-SYMBOLS:
  <compiler_result>                    LIKE LINE OF gt_compiler_results .

DATA:
  gv_pgmid                             TYPE pgmid ,
  gv_object                            TYPE trobjtype ,
  gv_obj_name                          TYPE sobj_name ,
  gv_trobj_name                        TYPE trobj_name ,
  gv_wdyn_name                         TYPE trobj_name .
DATA:
  gv_trkorr                            TYPE e070-trkorr ,
  gv_task                              TYPE e070-trkorr ,
  gs_k0200                             TYPE kO200 ,
  gs_tadir                             TYPE tadir ,
  gv_append                            TYPE boole_d .

DATA:
  gs_backup_object                     TYPE zbck_abap_4_hana ,
  gt_backup_objects                    TYPE TABLE OF zbck_abap_4_hana ,
  gs_backup_repository                 TYPE zbck_abap_4_hana ,
  BEGIN OF gs_backup_key ,
    object                             TYPE trObjType ,
    obj_name                           TYPE sObj_name ,
  END OF gs_backup_key .
FIELD-SYMBOLS:
  <backup_object>                      LIKE LINE OF gt_backup_objects .

DATA:
  gv_count                             TYPE i .

DATA:
  gt_rdir                              TYPE TABLE OF trdir ,
  gt_main_modules                      TYPE TABLE OF ty_module_list ,
  gt_main_fugr                         TYPE TABLE OF tlibg ,
  gt_modules_name                      TYPE TABLE OF ty_module_list ,
  gs_module_name                       LIKE LINE OF gt_modules_name .
FIELD-SYMBOLS:
  <main_fugr>                          LIKE LINE OF gt_main_fugr ,
  <main_module>                        LIKE LINE OF gt_main_modules ,
  <module_name>                        LIKE LINE OF gt_modules_name .



*-----------------------------------------------------------------------
*- SALV ----------------------------------------------------------------
*-----------------------------------------------------------------------
DATA:
  gt_output                            TYPE TABLE OF zst_abap_restore_code_list .
FIELD-SYMBOLS:
  <output>                             LIKE LINE OF gt_output .
DATA:
  go_salv                              TYPE REF TO cl_salv_table ,
  go_salv_events                       TYPE REF TO cl_salv_events_table ,
  go_salv_columns                      TYPE REF TO cl_salv_columns ,
  gt_salv_col_tab                      TYPE salv_t_column_ref ,
  go_salv_functions                    TYPE REF TO cl_salv_functions_list ,
  go_salv_header                       TYPE REF TO cl_salv_form_layout_grid ,
  go_salv_header_label                 TYPE REF TO cl_salv_form_label ,
  go_salv_header_flow                  TYPE REF TO cl_salv_form_layout_flow ,
  go_salv_display_settings             TYPE REF TO cl_salv_display_settings .
FIELD-SYMBOLS:
  <column>                             LIKE LINE OF gt_salv_col_tab .



*-----------------------------------------------------------------------
*- RANGES --------------------------------------------------------------
*-----------------------------------------------------------------------
*ANGES:
* r_xxxx
*ATA:
* r_xxxx                     TYPE RANGE OF xxx ,
* st_xxxx                    LIKE LINE OF r_xxx


*-----------------------------------------------------------------------
*- SELECTION-SCREEN ----------------------------------------------------
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK 001
                 WITH FRAME TITLE text-b01 .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(14) text-p02 .
SELECTION-SCREEN POSITION 15 .
PARAMETERS:
  p_repid                              TYPE c RADIOBUTTON
                                              GROUP objt .
SELECTION-SCREEN POSITION 20 .
SELECT-OPTIONS:
  s_repid                              FOR rs38m-programm .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(14) text-p03 .
SELECTION-SCREEN POSITION 15 .
PARAMETERS:
  p_fugr                               TYPE c RADIOBUTTON
                                              GROUP objt .
SELECTION-SCREEN POSITION 20 .
SELECT-OPTIONS:
  s_fugr                               FOR rs38l-name .
SELECTION-SCREEN END OF LINE .

*SELECTION-SCREEN BEGIN OF LINE .
*SELECTION-SCREEN COMMENT 1(30) text-p01 .
*SELECTION-SCREEN POSITION 35 .
PARAMETERS:
  p_class                              TYPE c "RADIOBUTTON
*                                              GROUP objt
                                              NO-DISPLAY .
*SELECTION-SCREEN END OF LINE .
*SELECTION-SCREEN POSITION 20 .
*SELECT-OPTIONS:
*  s_clas                               FOR rs38l-name NO INTERVALS .
*SELECTION-SCREEN END OF LINE .


*SELECTION-SCREEN BEGIN OF LINE .
*SELECTION-SCREEN COMMENT 1(30) text-p04 .
*SELECTION-SCREEN POSITION 35 .
PARAMETERS:
  p_wdyn                               TYPE c "RADIOBUTTON
*                                              GROUP objt
                                              NO-DISPLAY .
*SELECTION-SCREEN END OF LINE .
*SELECTION-SCREEN POSITION 20 .
*SELECT-OPTIONS:
*  s_wdyn                               FOR rs38l-name NO INTERVALS .
*SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN END OF BLOCK 001 .



*-----------------------------------------------------------------------
*- SELECT-OPTIONS ------------------------------------------------------
*-----------------------------------------------------------------------
*ELECT-OPTIONS:
* s_xxxxx                    FOR


*-----------------------------------------------------------------------
*- PARAMETERS ----------------------------------------------------------
*-----------------------------------------------------------------------



*-----------------------------------------------------------------------
*- MACROES -------------------------------------------------------------
*-----------------------------------------------------------------------
*DEFINE xxxx .
* WRITE &1 .
*END-OF-DEFINITION .


*-----------------------------------------------------------------------
*- LOAD-OF-PROGRAM -----------------------------------------------------
*-----------------------------------------------------------------------
LOAD-OF-PROGRAM .


*-----------------------------------------------------------------------
*- INITIALIZATION ------------------------------------------------------
*-----------------------------------------------------------------------
INITIALIZATION .

*  my_self = sy-repid .


*-----------------------------------------------------------------------
*- AT SELECTION-SCREEN -------------------------------------------------
*-----------------------------------------------------------------------
*AT SELECTION-SCREEN ON p_objt .



*-----------------------------------------------------------------------
*- START-OF-SELECTION --------------------------------------------------
*-----------------------------------------------------------------------
START-OF-SELECTION .

  PERFORM build_object_list .
  PERFORM build_output .


*-----------------------------------------------------------------------
*- END-OF-SELECTION ----------------------------------------------------
*-----------------------------------------------------------------------
END-OF-SELECTION .

  PERFORM output_as_salv .


*-----------------------------------------------------------------------
*- TOP-OF-PAGE ---------------------------------------------------------
*-----------------------------------------------------------------------
TOP-OF-PAGE .


*-----------------------------------------------------------------------
*- END-OF-PAGE ---------------------------------------------------------
*-----------------------------------------------------------------------
END-OF-PAGE .


*&---------------------------------------------------------------------*
*&      Form  BUILD_OBJECT_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_object_list .

break i025305 .


  SELECT DISTINCT object obj_name tot_changes main_program include_program created_by created_at changed_by changed_at
    FROM zbck_abap_4_hana
    INTO CORRESPONDING FIELDS OF TABLE gt_backup_objects .

  gv_return_code = sy-subrc .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  OUTPUT_AS_SALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM output_as_salv .

DATA:
  lv_column_name                       TYPE lvc_fname ,
  lv_output_length                     TYPE lvc_outlen ,
  lv_is_optimized                      TYPE sap_bool .



  TRY .
    cl_salv_table=>factory(
      IMPORTING r_salv_table = go_salv
      CHANGING  t_table      = gt_output
    ) .

    go_salv_events           = go_salv->get_event( ) .
*    SET HANDLER cl_sagv_events_table->double_click FOR lo_events .
    go_salv_columns          = go_salv->get_columns( ) .
    gt_salv_col_tab          = go_salv_columns->get( ) .
    go_salv_functions        = go_salv->get_functions( ) .
    go_salv_header           ?= go_salv->get_top_of_list( ) .
    go_salv_display_settings = go_salv->get_display_settings( ) .
    go_salv_display_settings->set_list_header( text-h01 ) .
    IF go_salv_header IS INITIAL .
      CREATE OBJECT go_salv_header .
    ENDIF .

* create header
    go_salv_header_label = go_salv_header->create_label( row = 1 column = 1 ).
    go_salv_header_label->set_text( text-h01 ).

*   set the top of list using the header for Online.
    go_salv->set_top_of_list( go_salv_header ).
*
*   set the top of list using the header for Print.
    go_salv->set_top_of_list_print( go_salv_header ).


    LOOP AT gt_salv_col_tab ASSIGNING <column> .

      <column>-r_column->set_visible( if_salv_c_bool_sap=>true ) .

      IF <column>-columnname = 'OBJECT' .
        lv_output_length = <column>-r_column->get_output_length( ) .
        lv_output_length = lv_output_length * 2 .
        <column>-r_column->set_output_length( lv_output_length ) .
      ENDIF .
*      lv_is_optimized = <column>-r_column->is_optimized( ) .

*      <column>-r_column->set_output_length( 40 ) .
      <column>-r_column->set_optimized( if_salv_c_bool_sap=>true ) .

    ENDLOOP .

    go_salv_functions->set_export_spreadsheet( abap_true ) .
    go_salv->display( ) .


  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

ENDFORM .



*&---------------------------------------------------------------------*
*&      Form  BUILD_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_output .

  LOOP AT gt_backup_objects ASSIGNING <backup_object> .
    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
    <output>-object           = <backup_object>-object .
    <output>-obj_name         = <backup_object>-obj_name .
    <output>-main_program     = <backup_object>-main_program .
    <output>-include_program  = <backup_object>-include_program .
    <output>-tot_changes      = <backup_object>-tot_changes .
*    <output>-code             = -code .
*    <output>-status           = -status .
*    <output>-notes            = -notes .
  ENDLOOP .

ENDFORM .
