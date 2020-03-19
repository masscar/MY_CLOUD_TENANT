*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_SCAN_AND_CHANGE                                 *
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
REPORT z_abap_code_scan_and_change     MESSAGE-ID z_abap_4_hana
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
    fugr_root_name                     TYPE progname ,
    generation_module                  TYPE progname ,
    srcsystem                          TYPE srcsystem ,
  END OF ty_module_list .
TYPES:
  BEGIN OF ty_fugr_list ,
    area                               TYPE rs38l_area ,
    srcsystem                          TYPE srcsystem ,
  END OF ty_fugr_list .
TYPES:
  BEGIN OF ty_func_list ,
    funcname                           TYPE funcname ,
    pname                              TYPE progname ,
    include                            TYPE includenr ,
    srcsystem                          TYPE srcsystem ,
  END OF ty_func_list .
TYPES:
  BEGIN OF ty_clas_list ,
    clsname                            TYPE seoclsname ,
    srcsystem                          TYPE srcsystem ,
  END OF ty_clas_list .


*-----------------------------------------------------------------------
*- TABLES --------------------------------------------------------------
*-----------------------------------------------------------------------
TABLES:
  tdevc ,    "development class
  trdir ,
  rs38m ,    "SE38 help value
  rs38l ,    "SE37 help value
  seoclass , "SE24
  e070 .     "transport request


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
  gt_abap_lines_backup                 TYPE sci_include .

DATA:
  gt_includes                          LIKE gt_abap_lines .
DATA:
  gv_progname_len                      TYPE i .
DATA:
  gv_folder_name                       TYPE salfile-longname ,
  gv_file_name                         TYPE fileExtern ,
  gt_folder_files                      TYPE TABLE OF salfldir .

DATA:
  gv_contains_group_by                 TYPE boole_d ,
  gv_group_by_clause_row               TYPE i ,
  gv_contains_join                     TYPE boole_d ,
  gv_contains_hints                    TYPE boole_d ,
  gv_contains_fae                      TYPE boole_d .
FIELD-SYMBOLS:
  <token_group_by>                     LIKE LINE OF gt_tokens .
DATA:
  go_trkorr_entity                     TYPE REF TO cl_cts_transport_request , "cl_cts_tr_req_decorator_log ,
  gt_trkorr_team                       TYPE cl_cts_transport_request=>ty_users ,
  gv_trkorr_type                       TYPE cl_cts_transport_request=>ty_request_type ,
  gv_trkorr_status                     TYPE cl_cts_transport_request=>ty_status .

DATA:
  gv_source_system                     TYPE srcsystem .

DATA:
  go_abap_compiler                     TYPE REF TO cl_abap_compiler ,
*  gt_refs                              TYPE cl_abap_compiler=>t_all_refs ,
  gv_error                             type sychar01 ,
  gt_errors                            type scr_errors ,
  gv_abort                             type sychar01 .
DATA:
  gt_compiler_results                  TYPE scr_refs ,
  gt_compiler_errors                   TYPE synt_errors .
FIELD-SYMBOLS:
  <compiler_result>                    LIKE LINE OF gt_compiler_results ,
  <compiler_error>                     LIKE LINE OF gt_compiler_errors .
DATA:
  gx_write_source_exception            TYPE REF TO cx_sy_write_src_line_too_long .
DATA:
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
  gv_found                             TYPE i ,
  gv_char_position                     TYPE i ,
  gv_included_object                   TYPE i .
DATA:
  gt_backup_objects                    TYPE TABLE OF zbck_abap_4_hana ,
  gs_backup_object                     TYPE zbck_abap_4_hana ,
  gs_backup_repository                 TYPE zbck_abap_4_hana ,
  BEGIN OF gs_backup_key ,
    object                             TYPE trObjType ,
    obj_name                           TYPE sObj_name ,
  END OF gs_backup_key .

DATA:
  gt_rdir                              TYPE TABLE OF trdir ,
  gt_main_modules                      TYPE TABLE OF ty_module_list ,
  gt_main_clas                         TYPE TABLE OF ty_clas_list , "seoclass ,
  gt_main_fugr                         TYPE TABLE OF ty_fugr_list , "tlibg ,
  gt_main_func                         TYPE TABLE OF ty_func_list , "tfdir
*  gt_modules_name                      TYPE TABLE OF ty_module_list ,
*  gs_module_name                       LIKE LINE OF gt_modules_name ,
  gs_main_module                       TYPE ty_module_list ,
  gs_main_func                         TYPE ty_func_list . "tfdir
FIELD-SYMBOLS:
  <main_fugr>                          LIKE LINE OF gt_main_fugr ,
  <main_func>                          LIKE LINE OF gt_main_func ,
  <main_clas>                          LIKE LINE OF gt_main_clas ,
  <main_module>                        LIKE LINE OF gt_main_modules .
*  <module_name>                        LIKE LINE OF gt_modules_name .
DATA:
  go_sci_inspector                     TYPE REF TO cl_ci_inspection ,
  gt_sci_filters                       TYPE scisrest ,
  gt_sci_objects                       TYPE scit_objs .
FIELD-SYMBOLS:
  <sci_object>                         LIKE LINE OF gt_sci_objects .

DATA:
  gt_versions_list                     TYPE TABLE OF vrsd_old ,
  gt_versions_last                     TYPE TABLE OF vrsd .
FIELD-SYMBOLS:
  <version>                            LIKE LINE OF gt_versions_list .

DATA:
  gr_request_header                    TYPE REF TO trwbo_request_header ,
  gr_transport_objects_t               TYPE REF TO e071_t ,
  gr_transport_object                  TYPE REF TO e071 ,
  gr_trint_messages                    TYPE REF TO ctsgErrMsgs ,
  gv_last_e071_position                TYPE ddposition ,
  gv_not_lockable                      TYPE boole_d .
FIELD-SYMBOLS:
  <transport_object>                   TYPE e071 .
DATA:
  gt_versions_info                     TYPE TABLE OF vrso .
FIELD-SYMBOLS:
  <version_info>                       TYPE vrso .

DATA:
  gv_info_object                       LIKE euobj-id .
DATA:
  gv_current_output_row                TYPE i .
DATA:
  gv_tfill                             TYPE sytfill ,
  gv_tabix                             TYPE sytabix .
DATA:
  gv_progress_percentage               TYPE i ,
  gv_progress_text                     TYPE syucomm .

DATA:
  r_object                             TYPE RANGE OF e071-object .
FIELD-SYMBOLS:
  <r_object>                           LIKE LINE OF r_object .


*-----------------------------------------------------------------------
*- SALV ----------------------------------------------------------------
*-----------------------------------------------------------------------
DATA:
  gt_output                            TYPE TABLE OF zst_abap_scan_code_list .
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
                 WITH FRAME TITLE text-b02 .


SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_korr                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p09 .
SELECTION-SCREEN POSITION 20 .
SELECT-OPTIONS:
  s_korr                               FOR e070-trkorr
                                         MATCHCODE OBJECT spak_open_trkorr_shlp .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_devc                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p06 .
SELECTION-SCREEN POSITION 20 .
SELECT-OPTIONS:
  s_devc                               FOR tdevc-devclass .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_prog                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p02 .
SELECT-OPTIONS:
  s_prog                               FOR rs38m-programm .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_fugr                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p03 .
SELECT-OPTIONS:
  s_fugr                               FOR rs38l-name .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_clas                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p01 .
SELECT-OPTIONS:
  s_clas                               FOR seoclass-clsname .
SELECTION-SCREEN END OF LINE .


SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_wdyn                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p04 .
SELECT-OPTIONS:
  s_wdyn                               FOR rs38l-name .
SELECTION-SCREEN END OF LINE .


SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_reps                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p07 .
SELECT-OPTIONS:
  s_reps                               FOR rs38m-programm .
SELECTION-SCREEN END OF LINE .


SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_func                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p08 .
SELECT-OPTIONS:
  s_func                               FOR rs38l-name .
SELECTION-SCREEN END OF LINE .

SKIP 1 .

SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_sci                                TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p10 .
SELECTION-SCREEN COMMENT 23(10) text-p11 .
PARAMETERS:
  p_scin                               TYPE sci_insp .  "SCI: inspection name
SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 23(10) text-p12 .
PARAMETERS:
  p_sciu                               TYPE sci_user .  "SCI: inspection user
SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 23(10) text-p13 .
PARAMETERS:
  p_sciv                               TYPE sci_vers .  "SCI: inspection version
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN END OF BLOCK 001 .


SELECTION-SCREEN SKIP 2 .
SELECTION-SCREEN BEGIN OF BLOCK 002
                 WITH FRAME TITLE text-b01 .

SELECTION-SCREEN SKIP 1 .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(35) text-s04 .
SELECTION-SCREEN POSITION 40 .
PARAMETERS:
  p_show                               RADIOBUTTON GROUP rb DEFAULT 'X' .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN SKIP 1 .

SELECTION-SCREEN BEGIN OF LINE .
SELECTION-SCREEN COMMENT 1(35) text-s01 .
SELECTION-SCREEN POSITION 40 .
PARAMETERS:
  p_exec                               RADIOBUTTON GROUP rb .
SELECTION-SCREEN END OF LINE .

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
  PERFORM deactivate_parameters .



*-----------------------------------------------------------------------
*- AT SELECTION-SCREEN -------------------------------------------------
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_prog-low .

  gv_info_object = 'PROG' .
  CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
    EXPORTING  object_type          = gv_info_object
               object_name          = s_prog-low
               suppress_selection   = 'X'
    IMPORTING  object_name_selected = s_prog-low
    EXCEPTIONS cancel               = 0 .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_reps-low .

  gv_info_object = 'REPS' .
  CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
    EXPORTING  object_type          = gv_info_object
               object_name          = s_reps-low
               suppress_selection   = 'X'
    IMPORTING  object_name_selected = s_reps-low
    EXCEPTIONS cancel               = 0 .



