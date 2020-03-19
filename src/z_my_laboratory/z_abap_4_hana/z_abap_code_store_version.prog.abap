*&---------------------------------------------------------------------*
*& Report  Z_ABAP_CODE_STORE_VERSION                                   *
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
REPORT z_abap_code_store_version       MESSAGE-ID z_abap_4_hana
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
*TYPES:
*  BEGIN OF ty_objects_version ,
*  END OF ty_objects_version .


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
DATA:
  gv_pgmid                             TYPE pgmid ,
  gv_object                            TYPE trobjtype ,
  gv_obj_name                          TYPE sobj_name ,
  gv_trobj_name                        TYPE trobj_name ,
  gv_wdyn_name                         TYPE trobj_name .

DATA:
  gt_versions_list                     TYPE TABLE OF vrsd_old ,
  gt_versions_last                     TYPE TABLE OF vrsd .
FIELD-SYMBOLS:
  <version>                            LIKE LINE OF gt_versions_list .

DATA:
  gt_abap_lines                        TYPE sci_include .

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
  gv_return_code                       TYPE sysubrc .


*-----------------------------------------------------------------------
*- SALV ----------------------------------------------------------------
*-----------------------------------------------------------------------
DATA:
  gt_output                            TYPE TABLE OF zst_abap_restore_code_list .
FIELD-SYMBOLS:
  <output>                             LIKE LINE OF gt_output .
DATA:
  go_alv                               TYPE REF TO cl_salv_table ,
  go_events                            TYPE REF TO cl_salv_events_table ,
  go_columns                           TYPE REF TO cl_salv_columns ,
  gt_col_tab                           TYPE salv_t_column_ref .
FIELD-SYMBOLS:
  <column>                             LIKE LINE OF gt_col_tab .
DATA:
  gv_current_output_row                TYPE i .


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

*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON RADIOBUTTON GROUP objt .

*break i025305.

  CASE abap_true .
    WHEN p_class .
      gv_pgmid    = 'R3TR' .
      gv_object   = 'CLAS' .
*      gv_obj_name = s_clas-low .

    WHEN p_repid .
      gv_pgmid    = 'R3TR' .
      gv_object   = 'PROG' .
      gv_obj_name = s_repid-low .

    WHEN p_fugr .
      gv_pgmid    = 'R3TR' .
      gv_object   = 'FUGR' .
      gv_obj_name = s_fugr-low .

    WHEN p_wdyn .
      gv_pgmid    = 'R3TR' .
      gv_object   = 'WDYN' .
*      gv_obj_name = gv_wdyn_name = s_wdyn-low .


    WHEN Others .

  ENDCASE .

*  PERFORM check_tadir .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_repid-low .

DATA: info_object LIKE euobj-id .

  info_object = 'PROG'.
  CALL FUNCTION 'REPOSITORY_INFO_SYSTEM_F4'
    EXPORTING  object_type          = info_object
               object_name          = s_repid-low
               suppress_selection   = 'X'
    IMPORTING  object_name_selected = s_repid-low
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
AT SELECTION-SCREEN ON s_repid .

*  LOOP AT s_repid .
*    gv_obj_name = s_repid-low .
*    PERFORM check_tadir .
*  ENDLOOP .


*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON s_fugr .

*  LOOP AT s_fugr .
*    gv_obj_name = s_fugr-low .
*    PERFORM check_tadir .
*  ENDLOOP .


*-----------------------------------------------------------------------
*- START-OF-SELECTION --------------------------------------------------
*-----------------------------------------------------------------------
START-OF-SELECTION .


  PERFORM build_object_list .


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
*&      Form  BACKUP_SOURCE_CODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_gv_PROGRAM_NAME  text
*      -->P_LT_ABAP_LINES  text
*----------------------------------------------------------------------*
FORM build_object_list .

DATA:
  lv_object_name                       TYPE vrsd_old-objname ,
  lv_trobj_name                        TYPE trobj_name .


