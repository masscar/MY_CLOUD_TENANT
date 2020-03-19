*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_RESTORE                                         *
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
REPORT z_abap_code_restore             MESSAGE-ID z_abap_4_hana
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
*****SELECTION-SCREEN BEGIN OF BLOCK 001
*****                 WITH FRAME TITLE text-b01 .
*****
*****
*****SELECTION-SCREEN BEGIN OF LINE .
*****SELECTION-SCREEN COMMENT 1(14) text-p02 .
*****SELECTION-SCREEN POSITION 15 .
*****PARAMETERS:
*****  p_repid                              TYPE c RADIOBUTTON
*****                                              GROUP objt .
*****SELECTION-SCREEN POSITION 20 .
*****SELECT-OPTIONS:
*****  s_repid                              FOR rs38m-programm NO INTERVALS .
*****SELECTION-SCREEN END OF LINE .
*****
*****SELECTION-SCREEN BEGIN OF LINE .
*****SELECTION-SCREEN COMMENT 1(14) text-p03 .
*****SELECTION-SCREEN POSITION 15 .
*****PARAMETERS:
*****  p_fugr                               TYPE c RADIOBUTTON
*****                                              GROUP objt .
*****SELECTION-SCREEN POSITION 20 .
*****SELECT-OPTIONS:
*****  s_fugr                               FOR rs38l-name NO INTERVALS .
*****SELECTION-SCREEN END OF LINE .
*****
******SELECTION-SCREEN BEGIN OF LINE .
******SELECTION-SCREEN COMMENT 1(30) text-p01 .
******SELECTION-SCREEN POSITION 35 .
*****PARAMETERS:
*****  p_class                              TYPE c "RADIOBUTTON
******                                              GROUP objt
*****                                              NO-DISPLAY .
******SELECTION-SCREEN END OF LINE .
******SELECTION-SCREEN POSITION 20 .
******SELECT-OPTIONS:
******  s_clas                               FOR rs38l-name NO INTERVALS .
******SELECTION-SCREEN END OF LINE .
*****
*****
******SELECTION-SCREEN BEGIN OF LINE .
******SELECTION-SCREEN COMMENT 1(30) text-p04 .
******SELECTION-SCREEN POSITION 35 .
*****PARAMETERS:
*****  p_wdyn                               TYPE c "RADIOBUTTON
******                                              GROUP objt
*****                                              NO-DISPLAY .
******SELECTION-SCREEN END OF LINE .
******SELECTION-SCREEN POSITION 20 .
******SELECT-OPTIONS:
******  s_wdyn                               FOR rs38l-name NO INTERVALS .
******SELECTION-SCREEN END OF LINE .
*****
*****SELECTION-SCREEN END OF BLOCK 001 .
SELECTION-SCREEN BEGIN OF BLOCK 001
                 WITH FRAME TITLE text-b01 .

PARAMETERS:
  p_objt                               TYPE trObjType
                                            OBLIGATORY .
PARAMETERS:
  p_objn                               TYPE sObj_Name
                                            OBLIGATORY .

SELECTION-SCREEN END OF BLOCK 001 .

SELECTION-SCREEN SKIP 2 .
SELECTION-SCREEN BEGIN OF BLOCK 002
                 WITH FRAME TITLE text-b01 .

SELECTION-SCREEN SKIP 1 .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(30) text-s01 .
SELECTION-SCREEN POSITION 40 .
PARAMETERS:
  p_exec                               TYPE boole_d DEFAULT abap_false .
SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN SKIP 1 .


SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(35) text-s02 .
SELECTION-SCREEN POSITION 40 .
PARAMETERS:
  p_trkorr                             TYPE e070-trkorr
                                            MATCHCODE OBJECT spak_open_trkorr_shlp .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN END OF BLOCK 002 .


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
AT SELECTION-SCREEN ON p_objt .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_objn .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_trkorr .

  CHECK p_trkorr IS NOT INITIAL .

  CLEAR: go_trkorr_entity, gt_trkorr_team, gv_trkorr_type, gv_trkorr_status .
  go_trkorr_entity ?= cl_cts_transport_factory=>get_transport_entity( p_trkorr ) .
  gt_trkorr_team   = go_trkorr_entity->if_cts_transport_entity~get_team( ) .
  gv_trkorr_type   = go_trkorr_entity->if_cts_transport_request~get_type( ) .
  gv_trkorr_status = go_trkorr_entity->if_cts_transport_entity~get_status( ) .

  READ TABLE gt_trkorr_team TRANSPORTING NO FIELDS
    WITH KEY table_line = sy-uname .
  IF sy-subrc = 0 .
*user is involved in selected transport request
  ELSE .
*user is NOT involved in selected transport request
    MESSAGE e002 WITH sy-uname p_trkorr .
  ENDIF .


  IF gv_trkorr_type = 'K' .
* OK, a workbench request
  ELSE .
    MESSAGE e003 WITH p_trkorr .
  ENDIF .


  IF gv_trkorr_status = 'D' .