*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_fugr-low .

  DATA: FIELD LIKE DYNPREAD-FIELDNAME.
  FIELD = 'S_FUGR-LOW'.
  CALL FUNCTION 'RS_HELP_HANDLING'
    EXPORTING  dynpField                 = 'S_FUGR-LOW'
               dynpName                  = sy-dynnr
               object                    = 'FB'
               progname                  = sy-repid
               suppress_selection_screen = abap_true .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_trkorr .

  CHECK p_exec IS NOT INITIAL .
  CHECK p_trkorr IS NOT INITIAL .

  CLEAR: go_trkorr_entity, gt_trkorr_team, gv_trkorr_type, gv_trkorr_status .
  go_trkorr_entity ?= cl_cts_transport_factory=>get_transport_entity( p_trkorr ) .
  gt_trkorr_team   = go_trkorr_entity->if_cts_transport_entity~get_team( ) .
  gv_trkorr_type   = go_trkorr_entity->if_cts_transport_request~get_type( ) .
  gv_trkorr_status = go_trkorr_entity->if_cts_transport_entity~get_status( ) .


  CASE gv_trkorr_type .
    WHEN 'K' .
* OK, a workbench request
      READ TABLE gt_trkorr_team TRANSPORTING NO FIELDS
        WITH KEY table_line = sy-uname .
      IF sy-subrc = 0 .
*    user is involved in selected transport request
      ELSE .
*    user is NOT involved in selected transport request
        MESSAGE e002 WITH sy-uname p_trkorr .
      ENDIF .

    WHEN 'T' .
* OK, transport of copies

    WHEN Others .
      MESSAGE e003 WITH p_trkorr .

  ENDCASE .


  IF gv_trkorr_status = 'D' .
* OK, still open
  ELSE .
    MESSAGE e004 WITH p_trkorr .
  ENDIF .


*------------------------------------------------------------------------------
AT SELECTION-SCREEN ON p_sci .

  IF p_sci IS NOT INITIAL .
    IF p_scin IS INITIAL OR
       p_sciu IS INITIAL OR
       p_sciv IS INITIAL .

      MESSAGE e004 WITH p_trkorr .
    ENDIF .

    CLEAR go_sci_inspector .
    go_sci_inspector = cl_ci_inspection=>get_ref( p_user = p_sciu
                                                  p_name = p_scin
                                                  p_vers = p_sciv
                                                ) .
    IF go_sci_inspector IS BOUND .
    ELSE .
      MESSAGE e004 WITH p_trkorr .
    ENDIF .

  ENDIF .



*------------------------------------------------------------------------------
AT SELECTION-SCREEN .

*DATA:
*  lt_valori                            TYPE TABLE OF vrm_value ,
*  lt_valori_dynpro                     TYPE TABLE OF rsselread .
*FIELD-SYMBOLS:
*  <zt1073_step>                        LIKE LINE OF lt_zt1073_steps ,
*  <valore>                             LIKE LINE OF lt_valori ,
*  <valore_dynpro>                      LIKE LINE OF lt_valori_dynpro .
*
*
*  APPEND INITIAL LINE TO lt_valori_dynpro ASSIGNING <valore_dynpro> .
*  <valore_dynpro>-name       = 'P_STEPID' .
*  <valore_dynpro>-kind       = 'P' .
*  <valore_dynpro>-position   = '' .
*  CALL FUNCTION 'RS_SELECTIONSCREEN_READ'
*    EXPORTING  program           = sy-repid
*               dynnr             = sy-dynnr
*    TABLES     fieldvalues       = lt_valori_dynpro .


  IF p_exec IS NOT INITIAL AND p_trkorr IS INITIAL .
    MESSAGE e009 .
  ENDIF .


*------------------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT .

  PERFORM deactivate_parameters .


*-----------------------------------------------------------------------
*- START-OF-SELECTION --------------------------------------------------
*-----------------------------------------------------------------------
START-OF-SELECTION .


*break-point.
  PERFORM lock_transport .

  PERFORM get_transport_content .

  PERFORM get_selected_objects .


  gv_tfill = LINES( gt_main_modules ) .
  LOOP AT gt_main_modules ASSIGNING <main_module> .

    gv_progress_percentage = ( sy-tabix * 100 ) / gv_tfill .
    gv_progress_text = |{ sy-tabix }/{ gv_tfill }: { <main_module>-pgmid } - { <main_module>-object } - { <main_module>-obj_name }| .
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING  percentage = gv_progress_percentage
                 text       = gv_progress_text .


* log
*    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
*    gv_current_output_row = sy-tabix .
*    <output>-main_program = <main_module>-name .
*    <output>-module_name  = <main_module>-name .

    CLEAR: gt_tokens_main, gt_statements_main, gt_keywords, gt_tokens, gt_statements, gt_levels, gt_structures .

    PERFORM scan_code .
    PERFORM analyze_code . "USING gv_program_name .

** build list of includes (1st level)
*    PERFORM build_includes_list USING gv_main_program abap_true .
*
*
** get module reference
*    IF <main_module>-generation_module IS INITIAL .
*      go_abap_compiler = cl_abap_compiler=>create(
*        EXPORTING p_name             = <main_module>-name "gv_main_program
*                  p_no_package_check = abap_true
*      ) .
*    ELSE .
*      go_abap_compiler = cl_abap_compiler=>create(
*        EXPORTING p_name             = <main_module>-generation_module "gv_main_program
*                  p_no_package_check = abap_true
*      ) .
*    ENDIF .
*
**   get all reference - we're checking if object contains syntax error
*    CLEAR gt_compiler_results .
*    go_abap_compiler->get_all(
*      IMPORTING  p_result = gt_compiler_results
*                 p_errors = gt_compiler_errors
*    ) .
*
*    IF gt_compiler_errors IS NOT INITIAL .
*      READ TABLE gt_compiler_errors ASSIGNING <compiler_error>
*        INDEX 1 .
*      <output>-status = ICON_MESSAGE_ERROR .
*      <output>-notes  = <compiler_error>-message . "text-n02 .
*      CONTINUE .
*    ENDIF .
*    DELETE gt_output INDEX gv_current_output_row .

* scan main program
*    gv_program_name = gv_main_program .
*    PERFORM scan_code .
*    PERFORM analyze_code .
*    gt_tokens_main     = gt_tokens .
*    gt_statements_main = gt_statements .

*    LOOP AT gt_modules_name ASSIGNING <module_name> .
*
*      gv_main_program = <main_module>-name .
*      gv_program_name = <module_name>-name .
*
*      IF <main_module>-object = 'FUGR' .
*        CLEAR gv_function_name .
*        gv_char_position = strlen( gv_program_name ) .
*        gv_char_position = gv_char_position - 3 .
*        gv_function_name = gv_program_name+gv_char_position(03) .
*        IF gv_function_name+00(01) = 'U'  AND  gv_function_name+01(02) CA '0123456789' . "INCLUDE for function module
*          SELECT SINGLE funcname FROM tfdir INTO gv_function_name
*           WHERE pname   = gv_main_program
*             AND include = gv_function_name+01(02) .
*        ELSE .
*          CLEAR gv_function_name .
*        ENDIF .
*      ELSE .
*        CLEAR gv_function_name .
*      ENDIF .
*
*      PERFORM scan_code .
*      PERFORM analyze_code USING gv_program_name .
*
*    ENDLOOP .

  ENDLOOP .

** get main program
*  gv_main_program = cl_ci_objectset=>get_program(
*    EXPORTING  p_pgmid   = gv_pgmid
*               p_objtype = gv_object
*               p_objname = gv_wdyn_name
*  ) .



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


FORM scan_code .

  CLEAR gt_abap_lines .
  READ REPORT <main_module>-name INTO gt_abap_lines .


  CLEAR gt_keywords .
  SCAN ABAP-SOURCE     gt_abap_lines
       KEYWORDS        FROM gt_keywords
       TOKENS          INTO gt_tokens
       STATEMENTS      INTO gt_statements
       LEVELS          INTO gt_levels
       STRUCTURES      INTO gt_structures
       FRAME PROGRAM   FROM <main_module>-name
*       INCLUDE PROGRAM FROM gv_include_name
       MESSAGE         INTO gv_message
       INCLUDE         INTO gv_include
       LINE            INTO gv_line
       WORD            INTO gv_word
       WITH ANALYSIS
*       WITH INCLUDES
       WITH COMMENTS
**       WITH DECLARATIONS
       WITH LIST TOKENIZATION
**       WITH BLOCKS
       WITH PRAGMAS abap_true .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  ANALYZE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM analyze_code .
*  USING p_program_name                 TYPE progname .

break i025305 .

* scan SELECT statements
  gv_current_row_scan = 1 .
  gv_statement_shift = 0 .
  LOOP AT gt_tokens ASSIGNING <token>
     FROM gv_current_row_scan
    WHERE str = 'SELECT' .
    gv_current_row_scan = sy-tabix .

* log
    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
    <output>-main_program = <main_module>-generation_module .
    <output>-module_name  = <main_module>-name .


    gv_contains_join = abap_false .



    READ TABLE gt_statements ASSIGNING <statement>
      WITH KEY from = gv_current_row_scan .
    IF <statement> IS NOT ASSIGNED .
* "SELECT" has been found but it's not a statement, maybe a variable... - we'll skip to next token
      CONTINUE .
    ENDIF .


    ASSIGN <token> TO <select_start_row> .
    READ TABLE gt_tokens ASSIGNING <select_end_row>
      INDEX <statement>-to .

    <output>-line      = <token>-row + gv_statement_shift .
    <output>-status    = ICON_SPACE .
    <output>-notes     = text-n08 .



    LOOP AT gt_tokens ASSIGNING <token_nested>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'TABLE' .
      gv_into_table_token_line = sy-tabix .
    ENDLOOP .
    IF sy-subrc = 0 .
* statement belongs to INTO TABLE category - is it in handled range
    ELSE .
