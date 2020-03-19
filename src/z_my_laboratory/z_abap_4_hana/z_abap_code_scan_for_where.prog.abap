*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_SCAN_FOR_WHERE                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Author      : M. CARDOSI (SAP ITALIA) -------------------------------
*& Date        : 24.03.2017 --------------------------------------------
*& Description : -------------------------------------------------------
*&
*& <description>
*&
*&
*&
*&
*&---------------------------------------------------------------------*
REPORT z_abap_code_scan_for_where      MESSAGE-ID z_abap_4_hana
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
  icon ,
  trwbo .


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
  gv_contains_hints                    TYPE boole_d .
FIELD-SYMBOLS:
  <token_group_by>                     LIKE LINE OF gt_tokens .
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
*  gt_backup_objects                    TYPE TABLE OF zbck_abap_4_hana ,
*  gs_backup_object                     TYPE zbck_abap_4_hana ,
*  gs_backup_repository                 TYPE zbck_abap_4_hana ,
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
  gr_transport_objects_t               TYPE REF TO tr_objects ,
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
  gv_progress_text                     TYPE syucomm ,
  gv_sytabix                           TYPE c LENGTH 6 ,
  gv_sytfill                           TYPE c LENGTH 6 .

DATA:
  r_object                             TYPE RANGE OF e071-object .
FIELD-SYMBOLS:
  <r_object>                           LIKE LINE OF r_object .


*-----------------------------------------------------------------------
*- SALV ----------------------------------------------------------------
*-----------------------------------------------------------------------
DATA:
  gt_output                            TYPE TABLE OF zst_abap_scan_tables_list .
FIELD-SYMBOLS:
  <output>                             LIKE LINE OF gt_output ,
  <output_join>                        LIKE LINE OF gt_output .
DATA:
  go_salv                              TYPE REF TO cl_salv_table ,
  go_salv_layout                       TYPE REF TO cl_salv_layout ,
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


*------------------------------------------------------------------------------
AT SELECTION-SCREEN ON p_sci .

  IF p_sci IS NOT INITIAL .
    IF p_scin IS INITIAL OR
       p_sciu IS INITIAL OR
       p_sciv IS INITIAL .

      MESSAGE e004 WITH '' . "p_trkorr .
    ENDIF .

    CLEAR go_sci_inspector .
    go_sci_inspector = cl_ci_inspection=>get_ref( p_user = p_sciu
                                                  p_name = p_scin
                                                  p_vers = p_sciv
                                                ) .
    IF go_sci_inspector IS BOUND .
    ELSE .
      MESSAGE e004 WITH '' . "p_trkorr .
    ENDIF .

  ENDIF .



*------------------------------------------------------------------------------
AT SELECTION-SCREEN .


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
  WRITE gv_tfill TO gv_sytfill NO-GAP NO-GROUPING .
  LOOP AT gt_main_modules ASSIGNING <main_module> .

    gv_progress_percentage = ( sy-tabix * 100 ) / gv_tfill .
    WRITE sy-tabix TO gv_sytabix NO-GAP NO-GROUPING .
*    WRITE sy-tfill TO gv_sytfill NO-GAP NO-GROUPING .
*    gv_progress_text = |{ sy-tabix }/{ gv_tfill }: { <main_module>-pgmid } - { <main_module>-object } - { <main_module>-obj_name }| .
    CONCATENATE gv_sytabix
                ' / '
                gv_sytfill
                ': '
                <main_module>-pgmid
                ' - '
                <main_module>-object
                ' - '
                <main_module>-obj_name
           INTO gv_progress_text
       RESPECTING BLANKS .
    CONDENSE gv_progress_text .
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
       WITH LIST TOKENIZATION .
**       WITH BLOCKS
**       WITH PRAGMAS abap_true .

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

*BREAK sap_i025305 .

* scan SELECT statements
  gv_current_row_scan = 1 .
  gv_statement_shift = 0 .
  LOOP AT gt_tokens ASSIGNING <token>
     FROM gv_current_row_scan
    WHERE str = 'SELECT' .
    gv_current_row_scan = sy-tabix .


