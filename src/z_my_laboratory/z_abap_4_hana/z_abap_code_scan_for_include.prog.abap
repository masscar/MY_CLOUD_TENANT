*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_SCAN_FOR_INCLUDE                                *
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
REPORT z_abap_code_scan_for_include      MESSAGE-ID zhec
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
  abap ,
  icon ,
  trwbo .


*-----------------------------------------------------------------------
*- TABLES --------------------------------------------------------------
*-----------------------------------------------------------------------
TABLES:
  rs38m .


*-----------------------------------------------------------------------
*- VARIABLES -----------------------------------------------------------
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
DATA:
  gt_rdir                              TYPE TABLE OF trdir ,
  gt_main_modules                      TYPE TABLE OF ty_module_list ,
  gt_components                        TYPE TABLE OF scompo ,
  gt_cross_references                  TYPE TABLE OF cross ,
  gt_includes_list                     TYPE TABLE OF d010inc .
FIELD-SYMBOLS:
  <rdir>                               LIKE LINE OF gt_rdir ,
  <main_module>                        LIKE LINE OF gt_main_modules ,
  <include_list>                       LIKE LINE OF gt_includes_list .

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
  gv_offset                            TYPE i ,
  gv_include_number                    TYPE includenr ,
  gv_trobj_name                        TYPE trobj_name ,
  gv_cnam                              TYPE trdir-cnam ,
  gv_found                             TYPE i .

DATA:
  gs_fugr                              TYPE trdir ,
  gt_fugr                              TYPE HASHED TABLE OF trdir
                                         WITH UNIQUE KEY name .
FIELD-SYMBOLS:
  <fugr>                               LIKE LINE OF gt_fugr .


*-----------------------------------------------------------------------
*- SALV ----------------------------------------------------------------
*-----------------------------------------------------------------------
TYPES:
  BEGIN OF ty_output ,
    main_module                        TYPE progname ,
    include_name                       TYPE progname ,
    object_name                        TYPE sobj_name ,
  END OF ty_output .
DATA:
  gt_output                            TYPE TABLE OF ty_output .
FIELD-SYMBOLS:
  <output>                             LIKE LINE OF gt_output ,
  <output_join>                        LIKE LINE OF gt_output .
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
*- SELECTION-SCREEN ----------------------------------------------------
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK 001
                 WITH FRAME TITLE text-b02 .


SELECTION-SCREEN BEGIN OF LINE .
PARAMETERS:
  p_prog                               TYPE c AS CHECKBOX .
SELECTION-SCREEN POSITION 5 .
SELECTION-SCREEN COMMENT 5(14) text-p02 .
SELECT-OPTIONS:
  s_prog                               FOR rs38m-programm .
SELECTION-SCREEN END OF LINE .

SELECTION-SCREEN END OF BLOCK 001 .


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


*-----------------------------------------------------------------------
*- START-OF-SELECTION --------------------------------------------------
*-----------------------------------------------------------------------
START-OF-SELECTION .

  PERFORM get_selected_objects .
  PERFORM scan_code .

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
*&      Form  GET_SELECTED_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_selected_objects .

  IF p_prog = abap_true .
*tab. d010inc - relazione main-includes
*    SELECT tadir~pgmid tadir~object tadir~obj_name trdir~name tadir~srcsystem APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
    SELECT trdir~name APPENDING CORRESPONDING FIELDS OF TABLE gt_main_modules
      FROM trdir AS trdir
*     INNER JOIN tadir AS tadir
*        ON tadir~pgmid     = 'R3TR'      AND
*           tadir~object    = 'PROG'      AND
*           tadir~obj_name  = trdir~name  "AND
**           tadir~srcsystem = sy-sysid
     WHERE trdir~name IN s_prog .
    DELETE gt_main_modules WHERE srcsystem = 'SAP' .

    SORT gt_main_modules .
    DELETE ADJACENT DUPLICATES FROM gt_main_modules .

    LOOP AT gt_main_modules ASSIGNING <main_module>
      WHERE generation_module IS INITIAL .
      gv_trobj_name = <main_module>-name .
      <main_module>-generation_module = cl_ci_objectset=>get_program(
                                                     p_pgmid   = 'R3TR'
                                                     p_objtype = 'PROG'
                                                     p_objname = gv_trobj_name
                                        ) .
    ENDLOOP .
  ENDIF . "P_PROG checkbox selected


  DELETE gt_main_modules WHERE name = sy-repid .