* get statement level - looping statment (i.e. SELECT/ENDSELECT) can be detected here
      READ TABLE gt_structures ASSIGNING <structure>
        INDEX <statement>-struc .
      IF sy-subrc = 0 .
      ELSE .
        <output>-status    = ICON_MESSAGE_WARNING .
        <output>-notes     = text-n09 .
        CONTINUE .
      ENDIF .
      IF <structure>-stmnt_type = 'S' .
* SELECT/ENDSELECT statment
        LOOP AT gt_tokens ASSIGNING <token_nested>
          FROM <statement>-from TO <statement>-to
          WHERE str = 'INTO' .
          gv_into_table_token_line = sy-tabix .
        ENDLOOP .
      ELSE .
        <output>-status    = ICON_MESSAGE_WARNING .
        <output>-notes     = text-n08 .
        CONTINUE .
      ENDIF .
    ENDIF .


    LOOP AT gt_tokens TRANSPORTING NO FIELDS
      FROM <statement>-from TO <statement>-to
      WHERE str = 'JOIN' .
      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
*      <output>-status    = ICON_MESSAGE_WARNING .
*      <output>-notes     = text-n01 .
      gv_contains_join = abap_true .
    ELSE .
      gv_contains_join = abap_false .
    ENDIF .


* SELECT statement contains INTO TABLE clause - check for ORDER BY clause
* get internal tablename
    gv_tablename_token_line = gv_into_table_token_line + 1 .
    READ TABLE gt_tokens ASSIGNING <token_nested>
      INDEX gv_tablename_token_line .
    gv_internal_tablename = <token_nested>-str .


    LOOP AT gt_tokens ASSIGNING <token_nested>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'ORDER' .
    ENDLOOP .
    IF sy-subrc = 0 .
*SELECT statement contains ORDER BY clause - nothing to do
      <output>-status = ICON_LED_INACTIVE .
      <output>-notes  = text-n05 .
    ELSE .

      PERFORM check_for_unhandled_clauses
        USING gv_return_code .

      IF gv_return_code IS INITIAL .
      ELSE .
        CONTINUE .
      ENDIF .


*SELECT...INTO TABLE does not contain ORDER BY clause - will be inserted
* look for db table name
      LOOP AT gt_tokens ASSIGNING <token_nested>
        FROM <statement>-from TO <statement>-to
        WHERE str = 'FROM' .
        gv_tablename_token_line = sy-tabix + 1 .
        EXIT .
      ENDLOOP .

*look for table name
      READ TABLE gt_tokens ASSIGNING <token_nested>
        INDEX gv_tablename_token_line .
      gv_tablename = <token_nested>-str .
      WHILE gv_tablename = '(' .
        gv_tablename_token_line = gv_tablename_token_line + 1 .
        READ TABLE gt_tokens ASSIGNING <token_nested>
          INDEX gv_tablename_token_line .
        gv_tablename = <token_nested>-str .
      ENDWHILE .
*table name found - check if it's really a table or not
      CLEAR gs_table_info .
      CALL FUNCTION 'DD_INT_TABL_GET'
        EXPORTING  TABNAME        = gv_tablename
        IMPORTING  DD02V_A        = gs_table_info
        EXCEPTIONS INTERNAL_ERROR = 1
                   OTHERS         = 2 .

      IF SY-SUBRC <> 0.
*Implement suitable error handling here
      ENDIF.
*      IF gs_table_info-tabclass = 'TRANSP' .
*      ELSE .
*      IF gs_table_info-tabclass = 'VIEW' .
*        <output>-status    = ICON_MESSAGE_WARNING .
*        <output>-notes     = text-n12 .
*        CONTINUE .
*      ENDIF .

      IF <main_module>-generation_module IS INITIAL .
        <output>-status = ICON_CANCEL .
        <output>-notes  = text-n16 .
        CONTINUE .
      ENDIF .

      <output>-status = ICON_SYSTEM_FAVORITES .
      <output>-notes  = text-n09 .

      IF p_exec = abap_true .

        PERFORM insert_into_transport
          USING gv_return_code .

        IF gv_return_code IS INITIAL .
          PERFORM backup_source_code
           TABLES gt_abap_lines
            USING gv_return_code .

          IF gv_return_code IS INITIAL .
            IF gv_contains_fae = abap_false .
              IF gv_contains_join = abap_false .
                IF gs_table_info-tabclass = 'VIEW' .
* get table key from master table - the one specified in FROM clause
                  CLEAR gt_table_columns .
                  CALL FUNCTION 'DD_INT_TABLINFO_GET'
                    EXPORTING  typename       = gv_tablename
*                               LANGU          = SYST-LANGU
                    TABLES     extdfies_tab   = gt_table_columns
                    EXCEPTIONS not_found      = 1
                               internal_error = 2
                               Others         = 3 .

* build ORDER BY clause on primary key
                  gv_current_row_index = 1 .
                  LOOP AT gt_table_columns ASSIGNING <table_column>
                    WHERE keyflag = abap_true .
                    CHECK <table_column>-domname <> 'MANDT'   AND
                          <table_column>-domname <> 'CLIENT' .

                    IF gv_current_row_index = 1 .
                      gs_order_by_statement = |ORDER BY { <table_column>-fieldname }| .
                    ELSE .
                      gs_order_by_statement = |{ gs_order_by_statement } { <table_column>-fieldname }| .
                    ENDIF .
                    gv_current_row_index = gv_current_row_index + 1 .
                  ENDLOOP .
                  gs_order_by_statement = |{ gs_order_by_statement } . "=> AUTOMATIC ADJUSTMENT | .
                ELSE .
                  gs_order_by_statement = |ORDER BY PRIMARY KEY . "=> AUTOMATIC ADJUSTMENT | .
*****              gs_order_by_statement = |SORT { gv_internal_tablename } . "=> AUTOMATIC ADJUSTMENT | .
                ENDIF .
              ELSE .
* get alias used for primary table
                gv_alias_token_line = gv_tablename_token_line + 1 .
                READ TABLE gt_tokens ASSIGNING <alias_of_primary_table>
                  INDEX gv_alias_token_line .
                IF <alias_of_primary_table>-str = 'AS' .
                  gv_alias_token_line = gv_alias_token_line + 1 .
                  READ TABLE gt_tokens ASSIGNING <alias_of_primary_table>
                    INDEX gv_alias_token_line .
                  gv_alias = <alias_of_primary_table>-str .
                ELSE .
                  gv_alias = gv_tablename .
                ENDIF .
*                IF <alias_of_primary_table>-str CO sy-abcde .
*                ELSE .
*                  gv_alias_token_line = gv_alias_token_line + 1 .
*                  READ TABLE gt_tokens ASSIGNING <alias_of_primary_table>
*                    INDEX gv_alias_token_line .
*                ENDIF .

* get table key from master table - the one specified in FROM clause
                CLEAR gt_table_columns .
                CALL FUNCTION 'DD_INT_TABLINFO_GET'
                  EXPORTING  typename       = gv_tablename
*                             LANGU          = SYST-LANGU
                  TABLES     extdfies_tab   = gt_table_columns
                  EXCEPTIONS not_found      = 1
                             internal_error = 2
                             Others         = 3 .

* build ORDER BY clause on primary key
                gv_current_row_index = 1 .
                LOOP AT gt_table_columns ASSIGNING <table_column>
                  WHERE keyflag = abap_true .
                  CHECK <table_column>-domname <> 'MANDT'   AND
                        <table_column>-domname <> 'CLIENT' .

                  IF gv_current_row_index = 1 .
                    gs_order_by_statement = |ORDER BY { gv_alias }~{ <table_column>-fieldname }| .
                  ELSE .
                    gs_order_by_statement = |{ gs_order_by_statement } { gv_alias }~{ <table_column>-fieldname }| .
                  ENDIF .
                  gv_current_row_index = gv_current_row_index + 1 .
                ENDLOOP .
                gs_order_by_statement = |{ gs_order_by_statement } . "=> AUTOMATIC ADJUSTMENT | .
              ENDIF .  "IF gv_contains_join = abap_false .

              PERFORM generate_source_code
               TABLES gt_abap_lines
                USING gv_return_code .

            ELSE .
              PERFORM generate_source_code_for_fae
               TABLES gt_abap_lines
                USING gv_return_code .
            ENDIF .  "IF gv_contains_fae = abap_false


            IF gv_return_code IS INITIAL .
              <output>-status = ICON_LED_GREEN .
              <output>-notes  = text-n07 .
*reload new version to have right statement line numbers
              gv_statement_shift = gv_statement_shift + 1 .
            ELSE .
*error is handled in form "generate_source_code"
            ENDIF .
          ELSE .
            <output>-status = ICON_RED_LIGHT .
            <output>-notes  = text-n04 .
          ENDIF .  "IF gv_return_code IS INITIAL .

        ELSE .
*original version not backed up - changes not applied
          <output>-status = ICON_RED_LIGHT .
          <output>-notes  = text-n06 .
        ENDIF .  "IF gv_return_code IS INITIAL .
      ENDIF .  "IF p_exec = abap_true
    ENDIF .  " look for token ORDER

    UNASSIGN <statement> .
  ENDLOOP .


*  PERFORM build_includes_list USING p_program_name abap_false .


ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  BACKUP_SOURCE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_gv_PROGRAM_NAME  text
*      -->P_LT_ABAP_LINES  text
*----------------------------------------------------------------------*
FORM backup_source_code
 TABLES pt_abap_lines                  TYPE sci_include
  USING p_return_code                  TYPE sysubrc .
                                    "Insert correct name for <...>.