* get current statement
    READ TABLE gt_statements ASSIGNING <statement>
      WITH KEY from = gv_current_row_scan .
    IF <statement> IS NOT ASSIGNED .
* "SELECT" has been found but it's not a statement, maybe a variable... - we'll skip to next token
      CONTINUE .
    ENDIF .

* set first token of current statement
    ASSIGN <token> TO <select_start_row> .
* set last token of current statement
    READ TABLE gt_tokens ASSIGNING <select_end_row>
      INDEX <statement>-to .


* log
    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
    <output>-main_program = <main_module>-generation_module .
    <output>-module_name  = <main_module>-name .
    <output>-line      = <token>-row + gv_statement_shift .
    <output>-status    = ICON_SPACE .
    <output>-notes     = text-n08 .


*SELECT...INTO TABLE does not contain ORDER BY clause - will be inserted
* look for db table name
    LOOP AT gt_tokens ASSIGNING <token_nested>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'FROM' .
      gv_tablename_token_line = sy-tabix + 1 .
      EXIT .
    ENDLOOP .

* look for table name
    READ TABLE gt_tokens ASSIGNING <token_nested>
      INDEX gv_tablename_token_line .
    <output>-tabname = gv_tablename = <token_nested>-str .
    WHILE gv_tablename = '(' .
      gv_tablename_token_line = gv_tablename_token_line + 1 .
      READ TABLE gt_tokens ASSIGNING <token_nested>
        INDEX gv_tablename_token_line .
      gv_tablename = <token_nested>-str .
    ENDWHILE .
    <output>-tabname = gv_tablename .
* table name found - check if it's really a table or not
    CLEAR gs_table_info .
    CALL FUNCTION 'DD_INT_TABL_GET'
      EXPORTING  TABNAME        = gv_tablename
      IMPORTING  DD02V_A        = gs_table_info
      EXCEPTIONS INTERNAL_ERROR = 1
                 OTHERS         = 2 .
* get table key fields
    SELECT fieldname position
      FROM dd03l
      INTO CORRESPONDING FIELDS OF TABLE gt_key_fields
     WHERE tabname = gv_tablename
       AND keyflag = abap_true
     ORDER BY position .
    DELETE gt_key_fields
      WHERE fieldname = 'MANDT'
         OR fieldname = 'CLIENT'
         OR fieldname = 'RCLNT' .

* look for WHERE token
    LOOP AT gt_tokens ASSIGNING <token_nested>
      FROM <statement>-from TO <statement>-to
      WHERE str = 'WHERE' .
      gv_into_table_token_line = sy-tabix .
    ENDLOOP .
    IF sy-subrc = 0 .
      gv_into_table_token_line = gv_into_table_token_line + 1 .
      READ TABLE gt_tokens ASSIGNING <token_nested>
        INDEX gv_into_table_token_line .
      <output>-notes = <token_nested>-str .
      DELETE gt_key_fields
        WHERE fieldname = <token_nested>-str .
    ELSE .
* get statement level - looping statment (i.e. SELECT/ENDSELECT) can be detected here
      CONTINUE .
    ENDIF .

* loop over conditions
DATA:
  lv_condition_row                     TYPE i .
FIELD-SYMBOLS:
  <condition>                          LIKE LINE OF gt_tokens .
    LOOP AT gt_tokens ASSIGNING <token_nested>
      FROM gv_into_table_token_line TO <statement>-to
      WHERE str = 'AND'
         OR str = 'OR' .
      lv_condition_row = sy-tabix + 1 .
      READ TABLE gt_tokens ASSIGNING <condition>
        INDEX lv_condition_row .
      <output>-notes = |{ <output>-notes }, { <condition>-str }| .
      DELETE gt_key_fields
        WHERE fieldname = <condition>-str .
    ENDLOOP .

    IF LINES( gt_key_fields ) = 0 .
      <output>-status    = ICON_LED_GREEN .
    ELSE .
      <output>-status    = ICON_LED_YELLOW .
    ENDIF .

    UNASSIGN <statement> .
  ENDLOOP .


  WAIT UP TO '0.1' SECONDS .

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