ENDFORM .


*&---------------------------------------------------------------------*
*&      Form  SCAN_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM scan_code .


* add INCLUDE modules for main objects (FUGR, PROG, ...)
  LOOP AT gt_main_modules ASSIGNING <main_module> .

*    CLEAR gt_compiler_results .
*    go_abap_compiler = cl_abap_compiler=>create(
*                p_name             = <main_module>-name
**                p_no_package_check = abap_true
*    ) .
*
*    go_abap_compiler->get_all(
*      IMPORTING  p_result = gt_compiler_results
*                 p_errors = gt_compiler_errors
*    ) .
*
*    LOOP AT gt_compiler_results ASSIGNING <compiler_result>
*      WHERE tag = go_abap_compiler->tag_include .
*
*      CLEAR gv_cnam .
*      SELECT SINGLE cnam FROM trdir
*        INTO gv_cnam
*        WHERE name = <compiler_result>-name .
*      IF gv_cnam = 'SAP' .
** standard module - it will not be extract
*      ELSE .
*        APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
*        <output>-main_module  = <main_module>-name .
*        <output>-include_name = <compiler_result>-name .
*      ENDIF .
*    ENDLOOP .
    CLEAR:
      gt_includes_list ,
      gt_cross_references ,
      gt_components .
    CALL FUNCTION 'RS_PROGRAM_INDEX'
      EXPORTING  pg_name         = <main_module>-name
*                 WITHOUT_TREE   = ' '
*      IMPORTING  MESSAGE_CLASS  =
      TABLES     compo          = gt_components
                 cross_ref      = gt_cross_references
                 inc            = gt_includes_list
      EXCEPTIONS syntax_error   = 1
                 Others         = 2 .

    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    LOOP AT gt_includes_list ASSIGNING <include_list> .
      IF <include_list>-include CA '%' .
      ELSE .
        CLEAR gv_cnam .
        SELECT SINGLE cnam FROM trdir
          INTO gv_cnam
          WHERE name = <include_list>-include .
        IF gv_cnam = 'SAP' .
* standard module - it will not be extract
        ELSE .
          APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
          <output>-main_module   = <include_list>-master .
          <output>-include_name  = <include_list>-include .
          <output>-object_name   = '' .

* check if main module is a function group
          READ TABLE gt_fugr ASSIGNING <fugr>
            WITH KEY name = <include_list>-master .
          IF sy-subrc = 0 .

          ELSE .
            SELECT SINGLE *
              FROM trdir
              INTO gs_fugr
             WHERE name = <include_list>-master
               AND subc = 'F' .

            IF sy-subrc = 0 .
              INSERT gs_fugr INTO TABLE gt_fugr .
            ENDIF .

            READ TABLE gt_fugr ASSIGNING <fugr>
              WITH KEY name = <include_list>-master .
          ENDIF .
* main module is a function group, we can translate include name into function name
          IF sy-subrc = 0 .
            gv_offset = strlen( <include_list>-include ) .
            gv_offset = gv_offset - 2 .
            gv_include_number = <include_list>-include+gv_offset(02) .
            SELECT SINGLE funcname
              FROM tfdir
              INTO <output>-object_name
             WHERE pname   = <include_list>-master
               AND include = gv_include_number .
            IF sy-subrc = 0 .
            ELSE .
              <output>-object_name = <include_list>-include .
            ENDIF .
          ELSE .
            <output>-object_name = <include_list>-include .
          ENDIF .
        ENDIF .
      ENDIF .
    ENDLOOP .

  ENDLOOP .

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

*      CASE <column>-columnname .
*        WHEN 'STATUS' .
*          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .
*
*        WHEN 'NOTES' .
*          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .
**        <column>-r_column->set_output_length( 40 ) .
*        WHEN Others .
*      ENDCASE .
    ENDLOOP .

* functions
    go_salv_functions->set_all( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_export_spreadsheet( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_change( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_load( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_maintain( if_salv_c_bool_sap=>true ) .
    go_salv_functions->set_layout_save( if_salv_c_bool_sap=>true ) .


    go_salv->display( ) .


  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

ENDFORM .