DATA:
  lv_object_type                       TYPE vrsd_old-objtype ,
  lv_object_name                       TYPE vrsd_old-objname .


  CLEAR p_return_code .

  gs_backup_key-object        = <main_module>-object .
  gs_backup_key-obj_name      = <main_module>-obj_name .

  CLEAR gv_found .
  SELECT COUNT( * )
    INTO gv_found
    FROM zbck_abap_4_hana
   WHERE relid         = '00'
     AND object        = gs_backup_key-object
     AND obj_name      = gs_backup_key-obj_name .


  CLEAR gt_abap_lines_backup .
  IF gv_found IS INITIAL .
    CLEAR gs_backup_repository .
    CLEAR gt_versions_list .
    CLEAR gt_versions_last .
    lv_object_type = 'LIMU' . "gs_backup_key-object .
    lv_object_name = <main_module>-name . "gs_backup_key-obj_name .
    CALL FUNCTION 'SVRS_GET_VERSION_DIRECTORY'
      EXPORTING  objName      = lv_object_name
                 objType      = lv_object_type
      TABLES     lVersno_List = gt_versions_last
                 version_list = gt_versions_list
      EXCEPTIONS no_entry     = 1
                 OTHERS       = 2 .
    SORT gt_versions_list BY versno DESCENDING .
    READ TABLE gt_versions_list ASSIGNING <version>
      INDEX 1 .
    IF sy-subrc = 0 .
      gs_backup_repository-trkorr = <version>-korrnum .
    ELSE .
      CLEAR gs_backup_repository-trkorr .
    ENDIF .
    gt_abap_lines_backup[]           = pt_abap_lines[] .
    gs_backup_repository-tot_changes = 0 .
    gs_backup_repository-created_by  = sy-uname .
    gs_backup_repository-created_at  = sy-datum .
  ELSE .
    IMPORT source_code = gt_abap_lines_backup[]
      FROM DATABASE zbck_abap_4_hana(00)
        ID gs_backup_key
        TO gs_backup_repository .
    gs_backup_repository-changed_by = sy-uname .
    gs_backup_repository-changed_at = sy-datum .
  ENDIF .

  gs_backup_repository-tot_changes     = gs_backup_repository-tot_changes + 1 .
  gs_backup_repository-main_program    = <main_module>-generation_module .
  gs_backup_repository-include_program = <main_module>-obj_name .

  MOVE-CORRESPONDING gs_backup_key TO gs_backup_repository .


  EXPORT source_code = gt_abap_lines_backup[]
      TO DATABASE zbck_abap_4_hana(00)
      ID gs_backup_key
    FROM gs_backup_repository .

  p_return_code = sy-subrc .


ENDFORM .

*&---------------------------------------------------------------------*
*&      Form  CHECK_TADIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tadir .

  CHECK gv_obj_name IS NOT INITIAL .

*  SELECT SINGLE srcsystem
*    INTO gv_source_system
*    FROM tadir
*   WHERE pgmid    = gv_pgmid
*     AND object   = gv_object
*     AND obj_name = gv_obj_name .
*
*  IF sy-subrc = 0 .
*    IF gv_source_system = 'SAP' .
*      MESSAGE e005 WITH gv_object gv_obj_name .
*    ELSE .
*      IF gv_source_system = sy-sysid .
*        IF gv_obj_name = sy-repid .
*          MESSAGE e005 WITH gv_object gv_obj_name .
*        ELSE .
*        ENDIF .
*      ELSE .
*        MESSAGE e007 WITH gv_object gv_obj_name sy-sysid .
*      ENDIF .
*    ENDIF .
*  ELSE .
*    MESSAGE e006 WITH gv_object gv_obj_name .
*  ENDIF .

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  INSERT_INTO_TRANSPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_gv_PROGRAM_NAME  text
*      -->P_gv_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM insert_into_transport
  USING p_return_code                  TYPE sysubrc .

DATA:
  lv_func_successfull                  TYPE trparflag .

* check if current object has already been inserted into transport object
  CLEAR gr_transport_object->* .
  gr_transport_object->*-pgmid    = <main_module>-pgmid .
  gr_transport_object->*-object   = <main_module>-object .
  gr_transport_object->*-obj_name = <main_module>-obj_name .

  READ TABLE gr_transport_objects_t->* TRANSPORTING NO FIELDS
    WITH KEY pgmid    = gr_transport_object->*-pgmid
             object   = gr_transport_object->*-object
             obj_name = gr_transport_object->*-obj_name .

  CHECK sy-subrc <> 0 .
  CLEAR p_return_code .

  CLEAR gr_trint_messages->* .
  CALL FUNCTION 'TRINT_LOCK_OBJECT'
    EXPORTING  is_request_header      = gr_request_header->*
               iv_edit                = abap_true
               iv_collect_mode        = abap_true
    IMPORTING  "ES_TLOCK               =
               ev_object_not_lockable = gv_not_lockable
    CHANGING   ct_messages            = gr_trint_messages->*
               cs_object              = gr_transport_object->*
    EXCEPTIONS objLock_failed         = 1
               Others                 = 2 .

  p_return_code = sy-subrc .
  IF p_return_code IS INITIAL   AND
    gv_not_lockable = abap_false  AND
    gr_trint_messages->* IS INITIAL .
    CLEAR p_return_code .

    gv_last_e071_position = gv_last_e071_position + 1 .
    gr_transport_object->*-trkorr = p_trkorr .
    gr_transport_object->*-as4pos = gv_last_e071_position .

    INSERT e071 FROM gr_transport_object->* .
    p_return_code = sy-subrc .
    IF p_return_code IS INITIAL .
      APPEND gr_transport_object->* TO gr_transport_objects_t->* .
    ELSE .
      RETURN .
    ENDIF .

    RETURN .
  ELSE .
    p_return_code = 99 .
  ENDIF .

***
*** CALL FUNCTION 'TR_GET_PGMID_FOR_OBJECT'
*** restituisce il prefisso di un OBJECT: se si passa PROG restituisce R3TR, se REPS allora LIMU
***



*  CALL FUNCTION 'TRINT_CORR_CHECK'
*    EXPORTING  wi_kO200                    = gs_k0200
**               iv_no_standard_editor       = ' '
*               iv_no_show_option           = abap_true
*               iv_dialog                   = abap_false    "'R'
*    IMPORTING  we_order                    = gs_k0200-trkorr
**               we_task                     =
*               we_kO200                    = gs_k0200
*               we_object_appendable        = lv_func_successfull
**               ES_TADIR                    =
*    EXCEPTIONS cancel_edit_error           = 1
*               show_only_error             = 2
*               Others                      = 3 .
*
*  IF sy-subrc <> 0 .
*    p_return_code = sy-subrc .
*    RETURN .
*  ENDIF.
*
*  IF lv_func_successfull = abap_true  AND gs_k0200-trkorr IS INITIAL .
** OK, object will be inserted into selected transport request
*
*  ELSEIF lv_func_successfull = abap_false  AND  gs_k0200-trkorr IS NOT INITIAL .
** OK, object has already been included in returned transport request
*    RETURN .
*
*  ELSE .
*    p_return_code = 99 .
*    RETURN .
*  ENDIF .
*
*
*
*  CALL FUNCTION 'TRINT_CORR_INSERT'
*    EXPORTING  iv_order                    = p_trkorr
*               is_kO200                    = gs_k0200
**               iv_no_standard_editor       = ' '
*               iv_no_show_option           = abap_true
*               iv_dialog                   = abap_false    "'D'
*    IMPORTING  we_order                    = gs_k0200-trkorr
**               we_task                     = gv_task
*               es_kO200                    = gs_k0200
**               es_tadir                    = ls_tadir
*               ev_append                   = lv_func_successfull
*    EXCEPTIONS cancel_edit_error           = 1
*               show_only_error             = 2
*               Others                      = 3 .
*
*  p_return_code = sy-subrc .
*  IF lv_func_successfull = abap_false   OR
*     gs_k0200-trkorr IS INITIAL .
*    p_return_code = 99 .
*  ENDIF .


ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  build_includes_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_includes_list
  USING p_program_name                 TYPE progname
        p_is_main_module               TYPE boole_d .

*DATA:
*  lv_progname_from                     TYPE progname ,
*  lv_progname_to                       TYPE progname .
*
*  CLEAR gt_compiler_results .
*  go_abap_compiler = cl_abap_compiler=>create(
*    EXPORTING p_name             = p_program_name
*              p_no_package_check = abap_true
*  ) .
*
*
*  IF p_is_main_module = abap_true .
*    APPEND INITIAL LINE TO gt_compiler_results ASSIGNING <compiler_result> .
*    <compiler_result>-name = p_program_name .
*    <compiler_result>-tag  = go_abap_compiler->tag_include .
*  ENDIF .
*
*
*  go_abap_compiler->get_all(
*    IMPORTING  p_result = gt_compiler_results
*               p_errors = gt_compiler_errors
*  ) .
*
*
*  LOOP AT gt_compiler_results ASSIGNING <compiler_result>
*    WHERE tag = go_abap_compiler->tag_include .
*
*    SELECT COUNT( * ) FROM trdir INTO gv_found
*      WHERE name = <compiler_result>-name
*        AND cnam = 'SAP' .
*    IF gv_found = 0 .
** not standard object - can be checked
*
*      CLEAR gr_transport_object->* .
*      CLEAR gt_versions_info .
*      gr_transport_object->*-pgmid    = 'LIMU' .
*      gr_transport_object->*-object   = 'REPS' .
*      gr_transport_object->*-obj_name = <compiler_result>-name .
*      CALL FUNCTION 'SVRS_RESOLVE_E071_OBJ'
*        EXPORTING  e071_obj        = gr_transport_object->*
*        TABLES     obj_tab         = gt_versions_info
*        EXCEPTIONS not_versionable = 1
*                   Others          = 2 .
*
*      READ TABLE gt_versions_info ASSIGNING <version_info>
*        INDEX 1 .
*      IF sy-subrc = 0 .
*        gs_module_name-pgmid    = 'LIMU' .
*        gs_module_name-object   = <version_info>-objtype .
*        gs_module_name-obj_name = <version_info>-objname .
*        gs_module_name-name     = <compiler_result>-name .
*      ELSE .
*        gs_module_name-pgmid    = <main_module>-pgmid .
*        gs_module_name-object   = <main_module>-object .
*        gs_module_name-obj_name = <compiler_result>-name .
*        gs_module_name-name     = <compiler_result>-name .
*      ENDIF .
*
*      COLLECT gs_module_name INTO gt_modules_name .
*    ENDIF .
*
*  ENDLOOP .