* layout
    go_salv_layout           = go_salv->get_layout( ) .
    go_salv_layout->set_default( if_salv_c_bool_sap=>true ) .

* functions
    go_salv_functions->set_all( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_export_spreadsheet( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_change( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_load( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_maintain( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_save( if_salv_c_bool_sap=>true ) .

* display ALV
    go_salv->display( ) .


  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

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
*          <main_module>-name              = |{ <main_func>-pname+03 }U{ <main_func>-include }| .
          CONCATENATE <main_func>-pname+03
                      'U'
                      <main_func>-include
                 INTO <main_module>-name .
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
*      <main_module>-name              = |{ <main_func>-pname+03 }U{ <main_func>-include }| .
      CONCATENATE <main_func>-pname+03
                  'U'
                  <main_func>-include
             INTO <main_module>-name .
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

*****  CHECK p_trkorr IS NOT INITIAL .
*****
*****
*****  gr_request_header->*-trkorr =  p_trkorr .
*****  CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
*****    EXPORTING  iv_read_e070           = abap_true
******               IV_READ_E07T           = ' '
*****               iv_read_e070c          = abap_true
*****               iv_read_e070m          = abap_true
******    IMPORTING  EV_E07T_DOESNT_EXIST   =
******               EV_E070C_DOESNT_EXIST  =
******               EV_E070M_DOESNT_EXIST  =
*****    CHANGING   cs_request             = gr_request_header->*
*****    EXCEPTIONS empty_trkorr           = 1
*****               not_exist_e070         = 2
*****               Others                 = 3 .
*****
*****
*****
*****  CALL FUNCTION 'TR_READ_COMM'
*****    EXPORTING  wi_trkorr             = gr_request_header->*-trkorr
*****               wi_dialog             = abap_false
*****               wi_langu              = sy-langu
*****               wi_sel_e070           = abap_false
*****               wi_sel_e071           = abap_true
******               WI_SEL_E071K          = ' '
******               IV_SEL_E071KF         = ' '
******               WI_SEL_E07T           = ' '
******               WI_SEL_E070C          = ' '
******               IV_SEL_E070M          = ' '
******               IV_SEL_E070A          = ' '
******    IMPORTING  WE_E070               =
******               WE_E07T               =
******               WE_E070C              =
******               ES_E070M              =
******               WE_E07T_DOESNT_EXIST  =
******               WE_E070C_DOESNT_EXIST =
******               EV_E070M_DOESNT_EXIST =
******               WT_E071K_STR          =
*****    TABLES     wt_e071               = gr_transport_objects_t->*
******               WT_E071K              =
******               ET_E071KF             =
******               ET_E070A              =
*****    EXCEPTIONS not_exist_e070        = 1
*****               no_authorization      = 2
*****               Others                = 3 .
*****
*****  IF gr_transport_objects_t->* IS INITIAL .
*****    gv_last_e071_position = 0 .
*****  ELSE .
*****    SORT gr_transport_objects_t->* .
*****    READ TABLE gr_transport_objects_t->* ASSIGNING <transport_object>
*****      INDEX sy-tfill .
*****    gv_last_e071_position = <transport_object>-as4pos .
*****  ENDIF .

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

*****  CHECK p_trkorr IS NOT INITIAL .
*****  CALL FUNCTION 'ENQUEUE_E_TRKORR'
*****    EXPORTING  MODE_E070            = 'E'
*****               TRKORR               = p_trkorr
******     X_TRKORR             = ' '
******     _SCOPE               = '2'
******     _WAIT                = ' '
******     _COLLECT             = ' '
*****    EXCEPTIONS
*****      FOREIGN_LOCK         = 1
*****      SYSTEM_FAILURE       = 2
*****      OTHERS               = 3 .
*****
*****  IF sy-subrc = 0 .
****** Implement suitable error handling here
*****  ELSE .
*****    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
*****    <output>-status = ICON_FAILURE .
*****    <output>-notes  = text-n14 .
*****    CLEAR p_trkorr .
*****  ENDIF .

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

  READ REPORT <main_module>-generation_module INTO gt_abap_lines .
  CLEAR:
    gt_keywords ,
    gt_tokens ,
    gt_statements ,
    gt_levels ,
    gt_structures .
  SCAN ABAP-SOURCE     gt_abap_lines
       KEYWORDS        FROM gt_keywords
       TOKENS          INTO gt_tokens
       STATEMENTS      INTO gt_statements
       LEVELS          INTO gt_levels
       STRUCTURES      INTO gt_structures
       FRAME PROGRAM   FROM <main_module>-generation_module
*       INCLUDE PROGRAM FROM gv_include_name
       MESSAGE         INTO gv_message
       INCLUDE         INTO gv_include
       LINE            INTO gv_line
       WORD            INTO gv_word
       WITH ANALYSIS
       WITH INCLUDES
       WITH COMMENTS
**       WITH DECLARATIONS
*       WITH LIST TOKENIZATION
**       WITH BLOCKS
       WITH PRAGMAS abap_true .

  LOOP AT gt_levels ASSIGNING <level> .
    IF <level>-name CS '---' .
    ELSE .
      SELECT COUNT( * ) FROM trdir INTO gv_found
        WHERE name = <level>-name
          AND cnam = 'SAP' .
      IF gv_found = 0 .
* not standard object - can be checked

        CLEAR gr_transport_object->* .
        CLEAR gt_versions_info .
        gr_transport_object->*-pgmid    = 'LIMU' .
        gr_transport_object->*-object   = 'REPS' .
        gr_transport_object->*-obj_name = <level>-name .
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
          gs_main_module-name              = <level>-name .
          gs_main_module-generation_module = <main_module>-generation_module .
          gs_main_module-fugr_root_name    = <main_module>-fugr_root_name .
          gs_main_module-srcsystem         = <main_module>-srcsystem .
        ELSE .
          gs_main_module-pgmid             = <main_module>-pgmid .
          gs_main_module-object            = <main_module>-object .
          gs_main_module-obj_name          = <level>-name .
          gs_main_module-name              = <level>-name .
          gs_main_module-srcsystem         = <main_module>-srcsystem .
        ENDIF .

        gv_tabix = gv_tabix + 1 .
        INSERT gs_main_module INTO gt_main_modules INDEX gv_tabix .
      ENDIF .

    ENDIF .
  ENDLOOP .

***
*  CLEAR gt_compiler_results .
*  go_abap_compiler = cl_abap_compiler=>create(
*              p_name             = <main_module>-name
**              p_no_package_check = abap_true
*  ) .
*
*
*  go_abap_compiler->get_all(
*    IMPORTING  p_result = gt_compiler_results
*               p_errors = gt_compiler_errors
*  ) .
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
*
*      READ TABLE gt_versions_info ASSIGNING <version_info>
*        INDEX 1 .
*      IF sy-subrc = 0 .
*        gs_main_module-pgmid             = 'LIMU' .
*        gs_main_module-object            = <version_info>-objtype .
*        gs_main_module-obj_name          = <version_info>-objname .
*        gs_main_module-name              = <compiler_result>-name .
*        gs_main_module-generation_module = <main_module>-generation_module .
*        gs_main_module-fugr_root_name    = <main_module>-fugr_root_name .
*      ELSE .
*        gs_main_module-pgmid             = <main_module>-pgmid .
*        gs_main_module-object            = <main_module>-object .
*        gs_main_module-obj_name          = <compiler_result>-name .
*        gs_main_module-name              = <compiler_result>-name .
*      ENDIF .
*
*      gv_tabix = gv_tabix + 1 .
*      INSERT gs_main_module INTO gt_main_modules INDEX gv_tabix .
*    ENDIF .
*  ENDLOOP .

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
* "FOR ALL ENTRIES" clause cannot be AUTOMATICally be adjusted with ORDER BY
      <output>-status    = ICON_MESSAGE_WARNING .
      <output>-notes     = text-n10 .

      pv_return_code = 1 .
      RETURN .
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