break i025305 .
break sap_i025305 .


  SELECT DISTINCT object obj_name tot_changes main_program include_program trkorr created_by created_at changed_by changed_at
    FROM zbck_abap_4_hana
    INTO CORRESPONDING FIELDS OF TABLE gt_backup_objects
   WHERE srtf2 = 0 .


  LOOP AT gt_backup_objects ASSIGNING <backup_object> .
    CLEAR gs_backup_object .
    CLEAR gt_abap_lines .
    gs_backup_key-object   = <backup_object>-object .
    gs_backup_key-obj_name = <backup_object>-obj_name .
    IMPORT source_code = gt_abap_lines
      FROM DATABASE zbck_abap_4_hana(00)
        ID gs_backup_key
        TO gs_backup_object .

    CASE gs_backup_key-object .
      WHEN 'PROG' .
        lv_trobj_name = gs_backup_key-obj_name .
        gs_backup_object-main_program    = cl_ci_objectset=>get_program(
                                             EXPORTING  p_pgmid   = 'LIMU'
                                                        p_objtype = 'REPS'
                                                        p_objname = lv_trobj_name
                                           ) .
        gs_backup_object-include_program = gs_backup_key-obj_name .

      WHEN 'FUGR' .
        lv_trobj_name = gs_backup_key-obj_name .
        gs_backup_object-main_program    = cl_ci_objectset=>get_program(
                                             EXPORTING  p_pgmid   = 'LIMU'
                                                        p_objtype = 'REPS'
                                                        p_objname = lv_trobj_name
                                           ) .
        gs_backup_object-include_program = gs_backup_key-obj_name .

      WHEN 'FUNC' .
        SELECT SINGLE pname include
          INTO ( gs_backup_object-main_program, gs_backup_object-include_program )
          FROM tfdir
         WHERE funcname = gs_backup_key-obj_name .
         gs_backup_object-include_program = |{ gs_backup_object-main_program }U{ gs_backup_object-include_program }| .
         gs_backup_object-include_program = gs_backup_object-include_program+03 .

    ENDCASE .

*        gs_backup_object-created_by      = sy-uname .
*        gs_backup_object-created_at      = sy-udate .


    CLEAR gt_versions_list .
    CLEAR gt_versions_last .
* get version from transport request
    lv_object_name = gs_backup_object-include_program .
    CALL FUNCTION 'SVRS_GET_VERSION_DIRECTORY'
      EXPORTING  objname      = lv_object_name
                 objtype      = 'REPS'
      TABLES     lVersno_list = gt_versions_last
                 version_list = gt_versions_list
      EXCEPTIONS no_entry     = 1
                 Others       = 2 .
    SORT gt_versions_list BY versno DESCENDING .
    LOOP AT gt_versions_list ASSIGNING <version>
*      INDEX 1 .
      WHERE korrnum <> 'DIMK900054' .
      EXIT .
    ENDLOOP .
    IF sy-subrc = 0 .
      gs_backup_object-trkorr = <version>-korrnum .
    ELSE .
      CLEAR gs_backup_object-trkorr .
    ENDIF .

    EXPORT source_code = gt_abap_lines
        TO DATABASE zbck_abap_4_hana(00)
        ID gs_backup_key
      FROM gs_backup_object .
    gv_return_code = sy-subrc .


    APPEND INITIAL LINE TO gt_output ASSIGNING <output> .
    <output>-object          = gs_backup_key-object .
    <output>-obj_name        = gs_backup_key-obj_name .
    <output>-main_program    = gs_backup_object-main_program .
    <output>-include_program = gs_backup_object-include_program .
    <output>-trkorr          = gs_backup_repository-trkorr .
    <output>-tot_changes     = gs_backup_object-tot_changes .

    IF gv_return_code IS INITIAL .
      <output>-status = ICON_LED_GREEN .
    ELSE .
      <output>-status = ICON_LED_RED .
      <output>-notes  = text-n01 .
    ENDIF .

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
      IMPORTING r_salv_table = go_alv
      CHANGING  t_table      = gt_output
    ) .

    go_events = go_alv->get_event( ) .
*    SET HANDLER cl_sagv_events_table->double_click FOR lo_events .
    go_columns = go_alv->get_columns( ) .
    gt_col_tab = go_columns->get( ) .

*    READ TABLE gt_col_tab ASSIGNING <column>
*      WITH KEY columnname = 'NOTES' .
*    <column>-r_column->set_optimized( abap_true ) .

    LOOP AT gt_col_tab ASSIGNING <column> .
      <column>-r_column->set_visible( <column>-r_column->if_salv_c_bool_sap~true ) .

      CASE <column>-columnname .
        WHEN 'STATUS' .
          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .

        WHEN 'NOTES' .
          <column>-r_column->set_optimized( <column>-r_column->if_salv_c_bool_sap~true ) .
*        <column>-r_column->set_output_length( 40 ) .
        WHEN Others .
      ENDCASE .
    ENDLOOP.
    go_alv->display( ) .

  CATCH cx_salv_msg .
    MESSAGE 'ALV display not possible' TYPE 'I'
                DISPLAY LIKE 'E'.
  ENDTRY .

ENDFORM .