*  CLEAR gt_abap_lines .
*  READ REPORT p_program_name INTO gt_abap_lines .
*
*  CASE abap_true .
*    WHEN p_class   OR
*         p_wdyn .
*      lv_progname_from = lv_progname_to = gv_main_program .
*      REPLACE '=CP' WITH '=C ' INTO lv_progname_from .
*      REPLACE '=CP' WITH '=CZ' INTO lv_progname_to .
*      SELECT name
*        INTO CORRESPONDING FIELDS OF TABLE gt_modules_name
*        FROM trdir
*       WHERE name BETWEEN lv_progname_from AND lv_progname_to .
*
*    WHEN Others .
*      CLEAR gt_keywords .
*      SCAN ABAP-SOURCE     gt_abap_lines
*           KEYWORDS        FROM gt_keywords
*           TOKENS          INTO gt_tokens
*           STATEMENTS      INTO gt_statements
*           LEVELS          INTO gt_levels
*           STRUCTURES      INTO gt_structures
*           FRAME PROGRAM   FROM gv_program_name
**           INCLUDE PROGRAM FROM gv_include_name
*           MESSAGE         INTO gv_message
*           INCLUDE         INTO gv_include
*           LINE            INTO gv_line
*           WORD            INTO gv_word
*           WITH ANALYSIS
**           WITH INCLUDES
*           WITH COMMENTS
*           WITH DECLARATIONS
*           WITH LIST TOKENIZATION
*           WITH BLOCKS
*           WITH PRAGMAS abap_true .
*
*    LOOP AT gt_tokens ASSIGNING <token>
*      WHERE str = 'INCLUDE' .
*
**      READ TABLE gt_statements ASSIGNING <statement>
**        WITH KEY from = sy-tabix .
**
**      READ TABLE gt_tokens ASSIGNING <token_include>
**        INDEX <statement>-to .
*      gv_included_object = sy-tabix + 1 .
*
*      READ TABLE gt_tokens ASSIGNING <token_include>
*        INDEX gv_included_object .
*      CHECK <token_include>-str <> 'STRUCTURE' .
*
**      gs_module_name-pgmid    = <main_module>-pgmid .
**      gs_module_name-object   = <main_module>-object .
*      gs_module_name-obj_name = <token_include>-str .
*      gs_module_name-name     = <token_include>-str .
*      CLEAR gv_found .
**      SELECT COUNT( * ) FROM tadir INTO gv_found
**        WHERE pgmid    = 'R3TR'
**          AND object   = 'PROG'
**          AND obj_name = gs_module_name-name
**          AND srcsystem = 'SAP' .
*      SELECT COUNT( * ) FROM trdir INTO gv_found
*        WHERE name = gs_module_name-name
*          AND cnam = 'SAP' .
*      IF gv_found = 0 .
**   not standard object - can be checked
*        CLEAR gs_tadir .
**        CALL FUNCTION 'TR_TRANSFORM_TRDIR_TO_TADIR'
**          EXPORTING  iv_trdir_name       = gs_module_name-name
**          IMPORTING  es_tadir_keys       = gs_tadir
**          EXCEPTIONS invalid_name_syntax = 1
**                     Others              = 2 .
**
**        IF sy-subrc = 0 .
**          gs_module_name-pgmid    = gs_tadir-pgmid .
**          gs_module_name-object   = gs_tadir-object .
**          gs_module_name-obj_name = gs_tadir-obj_name .
**        ELSE .
**          gs_module_name-pgmid    = <main_module>-pgmid .
**          gs_module_name-object   = <main_module>-object .
**          gs_module_name-obj_name = gs_module_name-name .
**        ENDIF .
*        CLEAR gr_transport_object->* .
*        CLEAR gt_versions_info .
*        gr_transport_object->*-pgmid    = 'LIMU' .
*        gr_transport_object->*-object   = 'REPS' .
*        gr_transport_object->*-obj_name = gs_module_name-name .
*        CALL FUNCTION 'SVRS_RESOLVE_E071_OBJ'
*          EXPORTING  e071_obj              = gr_transport_object->*
*          TABLES     obj_tab               = gt_versions_info
*          EXCEPTIONS not_versionable       = 1
*                     Others                = 2 .
*
*        READ TABLE gt_versions_info ASSIGNING <version_info>
*          INDEX 1 .
*        IF sy-subrc = 0 .
*          gs_module_name-pgmid    = 'LIMU' .
*          gs_module_name-object   = <version_info>-objtype .
*          gs_module_name-obj_name = <version_info>-objname .
*        ELSE .
*          gs_module_name-pgmid    = <main_module>-pgmid .
*          gs_module_name-object   = <main_module>-object .
*          gs_module_name-obj_name = gs_module_name-name .
*        ENDIF .
*
*        COLLECT gs_module_name INTO gt_modules_name .
*      ENDIF .
*
*    ENDLOOP .
*    DELETE gt_modules_name WHERE name = 'METHODS' .
*    DELETE gt_modules_name WHERE object = 'TABL' .
*
*  ENDCASE .



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

* create header
    go_salv_header_label = go_salv_header->create_label( row = 1 column = 1 ).
    go_salv_header_label->set_text( text-h01 ).

*   set the top of list using the header for Online.
    go_salv->set_top_of_list( go_salv_header ).
*
*   set the top of list using the header for Print.
    go_salv->set_top_of_list_print( go_salv_header ).



    LOOP AT gt_salv_col_tab ASSIGNING <column> .
      <column>-r_column->set_visible( <column>-r_column->if_salv_c_bool_sap~true ) .

      CASE <column>-columnname .
        WHEN 'STATUS' .
          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .

        WHEN 'NOTES' .
          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .
*        <column>-r_column->set_output_length( 40 ) .
        WHEN Others .
      ENDCASE .
    ENDLOOP .

    go_salv_functions->set_export_spreadsheet( abap_true ) .
    go_salv->display( ) .


  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  GENERATE_SOURCE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ABAP_LINES  text
*      -->P_GV_PROGRAM_NAME  text
*      -->P_GV_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM generate_source_code
  TABLES  pt_abap_lines                TYPE sci_include
  USING   pv_return_code               TYPE sysubrc .


DATA:
  lo_function_editor                   TYPE REF TO cl_fb_function_editor .
DATA:
  lv_line_number                       TYPE i .
DATA:
  lv_message                           TYPE string ,
  lv_line                              TYPE i ,
  lv_word                              TYPE string ,
  ls_trdir                             TYPE trdir .
FIELD-SYMBOLS:
  <_token>                             LIKE LINE OF gt_tokens .



  gt_abap_lines_backup[] = gt_abap_lines[] .
  CLEAR pv_return_code .


  SELECT SINGLE * FROM trdir INTO ls_trdir
    WHERE name = <main_module>-name .



  IF gv_contains_group_by = abap_true .
* if GROUP BY clause is used than ORDER BY has to precede GROUP BY instead of been placed at the end of the statement
    gv_select_end_statement = gv_group_by_clause_row + gv_statement_shift .
    REPLACE ALL OCCURRENCES OF '.' IN gs_order_by_statement  WITH ' ' .

  ELSE .
* read last line of SELECT statement, for removing '.'
    gv_select_end_statement = <select_end_row>-row + gv_statement_shift .
    READ TABLE gt_abap_lines ASSIGNING <abap_line>
      INDEX gv_select_end_statement .

    gv_end_statement_length = STRLEN( <abap_line> ) .
    gv_end_statement_character = <select_end_row>-col +   "position of last token in statement
                                 <select_end_row>-len1 .  "length of last token
    WHILE gv_end_statement_character < gv_end_statement_length .

      gv_end_statement_offset = gv_end_statement_character - 1 .
      IF <abap_line>+gv_end_statement_offset(01) = '"' .
        EXIT .
      ENDIF .

      REPLACE '.' IN
        SECTION OFFSET gv_end_statement_character LENGTH 1 OF <abap_line>
        WITH space
        IN CHARACTER MODE .
*      IF <abap_line>+gv_end_statement_character(01) = '.' .
*        <abap_line>+gv_end_statement_character(01) = ' ' .
*      ENDIF .

      gv_end_statement_character = gv_end_statement_character + 1 .
      gv_end_statement_length = STRLEN( <abap_line> ) .
    ENDWHILE .
*    REPLACE ALL OCCURRENCES OF '.' IN <abap_line> WITH ' ' .
    gv_select_end_statement = <select_end_row>-row + gv_statement_shift + 1 .
  ENDIF .

* insert ORDER BY clause
  CLEAR gt_order_by_lines .
  SPLIT gs_order_by_statement
     AT ' '
   INTO TABLE gt_order_by_lines .

  INSERT gs_order_by_statement INTO gt_abap_lines INDEX gv_select_end_statement .


* replace code in ABAP repository
  TRY .
    INSERT REPORT <main_module>-name FROM gt_abap_lines
      DIRECTORY ENTRY ls_trdir .

  CATCH cx_sy_write_src_line_too_long INTO gx_write_source_exception .
    <output>-status = ICON_LED_RED .
    CLEAR <output>-notes .
    <output>-notes  = gx_write_source_exception->get_longtext( ) .
    IF <output>-notes IS INITIAL .
      <output>-notes  = gx_write_source_exception->get_text( ) .
    ENDIF .
    EXIT .
  ENDTRY .

  GENERATE REPORT <main_module>-generation_module
    MESSAGE lv_message
    LINE    lv_line
    WORD    lv_word .

  pv_return_code = sy-subrc .
  IF pv_return_code = 0 .
* OK, we can proceed
  ELSE .