* OK, still open
  ELSE .
    MESSAGE e004 WITH p_trkorr .
  ENDIF .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN .

  SELECT COUNT( * )
    FROM zbck_abap_4_hana
    INTO gv_count
   WHERE relid         = '00'
     AND object        = p_objt
     AND obj_name      = p_objn .

  IF gv_count IS INITIAL .
    MESSAGE e010 WITH p_objt p_objn .
  ENDIF .


  IF p_exec IS NOT INITIAL AND p_trkorr IS INITIAL .
    MESSAGE w009 .
  ENDIF .


*-----------------------------------------------------------------------
*- START-OF-SELECTION --------------------------------------------------
*-----------------------------------------------------------------------
START-OF-SELECTION .

  PERFORM build_object_list .
  IF gv_return_code IS INITIAL .
    PERFORM restore_source_code .
    IF gv_return_code IS INITIAL .
      PERFORM delete_from_backup_table .
    ENDIF .
  ENDIF .


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

FIELD-SYMBOLS:
  <abap_line>                          LIKE LINE OF gt_abap_lines .
break i025305 .


  gs_backup_key-object   = p_objt .
  gs_backup_key-obj_name = p_objn .
  IMPORT source_code = gt_abap_lines
    FROM DATABASE zbck_abap_4_hana(00)
      ID gs_backup_key
      TO gs_backup_object .

  gv_return_code = sy-subrc .

  APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
  <output>-object          = gs_backup_key-object .
  <output>-obj_name        = gs_backup_key-obj_name .
  <output>-main_program    = gs_backup_object-main_program .
  <output>-include_program = gs_backup_object-include_program .
  <output>-tot_changes     = gs_backup_object-tot_changes .

  IF gv_return_code IS INITIAL .
    <output>-status = ICON_LED_GREEN .
  ELSE .
    <output>-status = ICON_LED_RED .
    <output>-notes  = text-n01 .
  ENDIF .

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

*   information in Bold
    go_salv_header_label = go_salv_header->create_label( row = 1 column = 1 ) .
    go_salv_header_label->set_text( text-h01 ) .

*   set the top of list using the header for Online.
    go_salv->set_top_of_list( go_salv_header ) .
*
*   set the top of list using the header for Print.
    go_salv->set_top_of_list_print( go_salv_header ) .


    LOOP AT gt_salv_col_tab ASSIGNING <column> .
*      <column>-r_column->set_output_length( 40 ) .
*      IF <column>-columnname = 'CARRNAME' OR
      <column>-r_column->set_visible( 'X' ) .
      IF <column>-columnname = 'BACKUP_STATUS' .
        <column>-r_column->set_visible( abap_false ) .
      ENDIF .
    ENDLOOP .

    go_salv_functions->set_export_spreadsheet( abap_true ) .
    go_salv->display( ) .

  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  RESTORE_SOURCE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM restore_source_code .

DATA:
  lv_line_number                       TYPE i .
DATA:
  lv_message                           TYPE string ,
  lv_line                              TYPE i ,
  lv_word                              TYPE string ,
  ls_trdir                             TYPE trdir .


  CASE p_objt .
    WHEN 'PROG' .
      SELECT SINGLE *
        FROM trdir
        INTO ls_trdir
       WHERE name = gs_backup_object-include_program .

      INSERT REPORT gs_backup_object-include_program FROM gt_abap_lines
        DIRECTORY ENTRY ls_trdir .


    WHEN 'FUGR' .
      SELECT SINGLE *
        FROM trdir
        INTO ls_trdir
       WHERE name = gs_backup_object-include_program .

      INSERT REPORT gs_backup_object-include_program FROM gt_abap_lines
        DIRECTORY ENTRY ls_trdir .


    WHEN 'FUNC' .
      SELECT SINGLE *
        FROM trdir
        INTO ls_trdir
       WHERE name = gs_backup_object-include_program .

      INSERT REPORT gs_backup_object-include_program FROM gt_abap_lines
        DIRECTORY ENTRY ls_trdir .


    WHEN Others .
      STOP .

  ENDCASE .


  GENERATE REPORT gs_backup_object-main_program .
  gv_return_code = sy-subrc .

  IF gv_return_code IS INITIAL .
    <output>-status = ICON_LED_GREEN .
  ELSE .
    <output>-status = ICON_LED_RED .
    <output>-notes  = text-n02 .
  ENDIF .


ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  DELETE_FROM_BACKUP_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_from_backup_table .

  DELETE FROM zbck_abap_4_hana
   WHERE relid    = '00'
     AND object   =  gs_backup_key-object
     AND obj_name = gs_backup_key-obj_name .

  IF sy-subrc IS INITIAL .
    <output>-status = ICON_LED_GREEN .
    <output>-notes  = text-n03 .
  ELSE .
    <output>-status = ICON_LED_YELLOW .
    <output>-notes  = text-n04 .
  ENDIF .

ENDFORM .