*restore previous version
    gt_abap_lines[] = gt_abap_lines_backup[] .

    INSERT REPORT <main_module>-name FROM gt_abap_lines
      DIRECTORY ENTRY ls_trdir .
    GENERATE REPORT <main_module>-generation_module .

    <output>-status = ICON_LED_RED .
    <output>-notes  = |LINE { <select_end_row>-row }: { lv_message }|.

    EXIT .
  ENDIF .


ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  GENERATE_SOURCE_CODE_FOR_FAE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ABAP_LINES  text
*      -->P_GV_PROGRAM_NAME  text
*      -->P_GV_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM generate_source_code_for_fae
  TABLES  pt_abap_lines                TYPE sci_include
  USING   pv_return_code               TYPE sysubrc .


DATA:
  lo_function_editor                   TYPE REF TO cl_fb_function_editor .
DATA:
  lv_line_number                       TYPE i .
DATA:
  lv_message                           TYPE string ,
  lv_line                              TYPE i ,
  lv_word                              TYPE string ,
  ls_trdir                             TYPE trdir .
FIELD-SYMBOLS:
  <_token>                             LIKE LINE OF gt_tokens .



  gt_abap_lines_backup[] = gt_abap_lines[] .
  CLEAR pv_return_code .


  SELECT SINGLE * FROM trdir INTO ls_trdir
    WHERE name = <main_module>-name .


* get current statement
  gv_select_end_statement = <select_end_row>-row + gv_statement_shift .
  READ TABLE gt_abap_lines ASSIGNING <abap_line>
    INDEX gv_select_end_statement .


* insert SORT statement
  gs_order_by_statement = |SORT { gv_internal_tablename } . "=> AUTOMATIC ADJUSTMENT | .

  INSERT gs_order_by_statement INTO gt_abap_lines INDEX gv_select_end_statement .


* replace code in ABAP repository
  TRY .
    INSERT REPORT <main_module>-name FROM gt_abap_lines
      DIRECTORY ENTRY ls_trdir .

  CATCH cx_sy_write_src_line_too_long INTO gx_write_source_exception .
    <output>-status = ICON_LED_RED .
    CLEAR <output>-notes .
    <output>-notes  = gx_write_source_exception->get_longtext( ) .
    IF <output>-notes IS INITIAL .
      <output>-notes  = gx_write_source_exception->get_text( ) .
    ENDIF .
    EXIT .
  ENDTRY .

  GENERATE REPORT <main_module>-generation_module
    MESSAGE lv_message
    LINE    lv_line
    WORD    lv_word .

  pv_return_code = sy-subrc .
  IF pv_return_code = 0 .
* OK, we can proceed
  ELSE .
*restore previous version
    gt_abap_lines[] = gt_abap_lines_backup[] .

    INSERT REPORT <main_module>-name FROM gt_abap_lines
      DIRECTORY ENTRY ls_trdir .
    GENERATE REPORT <main_module>-generation_module .

    <output>-status = ICON_LED_RED .
    <output>-notes  = |LINE { <select_end_row>-row }: { lv_message }|.

    EXIT .
  ENDIF .


ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  GET_SELECTED_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_objects .


  IF p_korr = abap_true .
    CLEAR r_object .
    APPEND INITIAL LINE TO r_object ASSIGNING <r_object> .
    <r_object>-sign = 'I' . <r_object>-option = 'EQ' . <r_object>-low = 'FUNC' .
    APPEND INITIAL LINE TO r_object ASSIGNING <r_object> .
    <r_object>-sign = 'I' . <r_object>-option = 'EQ' . <r_object>-low = 'FUGR' .
    APPEND INITIAL LINE TO r_object ASSIGNING <r_object> .
    <r_object>-sign = 'I' . <r_object>-option = 'EQ' . <r_object>-low = 'PROG' .
    APPEND INITIAL LINE TO r_object ASSIGNING <r_object> .
    <r_object>-sign = 'I' . <r_object>-option = 'EQ' . <r_object>-low = 'REPS' .

    SELECT pgmid object obj_name
      APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
      FROM e071
     WHERE trkorr IN s_korr
       AND object IN r_object . " IN ( 'REPS', 'PROG', 'FUGR', 'FUNC' ) .

    LOOP AT gt_main_modules ASSIGNING <main_module> .

      gv_trobj_name = <main_module>-obj_name .
      <main_module>-generation_module = cl_ci_objectset=>get_program(
                                                     p_pgmid   = <main_module>-pgmid
                                                     p_objtype = <main_module>-object
                                                     p_objname = gv_trobj_name
                                        ) .

      CASE <main_module>-object .
        WHEN 'FUNC' .
          SELECT SINGLE tfdir~funcname tfdir~pname tfdir~include INTO CORRESPONDING FIELDS OF gs_main_func
            FROM tfdir AS tfdir
            WHERE funcname = <main_module>-obj_name .
          ASSIGN gs_main_func TO <main_func> .
          <main_module>-name              = |{ <main_func>-pname+03 }U{ <main_func>-include }| .
          <main_module>-fugr_root_name    = <main_func>-pname+04 .

        WHEN 'FUGR' .
          <main_module>-name              = <main_module>-generation_module .
          <main_module>-fugr_root_name    = <main_module>-name+04 .

        WHEN 'REPS' .
          <main_module>-name              = <main_module>-obj_name .

        WHEN 'PROG' .
          <main_module>-name              = <main_module>-obj_name .

      ENDCASE .
    ENDLOOP .

  ENDIF .


  IF p_devc = abap_true .
    SELECT tadir~pgmid tadir~object tadir~obj_name trdir~name tadir~srcsystem APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
      FROM tadir AS tadir
     INNER JOIN trdir AS trdir
        ON trdir~name  = tadir~obj_name
*           tadir~srcsystem = sy-sysid
     WHERE tadir~pgmid     = 'R3TR'
       AND ( tadir~object  = 'PROG'  OR  tadir~object  = 'REPS'  OR  tadir~object  = 'FUGR' )
       AND tadir~devclass IN s_devc .
    DELETE gt_main_modules WHERE srcsystem = 'SAP' .

    SORT gt_main_modules .
    DELETE ADJACENT DUPLICATES FROM gt_main_modules .

    LOOP AT gt_main_modules ASSIGNING <main_module>
      WHERE generation_module IS INITIAL .
      gv_trobj_name = <main_module>-obj_name .
      <main_module>-generation_module = cl_ci_objectset=>get_program(
                                                     p_pgmid   = <main_module>-pgmid
                                                     p_objtype = <main_module>-object
                                                     p_objname = gv_trobj_name
                                        ) .
    ENDLOOP .
  ENDIF . "P_DEVC checkbox selected


  IF p_prog = abap_true .
*tab. d010inc - relazione main-includes
    SELECT tadir~pgmid tadir~object tadir~obj_name trdir~name tadir~srcsystem APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
      FROM trdir AS trdir
     INNER JOIN tadir AS tadir
        ON tadir~pgmid     = 'R3TR'      AND
           tadir~object    = 'PROG'      AND
           tadir~obj_name  = trdir~name  "AND
*           tadir~srcsystem = sy-sysid
     WHERE trdir~name IN s_prog .
    DELETE gt_main_modules WHERE srcsystem = 'SAP' .

    SORT gt_main_modules .
    DELETE ADJACENT DUPLICATES FROM gt_main_modules .

    LOOP AT gt_main_modules ASSIGNING <main_module>
      WHERE generation_module IS INITIAL .
      gv_trobj_name = <main_module>-obj_name .
      <main_module>-generation_module = cl_ci_objectset=>get_program(
                                                     p_pgmid   = 'R3TR'
                                                     p_objtype = 'PROG'
                                                     p_objname = gv_trobj_name
                                        ) .
    ENDLOOP .
  ENDIF . "P_PROG checkbox selected


  IF p_fugr = abap_true .

    SELECT tlibg~area tadir~srcsystem INTO CORRESPONDING FIELDS OF TABLE gt_main_fugr
      FROM tlibg AS tlibg
     INNER JOIN tadir AS tadir
        ON tadir~pgmid     = 'R3TR'      AND
           tadir~object    = 'FUGR'      AND
           tadir~obj_name  = tlibg~area  AND
           tadir~srcsystem <> 'SAP'
     WHERE tlibg~area IN s_fugr .
    DELETE gt_main_fugr WHERE srcsystem = 'SAP' .

    SORT gt_main_fugr .
    DELETE ADJACENT DUPLICATES FROM gt_main_fugr .

    LOOP AT gt_main_fugr ASSIGNING <main_fugr> .

      gv_trobj_name = <main_fugr>-area .
      APPEND INITIAL LINE TO gt_main_modules ASSIGNING <main_module> .
      <main_module>-pgmid             = 'R3TR' .
      <main_module>-object            = 'FUGR' .
      <main_module>-obj_name          = <main_fugr>-area .
      <main_module>-name              = cl_ci_objectset=>get_program(
                                                  p_pgmid   = 'R3TR'
                                                  p_objtype = 'FUGR'
                                                  p_objname = gv_trobj_name
                                     ) .
      <main_module>-fugr_root_name    = <main_module>-name+03 .
      <main_module>-generation_module = <main_module>-name .
      <main_module>-srcsystem         = <main_fugr>-srcsystem .

    ENDLOOP .
  ENDIF .  "P_FUGR checkbox selected


  IF p_clas = abap_true .

    SELECT seoclass~clsname tadir~srcsystem INTO CORRESPONDING FIELDS OF TABLE gt_main_clas
      FROM seoclass AS seoclass
     INNER JOIN tadir AS tadir
        ON tadir~pgmid     = 'R3TR'            AND
           tadir~object    = 'CLAS'            AND
           tadir~obj_name  = seoclass~clsname  AND
           tadir~srcsystem <> 'SAP'
      WHERE clsname IN s_clas
      ORDER BY clsname .

    LOOP AT gt_main_clas ASSIGNING <main_clas> .
      gv_trobj_name = <main_clas>-clsname .
      APPEND INITIAL LINE TO gt_main_modules ASSIGNING <main_module> .
      <main_module>-pgmid             = 'R3TR' .
      <main_module>-object            = 'CLAS' .
      <main_module>-obj_name          = <main_clas>-clsname .
      <main_module>-name              = cl_ci_objectset=>get_program(
                                                     p_pgmid   = 'R3TR'
                                                     p_objtype = 'CLAS'
                                                     p_objname = gv_trobj_name
                                        ) .
      <main_module>-fugr_root_name    = '' .
      <main_module>-generation_module = <main_module>-name .
      <main_module>-srcsystem         = <main_clas>-srcsystem .
    ENDLOOP .

  ENDIF .  "P_CLAS checkbox selected


  IF p_reps = abap_true .
*tab. d010inc - relazione main-includes
    SELECT tadir~pgmid tadir~object tadir~obj_name trdir~name tadir~srcsystem APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
      FROM trdir AS trdir
     INNER JOIN tadir AS tadir
        ON tadir~pgmid     = 'LIMU'      AND
           tadir~object    = 'REPS'      AND
           tadir~obj_name  = trdir~name  "AND
*           tadir~srcsystem = sy-sysid
     WHERE trdir~name IN s_reps .
    DELETE gt_main_modules WHERE srcsystem = 'SAP' .

    SORT gt_main_modules .
    DELETE ADJACENT DUPLICATES FROM gt_main_modules .

    LOOP AT gt_main_modules ASSIGNING <main_module>
      WHERE generation_module IS INITIAL .
      gv_trobj_name = <main_module>-obj_name .
      <main_module>-generation_module = cl_ci_objectset=>get_program(
                                                     p_pgmid   = 'LIMU'
                                                     p_objtype = 'REPS'
                                                     p_objname = gv_trobj_name
                                        ) .
    ENDLOOP .
  ENDIF . "P_REPS checkbox selected


  IF p_func = abap_true .
*    SELECT tlibg~area tadir~srcsystem INTO CORRESPONDING FIELDS OF TABLE gt_main_fugr
    SELECT tfdir~funcname tfdir~pname tfdir~include APPENDING CORRESPONDING FIELDS OF TABLE gt_main_func
      FROM tfdir AS tfdir
*     INNER JOIN tadir AS tadir
*        ON tadir~pgmid     = 'R3TR'       AND
*           tadir~object    = 'FUGR'       AND
*           tadir~obj_name  = tfdir~pname  AND
*           tadir~srcsystem <> 'SAP'
     WHERE tfdir~funcname IN s_func .
*    DELETE gt_main_func WHERE srcsystem = 'SAP' .

    SORT gt_main_func .
    DELETE ADJACENT DUPLICATES FROM gt_main_func .
    LOOP AT gt_main_func ASSIGNING <main_func> .
      APPEND INITIAL LINE TO gt_main_modules ASSIGNING <main_module> .
      gv_tabix = sy-tabix .
      <main_module>-pgmid             = 'LIMU' .
      <main_module>-object            = 'FUNC' .
      <main_module>-obj_name          = <main_func>-funcname .
      <main_module>-name              = |{ <main_func>-pname+03 }U{ <main_func>-include }| .
      <main_module>-fugr_root_name    = <main_func>-pname+04 .
      <main_module>-generation_module = <main_func>-pname .

      CLEAR gv_found .
      SELECT COUNT( * )
        INTO gv_found
        FROM tlibg
       WHERE area = <main_module>-fugr_root_name
         AND uname <> 'SAP' .
      IF gv_found > 0 .
* it's NOT an SAP object - can be selected
      ELSE .
        DELETE gt_main_modules INDEX gv_tabix .
      ENDIF .

    ENDLOOP .

  ENDIF . "P_FUNC checkbox selected


  IF p_sci = abap_true .
    CLEAR:
      gt_sci_filters ,
      gt_sci_objects .
    go_sci_inspector->get_err_objects(
      EXPORTING  p_rest    = gt_sci_filters
      IMPORTING  p_errobjs = gt_sci_objects
    ) .
*OBJT OBJNAME                                  RESPONSIBL   DEVCLASS                       PRGNAME                                  PARAMS
*
*CLAS ZCL_IM_PM_CROS_RESTRICT_PO               AE11744      ZIBM_RO                        ZCL_IM_PM_CROS_RESTRICT_PO====CP                  0 Entries
*FUGR ZFGFI_FIE093_RDP                         AEIV080      ZCFI_FIE093                    SAPLZFGFI_FIE093_RDP                              0 Entries
*FUGR ZFGFI_FIE093_RDP                         AEIV080      ZCFI_FIE093                    SAPLZFGFI_FIE093_RDP                              0 Entries
*FUGR ZFGFI_FIE093_RDP                         AEIV080      ZCFI_FIE093                    SAPLZFGFI_FIE093_RDP                              0 Entries
*FUGR ZFGFI_FIE093_RDP                         AEIV080      ZCFI_FIE093                    SAPLZFGFI_FIE093_RDP                              0 Entries
*FUGR ZFG_STAMPE_SAP                           AE11744      ZIBM_RO                        SAPLZFG_STAMPE_SAP                                0 Entries
*FUGR ZFG_STAMPE_SAP                           AE11744      ZIBM_RO                        SAPLZFG_STAMPE_SAP                                0 Entries
*FUGR ZFGPM_CODIFY_TPLNR_AUI                   AE11744      ZIBM_RO                        SAPLZFGPM_CODIFY_TPLNR_AUI                        0 Entries
*FUGR ZFGPM_CODIFY_TPLNR_AUI                   AE11744      ZIBM_RO                        SAPLZFGPM_CODIFY_TPLNR_AUI                        0 Entries
  ENDIF .


  DELETE gt_main_modules WHERE name = sy-repid .


* add INCLUDE modules for main objects (FUGR, PROG, ...)
  LOOP AT gt_main_modules ASSIGNING <main_module>
    WHERE object = 'PROG'
       OR object = 'FUGR' .

    gv_tabix = sy-tabix .

    PERFORM add_included_modules .

  ENDLOOP .

ENDFORM .



FORM TEST_JOIN .

*DATA: BEGIN OF t_netmat OCCURS 1,
*      posid LIKE prps-posid,   "Elemento WBS
*      obwbs LIKE prps-objnr,   "Numero oggetto WBS
*      aufnr LIKE aufk-aufnr,   "Network
*      gstrp LIKE afko-gstrp,   "Data inizio cardine
*      autyp LIKE aufk-autyp,   "Categoria ordine
*      obord LIKE aufk-objnr,   "Numero oggetto
*      werks LIKE aufk-werks,   "Divisione
*      vornr LIKE afvc-vornr,   "Operazione
*      steus LIKE afvc-steus,   "Chiave di controllo operazione
*      ltxa1 LIKE afvc-ltxa1,   "Testo breve dell'operazione
*      meinh LIKE afvv-meinh,   "Unità di misura operazione
*      dauno LIKE afvv-dauno,   "Durata standard dell'operazione
*      arbei LIKE afvv-arbei,   "Lavoro relativo all'operazione
*      mgvrg LIKE afvv-mgvrg,   "Quantità operazione
*      matnr LIKE resb-matnr,   "Materiale
*      maktx LIKE makt-maktx,   "Descrizione del materiale
*      meins LIKE resb-meins,   "UM quantitativo materiale
*      bdmng LIKE resb-bdmng,   "Quantitativo fabbisogno
*      shkzg LIKE resb-shkzg,   "Dare/Avere
*      potx1 LIKE resb-potx1,   "Testo posizione distinta base (riga 1)
*      gpreis LIKE resb-gpreis, "Prezzo in divisa componente
*      stprs LIKE mbew-stprs,   "Prezzo standard
*      aufpl LIKE afko-aufpl,
*      objnr LIKE resb-objnr,  "Numero Oggetto
*      mrovdc(09),"Macro voce di costo
*      saknr LIKE resb-saknr.  "Conto Co.Ge.
*DATA: END OF t_netmat.
*
*DATA: BEGIN OF t_net OCCURS 1,
*      pspid LIKE proj-pspid,  "Cod. Progetto
*      posid LIKE prps-posid,  "Elemento WBS
*      obwbs LIKE prps-objnr,  "Numero oggetto WBS
*      aufnr LIKE aufk-aufnr,  "Network
*      auart LIKE aufk-auart,  "Tipo ordine
*      fsavd LIKE afvv-fsavd,  "Data inizio al più presto operazione
*      gstrp LIKE afko-gstrp,  "Data inizio cardine
*      autyp LIKE aufk-autyp,  "Categoria ordine
*      obord LIKE aufk-objnr,  "Numero oggetto
*      vornr LIKE afvc-vornr,  "Operazione
*      steus LIKE afvc-steus,  "Chiave di controllo operazione
*      ltxa1 LIKE afvc-ltxa1,   "Testo breve dell'operazione
*      meinh LIKE afvv-meinh,   "Unità di misura operazione
*      dauno LIKE afvv-dauno,   "Durata standard dell'operazione
*      arbei LIKE afvv-arbei,   "Lavoro relativo all'operazione
*      mgvrg LIKE afvv-mgvrg,   "Quantità operazione
*      usr03 LIKE afvu-usr03,   "Quantità operazione
*      aufpl LIKE afko-aufpl,
*      kokrs LIKE crco-kokrs,  "Controlling area
*      kostl LIKE crco-kostl,  "Centro di costo
*      lstar LIKE crco-lstar,  "Tipo di attività
*      begda LIKE crco-begda,  "Data Inizio
*      endda LIKE crco-endda,  "Data Fine
*      larnt LIKE afvc-larnt,
*      mrovdc(09),             "Macro voce di costo
*      vksta LIKE cokl-vksta.  " Voce di Costo
*DATA: END OF t_net.
*
*    SELECT p~posid r~matnr f~gstrp u~aufnr u~autyp u~objnr u~werks c~vornr
*          r~meins r~bdmng r~shkzg r~potx1 r~objnr r~gpreis c~ltxa1 c~steus
*          v~meinh v~dauno v~arbei v~mgvrg f~aufpl r~saknr
*                                  FROM ( proj AS j INNER JOIN prps AS p ON
*                                                       p~psphi = j~pspnr )
*                                                   INNER JOIN afko AS f ON
*                                                         f~pronr = j~pspnr
*                                                   INNER JOIN aufk AS u ON
*                                                         u~aufnr = f~aufnr
*                                                   INNER JOIN resb AS r ON
*                                                         r~rsnum = f~rsnum
*                                                   INNER JOIN afvc AS c ON
*                                                     c~aufpl = r~aufpl AND
*                                                     c~aplzl = r~aplzl AND
*                                                         c~projn = p~pspnr
*                                                   INNER JOIN afvv AS v ON
*                                                     v~aufpl = c~aufpl AND
*                                                         v~aplzl = c~aplzl
*                               INTO CORRESPONDING FIELDS OF TABLE t_netmat
**                                                  FOR ALL ENTRIES IN t_net
**                                           WHERE j~pspid = t_net-pspid AND
**                                                 f~aufnr = t_net-aufnr AND
***                                                 k~spras = 'I' AND
*       where                                            u~loekz NE 'X' AND
*                                                            c~loekz NE 'X'
*ORDER BY J~PSPNR  J~PSPID . "=> AUTOMATIC ADJUSTMENT

*data : begin of t_ekpo occurs 0 ,
**       ebeln like ekpo-ebeln,
*       ebeln like ekpo-ebeln,
**       flag,
*       loekz like ekpo-loekz,
**       var1,
**       var2,
**       var3,
*       end of t_ekpo.
*data contratto like ekpo-ebeln .
*  select  ebeln loekz   from ekpo
*     into corresponding fields of table t_ekpo   " k attivo
*                            where ebeln = contratto
*order by primary key.

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  GET_TRANSPORT_CONTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_transport_content .


  CREATE DATA gr_request_header .
  CREATE DATA gr_transport_objects_t .
  CREATE DATA gr_transport_object .
  CREATE DATA gr_trint_messages .

  CHECK p_trkorr IS NOT INITIAL .


  gr_request_header->*-trkorr =  p_trkorr .
  CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
    EXPORTING  iv_read_e070           = abap_true
*               IV_READ_E07T           = ' '
               iv_read_e070c          = abap_true
               iv_read_e070m          = abap_true
*    IMPORTING  EV_E07T_DOESNT_EXIST   =
*               EV_E070C_DOESNT_EXIST  =
*               EV_E070M_DOESNT_EXIST  =
    CHANGING   cs_request             = gr_request_header->*
    EXCEPTIONS empty_trkorr           = 1
               not_exist_e070         = 2
               Others                 = 3 .



  CALL FUNCTION 'TR_READ_COMM'
    EXPORTING  wi_trkorr             = gr_request_header->*-trkorr
               wi_dialog             = abap_false
               wi_langu              = sy-langu
               wi_sel_e070           = abap_false
               wi_sel_e071           = abap_true
*               WI_SEL_E071K          = ' '
*               IV_SEL_E071KF         = ' '
*               WI_SEL_E07T           = ' '
*               WI_SEL_E070C          = ' '
*               IV_SEL_E070M          = ' '
*               IV_SEL_E070A          = ' '
*    IMPORTING  WE_E070               =
*               WE_E07T               =
*               WE_E070C              =
*               ES_E070M              =
*               WE_E07T_DOESNT_EXIST  =
*               WE_E070C_DOESNT_EXIST =
*               EV_E070M_DOESNT_EXIST =
*               WT_E071K_STR          =
    TABLES     wt_e071               = gr_transport_objects_t->*
*               WT_E071K              =
*               ET_E071KF             =
*               ET_E070A              =
    EXCEPTIONS not_exist_e070        = 1
               no_authorization      = 2
               Others                = 3 .

  IF gr_transport_objects_t->* IS INITIAL .
    gv_last_e071_position = 0 .
  ELSE .
    SORT gr_transport_objects_t->* .
    READ TABLE gr_transport_objects_t->* ASSIGNING <transport_object>
      INDEX sy-tfill .
    gv_last_e071_position = <transport_object>-as4pos .
  ENDIF .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  LOCK_TRANSPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_transport .

  CHECK p_trkorr IS NOT INITIAL .
  CALL FUNCTION 'ENQUEUE_E_TRKORR'
    EXPORTING  MODE_E070            = 'E'
               TRKORR               = p_trkorr
*     X_TRKORR             = ' '
*     _SCOPE               = '2'
*     _WAIT                = ' '
*     _COLLECT             = ' '
    EXCEPTIONS
      FOREIGN_LOCK         = 1
      SYSTEM_FAILURE       = 2
      OTHERS               = 3 .

  IF sy-subrc = 0 .
* Implement suitable error handling here
  ELSE .
    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
    <output>-status = ICON_FAILURE .
    <output>-notes  = text-n14 .
    CLEAR p_trkorr .
  ENDIF .

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DEACTIVATE_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM deactivate_parameters .

  LOOP AT screen .
    CHECK screen-name CS 'P_CLAS'  OR  screen-name CS 'S_CLAS'  OR
          screen-name CS 'P_WDYN'  OR  screen-name CS 'S_WDYN'  OR
          screen-name CS 'P_SCI' .
    screen-input = '0' .
    MODIFY SCREEN .
  ENDLOOP .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  ADD_INCLUDED_MODULES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_included_modules .


  CLEAR gt_compiler_results .
  go_abap_compiler = cl_abap_compiler=>create(
              p_name             = <main_module>-name
              p_no_package_check = abap_true
  ) .

  go_abap_compiler->get_all(
    IMPORTING  p_result = gt_compiler_results
               p_errors = gt_compiler_errors
  ) .

  LOOP AT gt_compiler_results ASSIGNING <compiler_result>
    WHERE tag = go_abap_compiler->tag_include .

    SELECT COUNT( * ) FROM trdir INTO gv_found
      WHERE name = <compiler_result>-name
        AND cnam = 'SAP' .
    IF gv_found = 0 .
* not standard object - can be checked

      CLEAR gr_transport_object->* .
      CLEAR gt_versions_info .
      gr_transport_object->*-pgmid    = 'LIMU' .
      gr_transport_object->*-object   = 'REPS' .
      gr_transport_object->*-obj_name = <compiler_result>-name .
      CALL FUNCTION 'SVRS_RESOLVE_E071_OBJ'
        EXPORTING  e071_obj        = gr_transport_object->*
        TABLES     obj_tab         = gt_versions_info
        EXCEPTIONS not_versionable = 1
                   Others          = 2 .


      READ TABLE gt_versions_info ASSIGNING <version_info>
        INDEX 1 .
      IF sy-subrc = 0 .
        gs_main_module-pgmid             = 'LIMU' .
        gs_main_module-object            = <version_info>-objtype .
        gs_main_module-obj_name          = <version_info>-objname .
        gs_main_module-name              = <compiler_result>-name .
        gs_main_module-generation_module = <main_module>-generation_module .
        gs_main_module-fugr_root_name    = <main_module>-fugr_root_name .
      ELSE .
        gs_main_module-pgmid             = <main_module>-pgmid .
        gs_main_module-object            = <main_module>-object .
        gs_main_module-obj_name          = <compiler_result>-name .
        gs_main_module-name              = <compiler_result>-name .
      ENDIF .

      gv_tabix = gv_tabix + 1 .
      INSERT gs_main_module INTO gt_main_modules INDEX gv_tabix .
    ENDIF .
  ENDLOOP .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  CHECK_FOR_UNHANDLED_CLAUSES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_RETURN_CODE  text
*----------------------------------------------------------------------*
FORM check_for_unhandled_clauses
  USING    pv_return_code              TYPE i .


  pv_return_code = 0 .

*
* clauses not handled (yet)
*
    LOOP AT gt_tokens ASSIGNING <token_group_by>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'SINGLE' .

      gv_contains_group_by = abap_true .
      gv_group_by_clause_row = <token_group_by>-row .

      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
      gv_contains_hints  = abap_true .
      <output>-status    = ICON_MESSAGE_WARNING .
      <output>-notes     = text-n13 .

      pv_return_code = 1 .
      RETURN .
    ENDIF .


    gv_contains_group_by = abap_false .
    gv_group_by_clause_row = 0 .
    LOOP AT gt_tokens ASSIGNING <token_group_by>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'GROUP' .

      gv_contains_group_by = abap_true .
      gv_group_by_clause_row = <token_group_by>-row .

      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
      gv_contains_hints  = abap_true .
      <output>-status    = ICON_MESSAGE_WARNING .
      <output>-notes     = text-n13 .

      pv_return_code = 1 .
      RETURN .
    ENDIF .

    LOOP AT gt_tokens TRANSPORTING NO FIELDS
      FROM <statement>-from TO <statement>-to
      WHERE str = '%_HINTS' .
      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
      gv_contains_hints  = abap_true .
      <output>-status    = ICON_MESSAGE_WARNING .
      <output>-notes     = text-n03 .

      pv_return_code = 1 .
      RETURN .
    ELSE .
      gv_contains_hints  = abap_false .
    ENDIF .


    LOOP AT gt_tokens TRANSPORTING NO FIELDS
      FROM <statement>-from TO <statement>-to
      WHERE str = 'ENTRIES' .
      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
* "FOR ALL ENTRIES" clause will be handled by adding SORT statement
*      <output>-status    = ICON_MESSAGE_WARNING .
*      <output>-notes     = text-n10 .
*
*      pv_return_code = 0 .
*      RETURN .
      gv_contains_fae = abap_true .
    ELSE .
      gv_contains_fae = abap_false .
    ENDIF .

    LOOP AT gt_tokens TRANSPORTING NO FIELDS
      FROM <statement>-from TO <statement>-to
      WHERE str = 'DISTINCT' .
      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
* "DISTINCT" clause cannot be AUTOMATICally be adjusted with ORDER BY
      <output>-status    = ICON_MESSAGE_WARNING .
      <output>-notes     = text-n11 .

      pv_return_code = 1 .
      RETURN .
    ENDIF .

ENDFORM .
